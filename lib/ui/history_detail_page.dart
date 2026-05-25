import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../history/database.dart';
import '../providers/app_settings.dart';
import '../providers/history_provider.dart';
import '../quality/catalog.dart';
import '../quality/overview.dart';
import '../yinmik/reading_values.dart';
import 'widgets/parameter_card.dart';
import 'widgets/summary_header.dart';

/// Детальный просмотр одного замера из истории с возможностью свайпа влево/вправо
/// для сравнения с соседними замерами, и с меню «изменить метку / удалить замер»
/// в шапке.
class HistoryDetailPage extends ConsumerStatefulWidget {
  final List<Measurement> measurements;
  final int initialIndex;

  const HistoryDetailPage({
    super.key,
    required this.measurements,
    required this.initialIndex,
  });

  @override
  ConsumerState<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends ConsumerState<HistoryDetailPage> {
  // Локаль-нейтральный формат — не требует initializeDateFormatting и не падает на устройствах
  // без российских locale data.
  static final _timeFormat = DateFormat('dd.MM.yyyy HH:mm');

  late int _currentIndex = widget.initialIndex;
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex);

  /// Локальная копия списка — позволяет обновить метку и удалить запись «на месте»,
  /// не выходя из детального просмотра. После любого изменения мы синхронизируем
  /// `_measurements` со свежими данными из БД, чтобы PageView показывал актуальное
  /// состояние.
  late List<Measurement> _measurements = List.of(widget.measurements);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_measurements.isEmpty) {
      // Был последний замер, его удалили — закрываем экран.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    // _currentIndex мог выйти за границы после удаления.
    final clampedIndex = _currentIndex.clamp(0, _measurements.length - 1);
    final current = _measurements[clampedIndex];
    final hasLabel = current.label?.isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasLabel ? current.label! : 'Замер',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _timeFormat.format(current.observedAt),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                '${clampedIndex + 1} / ${_measurements.length}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          PopupMenuButton<_DetailAction>(
            onSelected: (action) => _onMenuAction(action, current),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _DetailAction.editLabel,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 12),
                    Text('Изменить метку'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _DetailAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 12),
                    Text('Удалить замер'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _measurements.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) =>
            _MeasurementDetailView(measurement: _measurements[index]),
      ),
    );
  }

  Future<void> _onMenuAction(_DetailAction action, Measurement current) async {
    switch (action) {
      case _DetailAction.editLabel:
        await _editLabel(current);
      case _DetailAction.delete:
        await _delete(current);
    }
  }

  Future<void> _editLabel(Measurement current) async {
    final newLabel = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => _LabelDialog(initialValue: current.label ?? ''),
    );
    // null — пользователь нажал «Отмена». Пустая строка — пользователь стёр метку.
    if (newLabel == null) return;

    final trimmed = newLabel.trim();
    final newValue = trimmed.isEmpty ? null : trimmed;
    if (newValue == current.label) return;

    final repo = ref.read(historyRepositoryProvider);
    await repo.updateLabel(current.id, newValue);

    if (!mounted) return;
    setState(() {
      _measurements = [
        for (final m in _measurements)
          if (m.id == current.id)
            current.copyWith(label: Value(newValue))
          else
            m,
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Метка обновлена')),
    );
  }

  Future<void> _delete(Measurement current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить замер?'),
        content: Text(
          'Замер от ${_timeFormat.format(current.observedAt)} будет удалён. '
          'Действие можно отменить в течение 5 секунд.',
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

    final repo = ref.read(historyRepositoryProvider);
    await repo.deleteById(current.id);
    await HapticFeedback.lightImpact();

    if (!mounted) return;
    setState(() {
      _measurements = _measurements.where((m) => m.id != current.id).toList();
      if (_currentIndex >= _measurements.length && _measurements.isNotEmpty) {
        _currentIndex = _measurements.length - 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Замер удалён'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () async {
            await repo.restoreFromMeasurement(current);
            if (!mounted) return;
            // Восстанавливаем в локальном списке. Точное место — то, где он был
            // в исходном списке (сохраняется порядок desc by observedAt).
            setState(() {
              final restored = [..._measurements, current]
                ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
              _measurements = restored;
            });
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

enum _DetailAction { editLabel, delete }

class _LabelDialog extends StatefulWidget {
  final String initialValue;

  const _LabelDialog({required this.initialValue});

  @override
  State<_LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<_LabelDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Метка замера'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Например: Москва, квартира',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _MeasurementDetailView extends ConsumerWidget {
  final Measurement measurement;

  const _MeasurementDetailView({required this.measurement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appSettingsProvider).normsProfile;
    final parameters = WaterParameterCatalog.forProfile(profile);
    final values = measurementValues(measurement);
    final overview = WaterQualityOverview.compute(values, profile: profile);
    final reading = readingFromMeasurement(measurement);

    return ListView(
      children: [
        SummaryHeader(overview: overview, reading: reading),
        for (final parameter in parameters)
          if (values[parameter.key] != null)
            ParameterCard(parameter: parameter, value: values[parameter.key]!),
        const SizedBox(height: 24),
      ],
    );
  }
}
