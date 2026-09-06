import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../history/database.dart';
import '../history/place_catalog.dart';
import '../location/site_anchor.dart';
import '../providers/history_provider.dart';
import '../providers/location_provider.dart';

/// Управление каталогом: места, комнаты, источники и привязка к координатам.
///
/// Отдельный экран, а не режим редактирования внутри листа выбора: выбор перед
/// замером должен оставаться быстрым, а правка каталога — редкое занятие, ради
/// которого не жалко открыть страницу.
class PlacesPage extends ConsumerWidget {
  const PlacesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(placeCatalogViewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Места замеров')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSite(context, ref),
        icon: const Icon(Icons.add_home_outlined),
        label: const Text('Место'),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (catalog) => catalog.sites.isEmpty
            ? const _EmptyState()
            : ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  for (final site in catalog.sites) _SiteSection(site: site, catalog: catalog),
                ],
              ),
      ),
    );
  }

  Future<void> _addSite(BuildContext context, WidgetRef ref) async {
    final result = await _promptNameAndCity(context, title: 'Новое место');
    if (result == null) return;

    await ref.read(placeCatalogProvider).addSite(result.$1, city: result.$2);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Пока нет ни одного места.\nДобавьте дом или дачу — источники живут внутри них.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Одно место со всем, что внутри.
class _SiteSection extends ConsumerWidget {
  final Site site;
  final PlaceCatalog catalog;

  const _SiteSection({required this.site, required this.catalog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rooms = catalog.roomsOfSite(site.id);
    final loose = catalog.sourcesDirectlyOnSite(site.id);
    final hasAnchor = site.latitude != null && site.longitude != null;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(site.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(_subtitle(hasAnchor)),
        leading: Icon(
          hasAnchor ? Icons.my_location : Icons.location_disabled_outlined,
          color: hasAnchor ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
        trailing: PopupMenuButton<_SiteAction>(
          onSelected: (action) => _onAction(context, ref, action),
          itemBuilder: (_) => const [
            PopupMenuItem(value: _SiteAction.rename, child: Text('Переименовать')),
            PopupMenuItem(value: _SiteAction.addRoom, child: Text('Добавить комнату')),
            PopupMenuItem(value: _SiteAction.addSource, child: Text('Добавить источник')),
            PopupMenuItem(value: _SiteAction.bind, child: Text('Привязать здесь')),
            PopupMenuItem(value: _SiteAction.unbind, child: Text('Сбросить привязку')),
            PopupMenuItem(value: _SiteAction.delete, child: Text('Удалить место')),
          ],
        ),
        children: [
          for (final source in loose) _SourceRow(source: source, indent: 16),
          for (final room in rooms) ...[
            _RoomRow(room: room, catalog: catalog),
            for (final source in catalog.sourcesOfRoom(room.id))
              _SourceRow(source: source, indent: 40),
          ],
          if (loose.isEmpty && rooms.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('Источников пока нет'),
            ),
        ],
      ),
    );
  }

  String _subtitle(bool hasAnchor) {
    final parts = <String>[
      if (site.city != null) site.city!,
      if (hasAnchor)
        'привязано по ${site.anchorSamples} замерам'
      else
        'без привязки — не подставляется автоматически',
    ];
    return parts.join(' · ');
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref, _SiteAction action) async {
    final catalogRepo = ref.read(placeCatalogProvider);
    final messenger = ScaffoldMessenger.of(context);

    switch (action) {
      case _SiteAction.rename:
        final result = await _promptNameAndCity(
          context,
          title: 'Переименовать место',
          initialName: site.name,
          initialCity: site.city,
        );
        if (result != null) await catalogRepo.renameSite(site.id, result.$1, city: result.$2);

      case _SiteAction.addRoom:
        final name = await _promptName(context, title: 'Новая комната');
        if (name != null) await catalogRepo.addRoom(site.id, name);

      case _SiteAction.addSource:
        final name = await _promptName(context, title: 'Новый источник');
        if (name != null) await catalogRepo.addSource(site.id, name);

      case _SiteAction.bind:
        // Привязка руками — единственный способ задать координаты месту, где
        // ещё ни разу не сохраняли замер.
        final location = await ref.read(locationServiceProvider).currentLocation();
        final point = location.location;
        if (point == null) {
          messenger.showSnackBar(
            SnackBar(content: Text(location.failure?.message ?? 'Координаты недоступны')),
          );
          return;
        }
        await catalogRepo.setSiteAnchor(site.id, updateAnchor(null, point));
        messenger.showSnackBar(const SnackBar(content: Text('Место привязано к этой точке')));

      case _SiteAction.unbind:
        await catalogRepo.setSiteAnchor(site.id, null);

      case _SiteAction.delete:
        final confirmed = await _confirm(
          context,
          title: 'Удалить «${site.name}»?',
          message:
              'Вместе с ним исчезнут его комнаты и источники. '
              'Замеры останутся в истории со своими названиями.',
        );
        if (confirmed) await catalogRepo.deleteSite(site.id);
    }
  }
}

enum _SiteAction { rename, addRoom, addSource, bind, unbind, delete }

class _RoomRow extends ConsumerWidget {
  final Room room;
  final PlaceCatalog catalog;

  const _RoomRow({required this.room, required this.catalog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 28, right: 8),
      dense: true,
      leading: Icon(
        Icons.meeting_room_outlined,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(room.name, style: theme.textTheme.labelLarge),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          final repo = ref.read(placeCatalogProvider);
          if (value == 'source') {
            final name = await _promptName(context, title: 'Источник в «${room.name}»');
            if (name != null) await repo.addSource(room.siteId, name, roomId: room.id);
          } else if (value == 'rename') {
            final name = await _promptName(
              context,
              title: 'Переименовать комнату',
              initial: room.name,
            );
            if (name != null) await repo.renameRoom(room.id, name);
          } else if (value == 'delete') {
            final confirmed = await _confirm(
              context,
              title: 'Удалить «${room.name}»?',
              message: 'Источники этой комнаты тоже исчезнут. История не меняется.',
            );
            if (confirmed) await repo.deleteRoom(room.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'source', child: Text('Добавить источник')),
          PopupMenuItem(value: 'rename', child: Text('Переименовать')),
          PopupMenuItem(value: 'delete', child: Text('Удалить комнату')),
        ],
      ),
    );
  }
}

class _SourceRow extends ConsumerWidget {
  final SamplingPoint source;
  final double indent;

  const _SourceRow({required this.source, required this.indent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.only(left: indent, right: 8),
      dense: true,
      leading: Icon(Icons.water_drop_outlined, size: 18, color: theme.colorScheme.primary),
      title: Text(source.name),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          final repo = ref.read(placeCatalogProvider);
          if (value == 'rename') {
            final name = await _promptName(
              context,
              title: 'Переименовать источник',
              initial: source.name,
            );
            if (name != null) await repo.renameSource(source.id, name);
          } else if (value == 'delete') {
            final confirmed = await _confirm(
              context,
              title: 'Удалить «${source.name}»?',
              message: 'Замеры этого источника останутся в истории со своим названием.',
            );
            if (confirmed) await repo.deleteSource(source.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'rename', child: Text('Переименовать')),
          PopupMenuItem(value: 'delete', child: Text('Удалить источник')),
        ],
      ),
    );
  }
}

/// Диалог с одним полем имени. Возвращает `null`, если отменили или ввели пусто.
Future<String?> _promptName(BuildContext context, {required String title, String? initial}) async {
  final controller = TextEditingController(text: initial);

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Название'),
        onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Отмена')),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: const Text('Готово'),
        ),
      ],
    ),
  );

  controller.dispose();
  final trimmed = result?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

/// Диалог имени и города для места. Город необязателен и нужен только чтобы
/// различать одинаково названные места в разных городах.
Future<(String, String?)?> _promptNameAndCity(
  BuildContext context, {
  required String title,
  String? initialName,
  String? initialCity,
}) async {
  final nameController = TextEditingController(text: initialName);
  final cityController = TextEditingController(text: initialCity);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Название', hintText: 'Дача'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cityController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Город (необязательно)',
              hintText: 'Тверь',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Готово'),
        ),
      ],
    ),
  );

  final name = nameController.text.trim();
  final city = cityController.text.trim();
  nameController.dispose();
  cityController.dispose();

  if (confirmed != true || name.isEmpty) return null;
  return (name, city.isEmpty ? null : city);
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );

  return result ?? false;
}
