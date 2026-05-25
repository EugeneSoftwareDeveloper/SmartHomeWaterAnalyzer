import '../../quality/parameter.dart';

/// Подбирает «красивый» шаг сетки для оси y графика по диапазону значений.
///
/// Логика подбора:
/// - до 20 (например, pH 0..14, salinity ‰ 0..10) → 1–5;
/// - до 200 (например, температура 0..100) → 5..40;
/// - больше (например, EC/TDS 0..3000) → шаг кратный 100.
///
/// Без этой функции `fl_chart` пытается нарисовать y-метки с шагом 1, и для
/// диапазона 0..3000 получается «лесенка из 3000 чисел» поверх друг друга.
double niceAxisInterval(double range) {
  if (range <= 20) return (range / 5).ceilToDouble().clamp(1, 5);
  if (range <= 200) return (range / 5).ceilToDouble();
  return (range / 6 / 100).ceilToDouble() * 100;
}

/// Форматирует значение на оси y под формат данного параметра.
///
/// Для параметров с большим диапазоном (EC, TDS — scaleMax ≥ 1000) применяется
/// компактная нотация: «1.5k» вместо «1500». Для остальных — десятичная запись
/// с количеством знаков из `parameter.fractionDigits`, но не больше 1 (чтобы
/// метки оси не были длиннее значения).
String formatChartAxisLabel(double value, WaterParameter parameter) {
  if (parameter.scaleMax >= 1000) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(parameter.fractionDigits.clamp(0, 1));
}
