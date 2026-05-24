import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../export/csv_export.dart';
import '../history/database.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/history_provider.dart';
import '../router.dart';

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

class _HistoryBody extends StatelessWidget {
  final List<Measurement> rows;

  const _HistoryBody({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _PhChart(rows: rows),
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Последние ${rows.length} измерений',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        for (var index = 0; index < rows.length; index++)
          _MeasurementTile(
            row: rows[index],
            onTap: () => context.push(
              '/history/detail',
              extra: HistoryDetailArgs(measurements: rows, index: index),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PhChart extends StatelessWidget {
  final List<Measurement> rows;

  const _PhChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chronological = rows.reversed.take(50).toList();
    final spots = <FlSpot>[
      for (var index = 0; index < chronological.length; index++)
        FlSpot(index.toDouble(), chronological[index].ph),
    ];

    if (spots.length < 2) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Нужно минимум 2 измерения для построения графика',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Кислотность (pH) во времени',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
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
                      reservedSize: 36,
                      interval: 1,
                      getTitlesWidget: (value, _) => Text(
                        value.toStringAsFixed(0),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                minY: 0,
                maxY: 14,
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
              ),
            ),
          ),
        ],
      ),
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
    final timeFormat = DateFormat('dd.MM HH:mm');
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
