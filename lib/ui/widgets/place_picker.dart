import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/database.dart';
import '../../providers/app_settings.dart';
import '../../providers/history_provider.dart';

/// Поле выбора места замера на экране показаний.
///
/// Заменяет прежний свободный ввод: набирать «Кран на кухне» перед каждым замером
/// утомительно и порождает разнобой («кухня», «Кухня », «кран кухня»), из-за
/// которого история потом плохо фильтруется. Выбранное место хранится в
/// `AppSettings.currentLabel` и подставляется во все последующие сохранения.
class PlacePickerField extends ConsumerWidget {
  const PlacePickerField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(appSettingsProvider).currentLabel;
    final hasSelection = selected != null && selected.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showPlacePicker(context, ref),
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.place_outlined, size: 20),
            labelText: 'Место замера',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(
            hasSelection ? selected : 'Не выбрано',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasSelection
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Открывает лист выбора места. Вынесен отдельно, чтобы его можно было вызвать
/// и из других экранов (например, при смене места у сохранённого замера).
Future<void> showPlacePicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _PlacePickerSheet(),
  );
}

class _PlacePickerSheet extends ConsumerStatefulWidget {
  const _PlacePickerSheet();

  @override
  ConsumerState<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends ConsumerState<_PlacePickerSheet> {
  final _controller = TextEditingController();
  String? _error;

  /// Защита от повторного запуска, пока предыдущая операция в полёте.
  /// «Добавить» висит и на кнопке «+», и на submit с клавиатуры — они
  /// срабатывают почти одновременно, и без этого флага два параллельных
  /// добавления одного имени упирались бы в уникальный индекс.
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _select(String? name) async {
    if (_busy) return;
    setState(() => _busy = true);

    final notifier = ref.read(appSettingsProvider.notifier);
    final repository = ref.read(placesRepositoryProvider);
    try {
      await notifier.setCurrentLabel(name);

      // Использованное место поднимается в начало списка — на практике человек
      // меряет две-три точки, и они должны быть под рукой.
      if (name != null) await repository.markUsed(name);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Не удалось выбрать место: $error';
      });
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _addAndSelect() async {
    if (_busy) return;

    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Введите название места');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(placesRepositoryProvider).add(name);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Не удалось добавить место: $error';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _busy = false);
    await _select(name);
  }

  /// Удаление места подтверждается диалогом, а не откатывается через SnackBar:
  /// лист занимает бóльшую часть экрана, и SnackBar с кнопкой «Отменить»
  /// оказывался бы **под** ним — нажать его было бы физически невозможно,
  /// а удаление на деле необратимым. Диалог рисуется поверх листа.
  Future<void> _confirmDelete(Place place) async {
    if (_busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Удалить «${place.name}»?'),
        content: const Text(
          'Место исчезнет из списка выбора. Замеры, сделанные в нём, '
          'останутся в истории со своим названием.',
        ),
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
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final repository = ref.read(placesRepositoryProvider);
    final settings = ref.read(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    try {
      await repository.deleteById(place.id);

      // Если удалили выбранное место — снимаем выбор, иначе в поле осталось бы
      // название, которого больше нет в каталоге.
      if (settings.currentLabel == place.name) {
        await notifier.setCurrentLabel(null);
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Не удалось удалить место: $error';
      });
      return;
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final places = ref.watch(placesProvider);
    final selected = ref.watch(appSettingsProvider).currentLabel;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Место замера', style: theme.textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Новое место',
                        errorText: _error,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSubmitted: (_) => _addAndSelect(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    tooltip: 'Добавить место',
                    onPressed: _busy ? null : _addAndSelect,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: places.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (items) => ListView(
                  controller: controller,
                  children: [
                    for (final place in items)
                      ListTile(
                        leading: Icon(
                          place.name == selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: place.name == selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(place.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Удалить место',
                          onPressed: _busy ? null : () => _confirmDelete(place),
                        ),
                        onTap: _busy ? null : () => _select(place.name),
                      ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        selected == null || selected.isEmpty
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: const Text('Без места'),
                      subtitle: const Text('Замер сохранится без названия'),
                      onTap: _busy ? null : () => _select(null),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
