import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/quality/overview.dart';
import 'package:water_analyzer/quality/profile.dart';
import 'package:water_analyzer/quality/zone.dart';

void main() {
  group('WaterQualityOverview.compute', () {
    test('типичная вода в норме — worstCategory как минимум good', () {
      final overview = WaterQualityOverview.compute({
        'ph': 7.4, // оптимум
        'orp': 400, // оптимум
        'ec': 200, // good (норма)
        'tds': 100, // good (норма)
        'salinity': 50, // excellent
        'temperature': 20, // excellent (комнатная)
        'sg': 1.000, // excellent
      });

      // Хотя бы один параметр в good — суммарная оценка тоже good (худшая).
      expect(overview.isAllGood, isTrue);
      expect(overview.worstCategory.index, lessThanOrEqualTo(QualityCategory.good.index + 1),
          reason: 'Все параметры должны быть excellent или good');
      expect(overview.problematicParameters, isEmpty);
    });

    test('идеальные значения — excellent', () {
      final overview = WaterQualityOverview.compute({
        'ph': 7.4, // оптимум
        'orp': 400, // оптимум
        'ec': 30, // excellent (очищенная)
        'tds': 30, // excellent (очищенная)
        'salinity': 50, // excellent
        'temperature': 20, // excellent
        'sg': 1.000, // excellent
      });

      expect(overview.worstCategory, QualityCategory.excellent);
    });

    test('один параметр danger тянет общую оценку вниз', () {
      final overview = WaterQualityOverview.compute({
        'ph': 7.4,
        'orp': 400,
        'ec': 200,
        'tds': 1500, // danger (>1000 «не питьевая»)
        'salinity': 50,
        'temperature': 20,
        'sg': 1.000,
      });

      expect(overview.worstCategory, QualityCategory.danger);
      expect(overview.isAllGood, isFalse);
      expect(overview.problematicParameters, hasLength(1));
      expect(overview.problematicParameters.first.key, 'tds');
    });

    test('пустой ввод — overview без параметров, остаётся excellent (нет данных = ничего плохого)', () {
      final overview = WaterQualityOverview.compute({});

      expect(overview.totalParameters, 0);
      expect(overview.worstCategory, QualityCategory.excellent);
    });

    test('профиль pool: pH 7.4 — оптимум', () {
      final overview = WaterQualityOverview.compute(
        {'ph': 7.4},
        profile: NormsProfile.pool,
      );
      expect(overview.worstCategory, QualityCategory.excellent);
    });

    test('профиль pool: pH 8.5 — danger (для бассейна это уже щелочная)', () {
      final overview = WaterQualityOverview.compute(
        {'ph': 8.5},
        profile: NormsProfile.pool,
      );
      expect(overview.worstCategory, QualityCategory.danger);
    });

    test('профиль hydroponics: pH 6.0 — оптимум', () {
      final overview = WaterQualityOverview.compute(
        {'ph': 6.0},
        profile: NormsProfile.hydroponics,
      );
      expect(overview.worstCategory, QualityCategory.excellent);
    });

    test('headline и description адаптируются под worstCategory', () {
      final danger = WaterQualityOverview.compute({'ph': 3.0});
      expect(danger.headline, contains('Опасное'));
      expect(danger.description, contains('Вне нормы'));
      expect(danger.description, contains('pH'));

      final good = WaterQualityOverview.compute({'ph': 7.0});
      expect(good.headline, contains('Хорошее'));
      expect(good.description, contains('в пределах нормы'));
    });
  });
}
