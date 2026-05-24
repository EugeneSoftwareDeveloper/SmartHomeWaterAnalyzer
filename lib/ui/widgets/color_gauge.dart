import 'package:flutter/material.dart';

import '../../quality/parameter.dart';

/// Горизонтальная цветная шкала с зонами качества, стрелкой-маркером текущего значения
/// и метками концов шкалы. Маркер плавно анимируется при изменении значения.
class ColorGauge extends StatelessWidget {
  final WaterParameter parameter;
  final double value;
  final double barHeight;
  final bool showScaleLabels;

  const ColorGauge({
    super.key,
    required this.parameter,
    required this.value,
    this.barHeight = 22,
    this.showScaleLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaleLabelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: barHeight + 18,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: value, end: value),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, animatedValue, _) {
              return CustomPaint(
                painter: _GaugePainter(
                  parameter: parameter,
                  value: animatedValue,
                  barHeight: barHeight,
                  borderColor: theme.colorScheme.outlineVariant,
                  markerColor: theme.colorScheme.onSurface,
                ),
              );
            },
          ),
        ),
        if (showScaleLabels)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatBoundary(parameter.scaleMin), style: scaleLabelStyle),
                Text(_formatBoundary(parameter.scaleMax), style: scaleLabelStyle),
              ],
            ),
          ),
      ],
    );
  }

  String _formatBoundary(double boundary) {
    // Округляем по разрядности параметра, чтобы pH/SG показывались дробно, а EC/TDS — целыми.
    final formatted = boundary.toStringAsFixed(parameter.fractionDigits);
    return parameter.unit == null ? formatted : '$formatted ${parameter.unit}';
  }
}

class _GaugePainter extends CustomPainter {
  final WaterParameter parameter;
  final double value;
  final double barHeight;
  final Color borderColor;
  final Color markerColor;

  _GaugePainter({
    required this.parameter,
    required this.value,
    required this.barHeight,
    required this.borderColor,
    required this.markerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const verticalPadding = 4.0;
    final barTop = verticalPadding;
    final barBottom = barTop + barHeight;
    final scaleRange = parameter.scaleMax - parameter.scaleMin;
    if (scaleRange <= 0) return;

    final fullRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, barTop, size.width, barBottom),
      const Radius.circular(6),
    );
    canvas.save();
    canvas.clipRRect(fullRect);

    // Цветные сегменты зон.
    for (final zone in parameter.zones) {
      final clampedMin = zone.min.clamp(parameter.scaleMin, parameter.scaleMax);
      final clampedMax = zone.max.clamp(parameter.scaleMin, parameter.scaleMax);
      final zoneStart = ((clampedMin - parameter.scaleMin) / scaleRange) * size.width;
      final zoneEnd = ((clampedMax - parameter.scaleMin) / scaleRange) * size.width;
      if (zoneEnd <= zoneStart) continue;

      final paint = Paint()..color = zone.color;
      canvas.drawRect(Rect.fromLTRB(zoneStart, barTop, zoneEnd, barBottom), paint);
    }
    canvas.restore();

    // Обводка.
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = borderColor;
    canvas.drawRRect(fullRect, borderPaint);

    // Маркер.
    final clampedValue = value.clamp(parameter.scaleMin, parameter.scaleMax);
    final markerX = ((clampedValue - parameter.scaleMin) / scaleRange) * size.width;

    // Тень-капля под маркером для контраста на любом цвете шкалы.
    final shadowPath = Path()
      ..moveTo(markerX, barBottom)
      ..lineTo(markerX - 8, barBottom + 11)
      ..lineTo(markerX + 8, barBottom + 11)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Стрелка.
    final markerPath = Path()
      ..moveTo(markerX, barBottom)
      ..lineTo(markerX - 7, barBottom + 10)
      ..lineTo(markerX + 7, barBottom + 10)
      ..close();
    canvas.drawPath(markerPath, Paint()..color = markerColor);

    // Вертикальная риска снизу шкалы, чтобы было видно, где именно стрелка касается полосы.
    final tickPaint = Paint()
      ..color = markerColor
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(markerX, barTop - 1),
      Offset(markerX, barBottom + 1),
      tickPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.parameter != parameter ||
      oldDelegate.barHeight != barHeight ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.markerColor != markerColor;
}
