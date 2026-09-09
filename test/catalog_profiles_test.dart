import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/l10n/generated/app_localizations.dart';
import 'package:water_analyzer/quality/catalog.dart';
import 'package:water_analyzer/quality/profile.dart';
import 'package:water_analyzer/quality/zone.dart';

/// Тексты каталога приходят из словаря, поэтому тестам нужен свой набор.
/// Русский взят намеренно: проверки сравнивают знакомые формулировки.
final l10n = lookupAppL10n(const Locale('ru'));

void main() {
  group('WaterParameterCatalog.forProfile', () {
    test('каждый профиль содержит все 7 параметров', () {
      for (final profile in NormsProfile.values) {
        final parameters = WaterParameterCatalog.forProfile(profile, l10n);
        expect(
          parameters.map((p) => p.key),
          containsAll(['ph', 'orp', 'ec', 'tds', 'salinity', 'temperature', 'sg']),
        );
      }
    });

    test('pH-зоны для бассейна оптимизированы под 7.2-7.6', () {
      final pool = WaterParameterCatalog.parameterFor(NormsProfile.pool, 'ph', l10n);
      final atOptimum = pool.zoneFor(7.4);
      expect(atOptimum.category, QualityCategory.excellent);
    });

    test('pH-зоны для гидропоники оптимизированы под 5.8-6.5', () {
      final hp = WaterParameterCatalog.parameterFor(NormsProfile.hydroponics, 'ph', l10n);
      final atOptimum = hp.zoneFor(6.0);
      expect(atOptimum.category, QualityCategory.excellent);
    });

    test('EC-зоны для гидропоники: 1500 — оптимум', () {
      final hp = WaterParameterCatalog.parameterFor(NormsProfile.hydroponics, 'ec', l10n);
      final atOptimum = hp.zoneFor(1500);
      expect(atOptimum.category, QualityCategory.excellent);
    });

    test('EC-зоны для питьевой: 1500 — это уже caution', () {
      final drinking = WaterParameterCatalog.parameterFor(NormsProfile.drinking, 'ec', l10n);
      final at1500 = drinking.zoneFor(1500);
      expect(at1500.category, QualityCategory.caution);
    });
  });
}
