import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/quality/catalog.dart';
import 'package:water_analyzer/quality/profile.dart';
import 'package:water_analyzer/quality/trend.dart';
import 'package:water_analyzer/quality/zone.dart';

/// Сравнение свежего замера с предыдущим в том же месте.
///
/// Главное, что здесь проверяется, — что «выросло» и «стало лучше» остались
/// разными вещами, и что шум электрода не выдаётся за изменение воды.
void main() {
  final ph = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'ph');

  ParameterTrend trend(double previous, double current) =>
      ParameterTrend.between(parameter: ph, previous: previous, current: current);

  group('порог различимости', () {
    test('сдвиг меньше погрешности прибора — не изменение', () {
      final result = trend(7.20, 7.25);

      expect(result.direction, TrendDirection.flat);
      expect(result.impact, TrendImpact.neutral);
      expect(result.isFlat, isTrue);
    });

    test('пересечение границы зон внутри шума не считается улучшением', () {
      // 7.19 — «норма», 7.21 — «оптимум»: формально зона сменилась на лучшую.
      // Но паспортная точность электрода ±0.1, и объявлять это улучшением —
      // выдавать дрожание за результат.
      expect(ph.zoneFor(7.19).category, QualityCategory.good);
      expect(ph.zoneFor(7.21).category, QualityCategory.excellent);

      final result = trend(7.19, 7.21);

      expect(result.direction, TrendDirection.flat);
      expect(result.impact, TrendImpact.neutral);
    });

    test('сдвиг заметно больше порога считается изменением', () {
      expect(trend(7.20, 7.35).direction, TrendDirection.up);
      expect(trend(7.20, 7.05).direction, TrendDirection.down);
    });

    test('дельта сохраняет знак и величину', () {
      expect(trend(7.0, 7.5).delta, closeTo(0.5, 1e-9));
      expect(trend(7.5, 7.0).delta, closeTo(-0.5, 1e-9));
    });
  });

  group('направление и качество — разные вещи', () {
    test('рост в лучшую зону: вверх и улучшение', () {
      final result = trend(6.9, 7.4); // «норма» → «оптимум»

      expect(result.direction, TrendDirection.up);
      expect(result.impact, TrendImpact.improved);
    });

    test('рост в худшую зону: вверх, но ухудшение', () {
      final result = trend(7.5, 8.7); // «оптимум» → «щелочная»

      expect(result.direction, TrendDirection.up);
      expect(result.impact, TrendImpact.worsened);
    });

    test('падение в лучшую зону: вниз, но улучшение', () {
      // Ради этого случая impact отделён от direction: стрелка вниз, а вода
      // стала лучше. Раскрась мы дельту по направлению — было бы наоборот.
      final result = trend(8.7, 7.5); // «щелочная» → «оптимум»

      expect(result.direction, TrendDirection.down);
      expect(result.impact, TrendImpact.improved);
    });

    test('падение в худшую зону: вниз и ухудшение', () {
      final result = trend(6.6, 6.0); // «норма» → «кислая»

      expect(result.direction, TrendDirection.down);
      expect(result.impact, TrendImpact.worsened);
    });

    test('движение внутри одной зоны направление имеет, оценки — нет', () {
      final result = trend(7.30, 7.60); // обе точки в «оптимуме»

      expect(result.direction, TrendDirection.up);
      expect(result.impact, TrendImpact.neutral);
    });
  });

  group('профиль норм влияет на оценку', () {
    test('один и тот же сдвиг может быть улучшением и ухудшением', () {
      // EC 400 → 1300 µС/см. Для питьевой воды это уход из «нормы» в «приемлемо»,
      // то есть ухудшение. Для гидропоники — наоборот, слабый раствор дорос до
      // рабочей концентрации. Числа одни, вердикт противоположный, и это ровно
      // то, ради чего профиль хранится в самом замере начиная с 1.2.0.
      final drinkingEc = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'ec');
      final hydroEc = WaterParameterCatalog.parameterFor(NormsProfile.hydroponics, 'ec');

      final drinking = ParameterTrend.between(parameter: drinkingEc, previous: 400, current: 1300);
      final hydroponics = ParameterTrend.between(parameter: hydroEc, previous: 400, current: 1300);

      expect(drinking.direction, TrendDirection.up);
      expect(hydroponics.direction, TrendDirection.up);

      expect(drinking.impact, TrendImpact.worsened);
      expect(hydroponics.impact, TrendImpact.improved);
    });

    test('зоны берутся из переданного параметра, а не из профиля по умолчанию', () {
      final poolPh = WaterParameterCatalog.parameterFor(NormsProfile.pool, 'ph');

      // pH 7.0: для питьевой воды «норма», для бассейна уже «низкая».
      expect(ph.zoneFor(7.0).category, QualityCategory.good);
      expect(poolPh.zoneFor(7.0).category, QualityCategory.caution);
    });
  });

  group('порядок категорий качества', () {
    test('rank растёт от опасного к отличному', () {
      expect(QualityCategory.danger.rank, lessThan(QualityCategory.caution.rank));
      expect(QualityCategory.caution.rank, lessThan(QualityCategory.acceptable.rank));
      expect(QualityCategory.acceptable.rank, lessThan(QualityCategory.good.rank));
      expect(QualityCategory.good.rank, lessThan(QualityCategory.excellent.rank));
    });

    test('у всех категорий rank различный', () {
      final ranks = QualityCategory.values.map((c) => c.rank).toSet();

      expect(ranks, hasLength(QualityCategory.values.length));
    });
  });

  group('пороги в каталоге', () {
    test('порог не меньше единицы вывода — иначе показали бы «+0.00»', () {
      for (final profile in NormsProfile.values) {
        for (final parameter in WaterParameterCatalog.forProfile(profile)) {
          final displayStep = math.pow(10, -parameter.fractionDigits);

          expect(
            parameter.noiseThreshold,
            greaterThanOrEqualTo(displayStep.toDouble()),
            reason:
                'у «${parameter.key}» в профиле ${profile.name} порог '
                '${parameter.noiseThreshold} мельче шага вывода $displayStep',
          );
        }
      }
    });

    test('порог задан положительным у всех параметров', () {
      for (final profile in NormsProfile.values) {
        for (final parameter in WaterParameterCatalog.forProfile(profile)) {
          expect(parameter.noiseThreshold, greaterThan(0), reason: parameter.key);
        }
      }
    });
  });

  group('формат дельты', () {
    test('положительная дельта со знаком плюс и разрядностью параметра', () {
      expect(ph.formatDelta(0.12), '+0.12');
    });

    test('отрицательная дельта с типографским минусом, а не дефисом', () {
      // В колонке цифр дефис читается как перенос, поэтому берём U+2212.
      expect(ph.formatDelta(-0.05), '−0.05');
      expect(ph.formatDelta(-0.05).startsWith('-'), isFalse);
    });

    test('разрядность берётся у параметра, а не общая', () {
      final tds = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'tds');
      final sg = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'sg');

      expect(tds.formatDelta(-12.0), '−12');
      expect(sg.formatDelta(0.0025), '+0.003');
    });
  });
}
