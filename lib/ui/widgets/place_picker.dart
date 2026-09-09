import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../history/database.dart';
import '../../history/measurement_place.dart';
import '../../history/place_catalog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/app_settings.dart';
import '../../providers/history_provider.dart';

/// Результат выбора в листе адресов.
///
/// Отдельный тип, а не голый `int?`, чтобы отличать «пользователь выбрал
/// „Без адреса“» ([sourceId] = null) от «пользователь закрыл лист, ничего не
/// выбрав» (сам результат = null). Вместе со ссылкой несёт готовый адрес:
/// вызывающему почти всегда нужен именно он, а не повторный поход в каталог.
class PlaceSelection {
  final int? sourceId;
  final MeasurementPlace place;

  const PlaceSelection({required this.sourceId, required this.place});

  /// Осознанный выбор «мерить без адреса».
  static const PlaceSelection none = PlaceSelection(sourceId: null, place: MeasurementPlace.none);
}

/// Поле выбора адреса замера на экране показаний.
///
/// Показывает весь путь — «Дача · Скважина», — потому что одного имени источника
/// мало: «Кран на кухне» есть и дома, и на даче, и в истории они стали бы
/// неотличимы.
class PlacePickerField extends ConsumerWidget {
  /// Подпись под полем, например «определено по координатам». Пусто, когда
  /// адрес выбран руками.
  final String? hint;

  const PlacePickerField({super.key, this.hint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final selectedId = ref.watch(appSettingsProvider.select((s) => s.currentSourceId));
    final catalog = ref.watch(placeCatalogViewProvider).valueOrNull;
    final place = catalog?.placeOfSourceId(selectedId);
    final note = hint;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              // Notifier берём ДО открытия листа: это ConsumerWidget, у него нет
              // `mounted`, и обращение к `ref` после await упало бы StateError'ом,
              // если экран успели закрыть, пока лист был открыт.
              final notifier = ref.read(appSettingsProvider.notifier);
              final selection = await showPlacePicker(context, initialSourceId: selectedId);
              if (selection == null) return;
              await notifier.setCurrentSource(selection.sourceId);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.place_outlined, size: 20),
                labelText: l10n.placeFieldLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              child: Text(
                place?.formatted ?? l10n.placeNotSelected,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: place != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Row(
                children: [
                  Icon(Icons.my_location, size: 13, color: theme.colorScheme.primary),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Открывает лист выбора адреса и возвращает выбор.
///
/// Сам ничего не сохраняет: экран показаний кладёт результат в настройки, а
/// детальный просмотр истории — в конкретную запись. Так один и тот же каталог
/// обслуживает оба сценария, и в истории не может появиться адрес, которого нет
/// в каталоге.
Future<PlaceSelection?> showPlacePicker(BuildContext context, {int? initialSourceId}) {
  return showModalBottomSheet<PlaceSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlacePickerSheet(initialSourceId: initialSourceId),
  );
}

class _PlacePickerSheet extends ConsumerStatefulWidget {
  final int? initialSourceId;

  const _PlacePickerSheet({required this.initialSourceId});

  @override
  ConsumerState<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends ConsumerState<_PlacePickerSheet> {
  /// Защита от повторного запуска, пока предыдущая операция в полёте: тап по
  /// пункту и подтверждение успевают сработать почти одновременно.
  bool _busy = false;

  Future<void> _select(SamplingPoint? source, PlaceCatalog catalog) async {
    if (_busy) return;
    setState(() => _busy = true);

    if (source != null) {
      // Использованный адрес поднимается в начало списка вместе со своим местом
      // и комнатой. Сбой этого шага не должен отменять сам выбор: порядок списка
      // не стоит того, чтобы отказывать пользователю в выбранном источнике.
      try {
        await ref.read(placeCatalogProvider).markSourceUsed(source.id);
      } on Object catch (_) {
        // Порядок списка — не повод беспокоить пользователя.
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(
      source == null
          ? PlaceSelection.none
          : PlaceSelection(sourceId: source.id, place: catalog.placeOf(source)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final catalogAsync = ref.watch(placeCatalogViewProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.placeFieldLabel, style: theme.textTheme.titleMedium)),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).push('/places');
                    },
                    icon: const Icon(Icons.tune, size: 18),
                    label: Text(l10n.placeConfigure),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: catalogAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (catalog) => _buildList(controller, catalog, theme, l10n),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(
    ScrollController controller,
    PlaceCatalog catalog,
    ThemeData theme,
    AppL10n l10n,
  ) {
    final selectedId = widget.initialSourceId;

    return ListView(
      controller: controller,
      children: [
        for (final site in catalog.sites) ...[
          _SiteHeader(site: site),
          for (final source in catalog.sourcesDirectlyOnSite(site.id))
            _SourceTile(
              source: source,
              selected: source.id == selectedId,
              enabled: !_busy,
              onTap: () => _select(source, catalog),
            ),
          for (final room in catalog.roomsOfSite(site.id)) ...[
            _RoomHeader(name: room.name),
            for (final source in catalog.sourcesOfRoom(room.id))
              _SourceTile(
                source: source,
                selected: source.id == selectedId,
                enabled: !_busy,
                inRoom: true,
                onTap: () => _select(source, catalog),
              ),
          ],
        ],
        const Divider(),
        ListTile(
          leading: Icon(
            selectedId == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(l10n.placeNoAddress),
          subtitle: Text(l10n.placeNoAddressSubtitle),
          onTap: _busy ? null : () => _select(null, catalog),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SiteHeader extends StatelessWidget {
  final Site site;

  const _SiteHeader({required this.site});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Город показывается только когда задан: он нужен, чтобы различить два
    // одинаково названных места, а в обычном случае это лишний шум.
    final city = site.city;
    final hasAnchor = site.latitude != null && site.longitude != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              city == null ? site.name : '${site.name} · $city',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasAnchor)
            Tooltip(
              message: AppL10n.of(context).placeBoundToCoordinates,
              child: Icon(Icons.my_location, size: 14, color: theme.colorScheme.outline),
            ),
        ],
      ),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  final String name;

  const _RoomHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 16, 2),
      child: Text(
        name,
        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final SamplingPoint source;
  final bool selected;
  final bool enabled;
  final bool inRoom;
  final VoidCallback onTap;

  const _SourceTile({
    required this.source,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.inRoom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.only(left: inRoom ? 40 : 16, right: 16),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(source.name),
      onTap: enabled ? onTap : null,
    );
  }
}
