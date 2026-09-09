import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/l10n/generated/app_localizations.dart';
import 'package:water_analyzer/quality/overview.dart';
import 'package:water_analyzer/quality/profile.dart';
import 'package:water_analyzer/quality/zone.dart';

/// Тексты каталога приходят из словаря, поэтому тестам нужен свой набор.
/// Русский взят намеренно: проверки сравнивают знакомые формулировки.
final l10n = lookupAppL10n(const Locale('ru'));

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
      }, l10n: l10n);

      // Хотя бы один параметр в good — суммарная оценка тоже good (худшая).
      expect(overview.isAllGood, isTrue);
      expect(
        overview.worstCategory.index,
        lessThanOrEqualTo(QualityCategory.good.index + 1),
        reason: 'Все параметры должны быть excellent или good',
      );
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
      }, l10n: l10n);

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
      }, l10n: l10n);

      expect(overview.worstCategory, QualityCategory.danger);
      expect(overview.isAllGood, isFalse);
      expect(overview.problematicParameters, hasLength(1));
      expect(overview.problematicParameters.first.key, 'tds');
    });

    test(
      'пустой ввод — overview без параметров, остаётся excellent (нет данных = ничего плохого)',
      () {
        final overview = WaterQualityOverview.compute({}, l10n: l10n);

        expect(overview.totalParameters, 0);
        expect(overview.worstCategory, QualityCategory.excellent);
      },
    );

    test('профиль pool: pH 7.4 — оптимум', () {
      final overview = WaterQualityOverview.compute(
        {'ph': 7.4},
        profile: NormsProfile.pool,
        l10n: l10n,
      );
      expect(overview.worstCategory, QualityCategory.excellent);
    });

    test('профиль pool: pH 8.5 — danger (для бассейна это уже щелочная)', () {
      final overview = WaterQualityOverview.compute(
        {'ph': 8.5},
        profile: NormsProfile.pool,
        l10n: l10n,
      );
      expect(overview.worstCategory, QualityCategory.danger);
    });

    test('профиль hydroponics: pH 6.0 — оптимум', () {
      final overview = WaterQualityOverview.compute(
        {'ph': 6.0},
        profile: NormsProfile.hydroponics,
        l10n: l10n,
      );
      expect(overview.worstCategory, QualityCategory.excellent);
    });

    test('headline и description адаптируются под worstCategory', () {
      final danger = WaterQualityOverview.compute({'ph': 3.0}, l10n: l10n);
      expect(danger.headline(l10n), contains('Опасное'));
      expect(danger.description(l10n), contains('Вне нормы'));
      expect(danger.description(l10n), contains('pH'));

      final good = WaterQualityOverview.compute({'ph': 7.0}, l10n: l10n);
      expect(good.headline(l10n), contains('Хорошее'));
      expect(good.description(l10n), contains('в пределах нормы'));
    });

    test('сводка идёт на языке интерфейса', () {
      // Оценка считается один раз, а показывается на том языке, который выбран
      // в момент показа: хранить готовую фразу внутри значило бы застрять на
      // языке, который был активен при вычислении.
      final overview = WaterQualityOverview.compute({'ph': 3.0}, l10n: l10n);
      final english = lookupAppL10n(const Locale('en'));

      expect(overview.headline(english), contains('Dangerous'));
      expect(overview.description(english), contains('Out of range'));
    });
  });
}
