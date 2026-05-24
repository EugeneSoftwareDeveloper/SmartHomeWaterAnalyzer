import 'zone.dart';

/// Описание одного параметра качества воды.
///
/// [label] — основное русское название (например, «Кислотность»).
/// [shortLabel] — короткая аббревиатура для шкал, бейджей, истории (например, «pH»).
/// [unit] — единица измерения или null если безразмерный.
class WaterParameter {
  final String key;
  final String label;
  final String shortLabel;
  final String? unit;
  final double scaleMin;
  final double scaleMax;
  final List<QualityZone> zones;
  final int fractionDigits;
  final String? description;

  const WaterParameter({
    required this.key,
    required this.label,
    required this.shortLabel,
    required this.unit,
    required this.scaleMin,
    required this.scaleMax,
    required this.zones,
    this.fractionDigits = 1,
    this.description,
  });

  /// Развёрнутое название с короткой аббревиатурой в скобках — для заголовков карточек:
  /// «Кислотность (pH)», «Минерализация (TDS)».
  String get displayLabel => label == shortLabel ? label : '$label ($shortLabel)';

  /// Возвращает зону, в которую попадает [value]. На границах диапазона — ближайшая крайняя зона.
  QualityZone zoneFor(double value) {
    for (final zone in zones) {
      if (zone.contains(value)) return zone;
    }
    return value < zones.first.min ? zones.first : zones.last;
  }

  String formatValue(double value) {
    final number = value.toStringAsFixed(fractionDigits);
    return unit == null ? number : '$number $unit';
  }
}
