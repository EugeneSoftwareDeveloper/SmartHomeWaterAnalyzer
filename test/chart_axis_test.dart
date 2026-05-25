import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/quality/catalog.dart';
import 'package:water_analyzer/quality/profile.dart';
import 'package:water_analyzer/ui/widgets/chart_axis.dart';

void main() {
  group('niceAxisInterval', () {
    test('узкий диапазон (pH 0..14) — шаг между 1 и 5', () {
      final interval = niceAxisInterval(14);
      expect(interval, greaterThanOrEqualTo(1));
      expect(interval, lessThanOrEqualTo(5));
    });

    test('очень узкий диапазон (salinity ‰ 0..10) — шаг не меньше 1', () {
      // Без clamp нижней границы получили бы шаг 2 (что нормально), главное — не 0.
      final interval = niceAxisInterval(10);
      expect(interval, greaterThanOrEqualTo(1));
    });

    test('средний диапазон (температура 0..100) — шаг 20', () {
      final interval = niceAxisInterval(100);
      // 100 / 5 = 20, что даёт 5 меток на оси. Это и есть «красиво».
      expect(interval, 20);
    });

    test('широкий диапазон (TDS 0..3000) — шаг кратный 100', () {
      final interval = niceAxisInterval(3000);
      expect(interval % 100, 0);
      // 3000 / 6 = 500, поэтому шаг ~500 (6 меток).
      expect(interval, greaterThanOrEqualTo(500));
      expect(interval, lessThanOrEqualTo(600));
    });

    test('шаг всегда положительный', () {
      for (final range in [1.0, 5.0, 20.0, 100.0, 500.0, 3000.0, 10000.0]) {
        expect(niceAxisInterval(range), greaterThan(0),
            reason: 'range=$range дал не-положительный шаг');
      }
    });
  });

  group('formatChartAxisLabel', () {
    test('параметр с малым диапазоном (pH) — десятичный формат', () {
      final ph = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'ph');
      expect(formatChartAxisLabel(7, ph), '7.0');
      expect(formatChartAxisLabel(8.5, ph), '8.5');
      expect(formatChartAxisLabel(0, ph), '0.0');
    });

    test('параметр с большим диапазоном (TDS) до 1000 — целое число', () {
      final tds = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'tds');
      // tds.scaleMax >= 1000, поэтому формат для значений < 1000 — целое.
      expect(formatChartAxisLabel(500, tds), '500');
      expect(formatChartAxisLabel(0, tds), '0');
    });

    test('параметр с большим диапазоном — тысячи в компактном формате', () {
      final tds = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'tds');
      expect(formatChartAxisLabel(1000, tds), '1.0k');
      expect(formatChartAxisLabel(1500, tds), '1.5k');
      expect(formatChartAxisLabel(2500, tds), '2.5k');
    });

    test('SG (плотность 0.99..1.05) — два знака после запятой ограничены 1', () {
      final sg = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'sg');
      // fractionDigits может быть >=2, но clamp(0, 1) ограничивает до 1 знака.
      final label = formatChartAxisLabel(1.02, sg);
      expect(label.split('.').last.length, lessThanOrEqualTo(1));
    });
  });
}
