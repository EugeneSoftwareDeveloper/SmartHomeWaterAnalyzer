import 'zone.dart';

/// Описание одного параметра качества воды: имя, единица, диапазон шкалы и нормативные зоны.
///
/// Нормы по умолчанию рассчитаны на **питьевую воду** (ГОСТ/СанПиН-ориентир). Это сознательное
/// упрощение для MVP — для бассейна/аквариума пользователю понадобится отдельный профиль норм
/// (V2). Источники: pH 6.5–8.5 (ВОЗ для drinking water), TDS до 1000 ppm, EC до 1500 µS/cm.
class WaterParameter {
  final String key;
  final String label;
  final String? unit;
  final double scaleMin;
  final double scaleMax;
  final List<QualityZone> zones;
  final int fractionDigits;
  final String? description;

  const WaterParameter({
    required this.key,
    required this.label,
    required this.unit,
    required this.scaleMin,
    required this.scaleMax,
    required this.zones,
    this.fractionDigits = 1,
    this.description,
  });

  /// Возвращает зону, в которую попадает [value]. Если значение вне диапазона шкалы —
  /// последнюю зону (на краях шкалы поведение определено).
  QualityZone zoneFor(double value) {
    for (final zone in zones) {
      if (zone.contains(value)) return zone;
    }
    // Значение за пределами всех зон — берём ближайшую крайнюю.
    return value < zones.first.min ? zones.first : zones.last;
  }

  /// Форматирует значение с учётом [fractionDigits] и единицы.
  String formatValue(double value) {
    final number = value.toStringAsFixed(fractionDigits);
    return unit == null ? number : '$number $unit';
  }
}
