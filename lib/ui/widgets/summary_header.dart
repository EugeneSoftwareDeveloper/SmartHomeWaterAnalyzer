import 'package:flutter/material.dart';

import '../../quality/overview.dart';
import '../../quality/zone.dart';
import '../../yinmik/reading.dart';

/// Большая «hero»-карточка вверху экрана: общая оценка качества воды, бейдж зоны,
/// иконка состояния, краткое объяснение + статус-бар прибора (батарея и HOLD).
class SummaryHeader extends StatelessWidget {
  final WaterQualityOverview overview;
  final YinmikReading reading;

  const SummaryHeader({super.key, required this.overview, required this.reading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = overview.worstCategory.color;
    final icon = _iconFor(overview.worstCategory);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.headline,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      overview.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DeviceStatusBar(reading: reading),
        ],
      ),
    );
  }

  static IconData _iconFor(QualityCategory category) {
    return switch (category) {
      QualityCategory.excellent => Icons.water_drop,
      QualityCategory.good => Icons.check_circle,
      QualityCategory.acceptable => Icons.info_outline,
      QualityCategory.caution => Icons.warning_amber,
      QualityCategory.danger => Icons.error_outline,
    };
  }
}

class _DeviceStatusBar extends StatelessWidget {
  final YinmikReading reading;

  const _DeviceStatusBar({required this.reading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = reading.batteryPercentEstimate;
    final batteryIcon = percent > 75
        ? Icons.battery_full
        : percent > 50
            ? Icons.battery_5_bar
            : percent > 25
                ? Icons.battery_3_bar
                : Icons.battery_alert;
    final batteryColor = percent > 25 ? theme.colorScheme.onSurfaceVariant : Colors.redAccent;

    return Row(
      children: [
        Icon(batteryIcon, size: 18, color: batteryColor),
        const SizedBox(width: 4),
        Text(
          '~$percent%',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: batteryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${reading.batteryRawMillivolts} мВ)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (reading.holdReadingOn) const _StatusChip(icon: Icons.lock, label: 'HOLD'),
        if (reading.holdReadingOn && reading.backlightOn) const SizedBox(width: 6),
        if (reading.backlightOn) const _StatusChip(icon: Icons.lightbulb, label: 'LIGHT'),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  // ignore: unused_element_parameter
  const _StatusChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
