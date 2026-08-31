import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/database.dart';
import '../../providers/app_settings.dart';
import '../../providers/history_provider.dart';

/// Результат выбора в листе мест.
///
/// Отдельный тип, а не голый `String?`, чтобы отличать «пользователь выбрал
/// „Без места“» ([name] = null) от «пользователь закрыл лист, ничего не выбрав»
/// (сам результат = null).
class PlaceSelection {
  final String? name;

  const PlaceSelection(this.name);
}

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
    final selected = normalizePlaceName(ref.watch(appSettingsProvider).currentLabel);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Notifier берём ДО открытия листа: это ConsumerWidget, у него нет
          // `mounted`, и обращение к `ref` после await упало бы StateError'ом,
          // если экран успели закрыть, пока лист был открыт.
          final notifier = ref.read(appSettingsProvider.notifier);
          final selection = await showPlacePicker(
            context,
            initialSelection: selected,
          );
          if (selection == null) return;
          await notifier.setCurrentLabel(selection.name);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.place_outlined, size: 20),
            labelText: 'Место замера',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(
            selected ?? 'Не выбрано',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected != null
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

/// Приводит хранимое имя места к каноничному виду: пустое и «пробельное»
/// становятся `null`.
///
/// Нужно, потому что до версии 1.2.0 место было свободным вводом, и в
/// `SharedPreferences` могла остаться строка из одних пробелов. Без нормализации
/// поле показывало бы пустоту, в списке не был бы отмечен ни один пункт, а замер
/// сохранялся бы с «пробельным» местом.
String? normalizePlaceName(String? name) {
  final trimmed = name?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

/// Открывает лист выбора места и возвращает выбор.
///
/// Сам ничего не сохраняет: экран показаний кладёт результат в настройки, а
/// детальный просмотр истории — в конкретную запись. Так один и тот же каталог
/// обслуживает оба сценария, и в истории не может появиться место, которого нет
/// в списке выбора.
Future<PlaceSelection?> showPlacePicker(
  BuildContext context, {
  String? initialSelection,
}) {
  return showModalBottomSheet<PlaceSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlacePickerSheet(
      initialSelection: normalizePlaceName(initialSelection),
    ),
  );
}

class _PlacePickerSheet extends ConsumerStatefulWidget {
  final String? initialSelection;

  const _PlacePickerSheet({required this.initialSelection});

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

    // Использованное место поднимается в начало списка — на практике человек
    // меряет две-три точки, и они должны быть под рукой. Сбой этого шага не
    // должен отменять сам выбор: порядок списка не стоит того, чтобы
    // отказывать пользователю в выбранном месте.
    if (name != null) {
      try {
        await ref.read(placesRepositoryProvider).markUsed(name);
      } on Object catch (_) {
        // Порядок списка — не повод беспокоить пользователя.
      }
    }

    if (mounted) Navigator.of(context).pop(PlaceSelection(name));
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
    try {
      await ref.read(placesRepositoryProvider).deleteById(place.id);
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
    final selected = widget.initialSelection;

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
                data: (items) {
                  // Место замера может отсутствовать в каталоге: его удалили уже
                  // после того, как замер был сохранён. Показываем его отдельной
                  // строкой, иначе в списке не был бы отмечен ни один пункт и
                  // текущее место выглядело бы потерянным.
                  final missing = selected != null &&
                          !items.any((place) => place.name == selected)
                      ? selected
                      : null;

                  return ListView(
                    controller: controller,
                    children: [
                      if (missing != null)
                        ListTile(
                          leading: Icon(
                            Icons.radio_button_checked,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(missing),
                          subtitle: const Text('Нет в списке мест'),
                          onTap: _busy ? null : () => _select(missing),
                        ),
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
                          selected == null
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
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
