import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../quality/parameter.dart';
import '../../quality/trend.dart';
import '../../quality/zone.dart';
import 'color_gauge.dart';

/// Карточка одного параметра.
///
/// Слева — крупное значение и единица измерения, справа — бейдж текущей зоны.
/// Под ними — цветная шкала с метками концов диапазона. Описание скрыто в expansion,
/// чтобы не загромождать экран, но открывается одним тапом.
class ParameterCard extends StatelessWidget {
  final WaterParameter parameter;
  final double value;

  /// Изменение относительно прошлого замера в этом же месте. `null` — сравнивать
  /// не с чем (первый замер здесь) или сравнение ещё грузится; в обоих случаях
  /// карточка просто не показывает дельту. С чем именно идёт сравнение, сказано
  /// один раз в шапке экрана, а не на каждой из семи карточек.
  final ParameterTrend? trend;

  const ParameterCard({super.key, required this.parameter, required this.value, this.trend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = parameter.zoneFor(value);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/help', extra: parameter.key),
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
                          parameter.displayLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _ValueDisplay(parameter: parameter, value: value),
                        // Дельта — отдельной строкой, а не рядом со значением:
                        // «1250 ppm» плюс «без изменений» не помещаются в одну
                        // строку рядом с бейджем зоны на узком экране.
                        if (trend != null) _TrendLine(parameter: parameter, trend: trend!),
                      ],
                    ),
                  ),
                  _ZoneBadge(zone: zone),
                  const SizedBox(width: 4),
                  Icon(Icons.help_outline, size: 18, color: theme.colorScheme.outline),
                ],
              ),
              const SizedBox(height: 14),
              ColorGauge(parameter: parameter, value: value),
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
            style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
            style: TextStyle(color: zone.color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Строка «стало / было» под значением параметра.
///
/// Цвет говорит про качество, стрелка — про направление, и это намеренно разные
/// вещи: рост pH с 6.0 до 7.0 — улучшение, с 8.0 до 9.0 — ухудшение, а стрелка
/// в обоих случаях вверх. Когда зона не сменилась, цвета нет вовсе: подкрашивать
/// колебание внутри одной зоны — значит придавать ему смысл, которого нет.
class _TrendLine extends StatelessWidget {
  final WaterParameter parameter;
  final ParameterTrend trend;

  const _TrendLine({required this.parameter, required this.trend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Палитра берётся из категорий качества, чтобы «лучше» и «хуже» на карточке
    // и на шкале были одного цвета.
    final color = switch (trend.impact) {
      TrendImpact.improved => QualityCategory.good.color,
      TrendImpact.worsened => QualityCategory.danger.color,
      TrendImpact.neutral => theme.colorScheme.onSurfaceVariant,
    };

    final (icon, text) = switch (trend.direction) {
      TrendDirection.flat => (Icons.remove, 'без изменений'),
      TrendDirection.up => (Icons.arrow_upward, parameter.formatDelta(trend.delta)),
      TrendDirection.down => (Icons.arrow_downward, parameter.formatDelta(trend.delta)),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
