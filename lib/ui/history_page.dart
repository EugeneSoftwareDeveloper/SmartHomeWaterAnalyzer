import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../export/csv_export.dart';
import '../history/database.dart';
import '../history/grouping.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/app_settings.dart';
import '../providers/history_provider.dart';
import '../quality/catalog.dart';
import '../quality/parameter.dart';
import '../router.dart';
import '../yinmik/reading_values.dart';
import 'widgets/chart_axis.dart';

/// Экран истории измерений. Если [standalone] = true — открыт как отдельный маршрут
/// без подключённого устройства (в AppBar появляется кнопка «Назад»).
class HistoryPage extends ConsumerWidget {
  final bool standalone;

  const HistoryPage({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final async = ref.watch(recentMeasurementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          PopupMenuButton<_HistoryAction>(
            onSelected: (action) => _onMenuAction(context, ref, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _HistoryAction.exportCsv,
                child: Row(
                  children: [
                    const Icon(Icons.file_download),
                    const SizedBox(width: 12),
                    Text(l10n.historyExport),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _HistoryAction.clear,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline),
                    const SizedBox(width: 12),
                    Text(l10n.historyDeleteAll),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          if (rows.isEmpty) return _EmptyState(l10n: l10n);
          return _HistoryBody(rows: rows);
        },
      ),
    );
  }

  Future<void> _onMenuAction(
    BuildContext context,
    WidgetRef ref,
    _HistoryAction action,
  ) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case _HistoryAction.exportCsv:
        final rows = await ref.read(historyRepositoryProvider).recent(limit: 10000);
        if (rows.isEmpty) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.historyEmpty)));
          return;
        }
        final path = await CsvExporter.shareMeasurementsCsv(rows);
        messenger.showSnackBar(SnackBar(content: Text(l10n.historyExported(path))));

      case _HistoryAction.clear:
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(l10n.historyDeleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.historyDeleteAll),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          await ref.read(historyRepositoryProvider).clear();
          messenger.showSnackBar(SnackBar(content: Text(l10n.historyDeleted)));
        }
    }
  }
}

enum _HistoryAction { exportCsv, clear }

class _HistoryBody extends ConsumerWidget {
  final List<Measurement> rows;

  const _HistoryBody({required this.rows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groups = groupMeasurementsByDay(rows);

    return ListView(
      children: [
        _MeasurementChart(rows: rows),
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Последние ${rows.length} измерений',
            style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        for (final group in groups) ...[
          _DayHeader(label: group.label),
          for (final row in group.measurements)
            _DismissibleTile(
              key: ValueKey(row.id),
              row: row,
              allRows: rows,
            ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Лейбл-«разделитель» между группами замеров. Не sticky — это упростило бы виджет,
/// но потребовало бы `SliverList` вместо `ListView`. Текущий вариант — обычный
/// текстовый блок, разделяющий ленту визуально.
class _DayHeader extends StatelessWidget {
  final String label;

  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(
            Icons.event_outlined,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Карточка одного замера, обёрнутая в `Dismissible` для swipe-to-delete.
/// Удаление через swipe: запись сразу убирается из БД, в SnackBar предлагается «Отменить»
/// в течение 5 секунд — нажатие восстанавливает запись с тем же id через
/// `HistoryRepository.restoreFromMeasurement`.
class _DismissibleTile extends ConsumerWidget {
  final Measurement row;
  final List<Measurement> allRows;

  const _DismissibleTile({
    required super.key,
    required this.row,
    required this.allRows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('dismiss-${row.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.errorContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Удалить',
              style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
          ],
        ),
      ),
      onDismissed: (_) async {
        final repo = ref.read(historyRepositoryProvider);
        final messenger = ScaffoldMessenger.of(context);
        await repo.deleteById(row.id);
        await HapticFeedback.lightImpact();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Замер удалён'),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () => repo.restoreFromMeasurement(row),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      },
      child: _MeasurementTile(
        row: row,
        onTap: () {
          final index = allRows.indexWhere((m) => m.id == row.id);
          if (index < 0) return;
          context.push(
            '/history/detail',
            extra: HistoryDetailArgs(measurements: allRows, index: index),
          );
        },
      ),
    );
  }
}

/// График значений одного параметра во времени. Параметр переключается через
/// `DropdownButton` сверху — отображаются последние 50 точек включительно.
/// Диапазон y-оси — `scaleMin..scaleMax` параметра.
class _MeasurementChart extends ConsumerStatefulWidget {
  final List<Measurement> rows;

  const _MeasurementChart({required this.rows});

  @override
  ConsumerState<_MeasurementChart> createState() => _MeasurementChartState();
}

class _MeasurementChartState extends ConsumerState<_MeasurementChart> {
  String _selectedKey = 'ph';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(appSettingsProvider).normsProfile;
    final parameters = WaterParameterCatalog.forProfile(profile);
    final parameter = parameters.firstWhere(
      (p) => p.key == _selectedKey,
      orElse: () => parameters.first,
    );

    final chronological = widget.rows.reversed.take(50).toList();
    final spots = <FlSpot>[
      for (var index = 0; index < chronological.length; index++)
        FlSpot(
          index.toDouble(),
          measurementValues(chronological[index])[parameter.key] ?? 0,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${parameter.displayLabel} во времени',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownButton<String>(
                value: parameter.key,
                isDense: true,
                underline: const SizedBox.shrink(),
                items: [
                  for (final p in parameters)
                    DropdownMenuItem(
                      value: p.key,
                      child: Text(p.shortLabel),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedKey = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (spots.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Нужно минимум 2 измерения для построения графика',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LineChart(
                _buildChartData(theme, parameter, spots),
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(
    ThemeData theme,
    WaterParameter parameter,
    List<FlSpot> spots,
  ) {
    final interval = niceAxisInterval(parameter.scaleMax - parameter.scaleMin);

    return LineChartData(
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: theme.colorScheme.outlineVariant,
          strokeWidth: 0.5,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: interval,
            getTitlesWidget: (value, _) => Text(
              formatChartAxisLabel(value, parameter),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      minY: parameter.scaleMin,
      maxY: parameter.scaleMax,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: theme.colorScheme.primary,
          dotData: const FlDotData(show: false),
          barWidth: 2.5,
          belowBarData: BarAreaData(
            show: true,
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  final Measurement row;
  final VoidCallback onTap;

  const _MeasurementTile({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final hasLabel = row.label != null && row.label!.trim().isNotEmpty;

    return ListTile(
      dense: true,
      onTap: onTap,
      title: Row(
        children: [
          Text(
            'pH ${row.ph.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Text(
            '${row.temperatureCelsius.toStringAsFixed(1)}°C',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 12),
          Text(
            'ORP ${row.oxidationReductionPotentialMillivolts} мВ',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${timeFormat.format(row.observedAt)} • TDS ${row.totalDissolvedSolidsPpm} ppm • EC ${row.electricalConductivityUsCm} µС/см',
          ),
          if (hasLabel)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    row.label!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppL10n l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            l10n.historyEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
