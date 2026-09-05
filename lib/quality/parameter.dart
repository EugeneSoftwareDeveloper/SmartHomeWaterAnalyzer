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

  /// Наименьшая разница между двумя замерами, которую прибор способен различить.
  ///
  /// Берётся из паспортной погрешности BLE-C600, а не из разрядности вывода:
  /// pH печатается с двумя знаками, но точность электрода ±0.1, поэтому разницу
  /// 7.21 − 7.19 показывать как изменение — значит выдавать шум за результат.
  /// Сравнение с предыдущим замером ниже этого порога считается отсутствием
  /// изменений (см. `quality/trend.dart`).
  ///
  /// Инвариант: порог не меньше единицы вывода (10^−[fractionDigits]) — иначе
  /// в интерфейсе появилась бы дельта «+0.00». Проверяется тестом.
  final double noiseThreshold;

  const WaterParameter({
    required this.key,
    required this.label,
    required this.shortLabel,
    required this.unit,
    required this.scaleMin,
    required this.scaleMax,
    required this.zones,
    required this.noiseThreshold,
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

  /// Разница между замерами со знаком: «+0.12», «−45». Единицу не добавляет —
  /// в карточке дельта стоит рядом со значением, и повторять «ppm» дважды незачем.
  ///
  /// Минус берётся типографский (U+2212), а не дефис: в колонке цифр дефис
  /// выглядит как перенос, а не как знак числа.
  String formatDelta(double delta) {
    final number = delta.abs().toStringAsFixed(fractionDigits);
    return delta < 0 ? '−$number' : '+$number';
  }
}
