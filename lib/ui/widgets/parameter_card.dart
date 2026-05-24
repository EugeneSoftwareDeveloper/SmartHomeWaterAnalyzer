import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../quality/parameter.dart';
import '../../quality/zone.dart';
import 'color_gauge.dart';

/// Карточка одного параметра.
///
/// Слева — крупное значение и единица измерения, справа — бейдж текущей зоны.
/// Под ними — цветная шкала с метками концов диапазона. Описание скрыто в expansion,
/// чтобы не загромождать экран, но открывается одним тапом.
class ParameterCard extends StatefulWidget {
  final WaterParameter parameter;
  final double value;

  const ParameterCard({
    super.key,
    required this.parameter,
    required this.value,
  });

  @override
  State<ParameterCard> createState() => _ParameterCardState();
}

class _ParameterCardState extends State<ParameterCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = widget.parameter.zoneFor(widget.value);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/help', extra: widget.parameter.key),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.parameter.displayLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _ValueDisplay(parameter: widget.parameter, value: widget.value),
                      ],
                    ),
                  ),
                  _ZoneBadge(zone: zone),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.help_outline,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ColorGauge(parameter: widget.parameter, value: widget.value),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueDisplay extends StatelessWidget {
  final WaterParameter parameter;
  final double value;

  const _ValueDisplay({required this.parameter, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final number = value.toStringAsFixed(parameter.fractionDigits);
    final unit = parameter.unit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          number,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (unit != null) ...[
          const SizedBox(width: 6),
          Text(
            unit,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ZoneBadge extends StatelessWidget {
  final QualityZone zone;

  const _ZoneBadge({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: zone.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: zone.color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: zone.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            zone.label,
            style: TextStyle(
              color: zone.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
