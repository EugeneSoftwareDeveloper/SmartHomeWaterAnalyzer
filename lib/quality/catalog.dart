import '../l10n/generated/app_localizations.dart';
import 'parameter.dart';
import 'profile.dart';
import 'zone.dart';

/// Каталог параметров качества воды. Зоны параметров зависят от выбранного профиля норм:
/// питьевая вода / бассейн / аквариум / гидропоника. Для отсутствующего варианта возвращаем
/// зоны питьевой воды по умолчанию.
///
/// Тексты приходят снаружи, а не лежат здесь: границы зон и пороги шума одинаковы
/// для всех, а называются на разных языках по-разному. В тестах нужный набор
/// берётся через `lookupAppL10n(const Locale('ru'))` — устройство для этого
/// не требуется.
abstract final class WaterParameterCatalog {
  static List<WaterParameter> forProfile(NormsProfile profile, AppL10n l10n) {
    return [
      _ph(profile, l10n),
      _orp(profile, l10n),
      _ec(profile, l10n),
      _tds(profile, l10n),
      _salinity(profile, l10n),
      _temperature(profile, l10n),
      _specificGravity(profile, l10n),
    ];
  }

  static WaterParameter parameterFor(NormsProfile profile, String key, AppL10n l10n) {
    return forProfile(profile, l10n).firstWhere((item) => item.key == key);
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            pH
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _ph(NormsProfile profile, AppL10n l10n) {
    final zones = switch (profile) {
      NormsProfile.pool => [
        QualityZone(min: 0, max: 6.8, category: QualityCategory.danger, label: l10n.zonePhAcidic),
        QualityZone(min: 6.8, max: 7.2, category: QualityCategory.caution, label: l10n.zonePhLow),
        QualityZone(
          min: 7.2,
          max: 7.6,
          category: QualityCategory.excellent,
          label: l10n.zonePhOptimum,
        ),
        QualityZone(min: 7.6, max: 7.8, category: QualityCategory.good, label: l10n.zonePhNormal),
        QualityZone(min: 7.8, max: 8.4, category: QualityCategory.caution, label: l10n.zonePhHigh),
        QualityZone(
          min: 8.4,
          max: 14,
          category: QualityCategory.danger,
          label: l10n.zonePhAlkaline,
        ),
      ],
      NormsProfile.aquariumFresh => [
        QualityZone(min: 0, max: 5.5, category: QualityCategory.danger, label: l10n.zonePhAcidic),
        QualityZone(min: 5.5, max: 6.5, category: QualityCategory.caution, label: l10n.zonePhLow),
        QualityZone(min: 6.5, max: 7.0, category: QualityCategory.good, label: l10n.zonePhNormal),
        QualityZone(
          min: 7.0,
          max: 7.5,
          category: QualityCategory.excellent,
          label: l10n.zonePhOptimum,
        ),
        QualityZone(min: 7.5, max: 8.2, category: QualityCategory.good, label: l10n.zonePhNormal),
        QualityZone(min: 8.2, max: 9.0, category: QualityCategory.caution, label: l10n.zonePhHigh),
        QualityZone(
          min: 9.0,
          max: 14,
          category: QualityCategory.danger,
          label: l10n.zonePhAlkaline,
        ),
      ],
      NormsProfile.hydroponics => [
        QualityZone(min: 0, max: 4.5, category: QualityCategory.danger, label: l10n.zonePhAcidic),
        QualityZone(min: 4.5, max: 5.5, category: QualityCategory.caution, label: l10n.zonePhLow),
        QualityZone(min: 5.5, max: 5.8, category: QualityCategory.good, label: l10n.zonePhNormal),
        QualityZone(
          min: 5.8,
          max: 6.5,
          category: QualityCategory.excellent,
          label: l10n.zonePhOptimum,
        ),
        QualityZone(min: 6.5, max: 7.0, category: QualityCategory.good, label: l10n.zonePhNormal),
        QualityZone(min: 7.0, max: 8.0, category: QualityCategory.caution, label: l10n.zonePhHigh),
        QualityZone(
          min: 8.0,
          max: 14,
          category: QualityCategory.danger,
          label: l10n.zonePhAlkaline,
        ),
      ],
      NormsProfile.drinking => [
        QualityZone(
          min: 0,
          max: 4.5,
          category: QualityCategory.danger,
          label: l10n.zonePhStronglyAcidic,
        ),
        QualityZone(
          min: 4.5,
          max: 6.5,
          category: QualityCategory.caution,
          label: l10n.zonePhAcidic,
        ),
        QualityZone(min: 6.5, max: 7.2, category: QualityCategory.good, label: l10n.zonePhNormal),
        QualityZone(
          min: 7.2,
          max: 7.8,
          category: QualityCategory.excellent,
          label: l10n.zonePhOptimum,
        ),
        QualityZone(min: 7.8, max: 8.5, category: QualityCategory.good, label: l10n.zonePhNormal),
        QualityZone(
          min: 8.5,
          max: 10.5,
          category: QualityCategory.caution,
          label: l10n.zonePhAlkaline,
        ),
        QualityZone(
          min: 10.5,
          max: 14,
          category: QualityCategory.danger,
          label: l10n.zonePhStronglyAlkaline,
        ),
      ],
    };

    return WaterParameter(
      key: 'ph',
      label: l10n.paramPh,
      shortLabel: 'pH',
      unit: null,
      scaleMin: 0,
      scaleMax: 14,
      fractionDigits: 2,
      // ±0.1 между соседними кадрами даже в идеальной среде — см. docs/02-ble-protocol.md.
      noiseThreshold: 0.1,
      description: switch (profile) {
        NormsProfile.drinking => l10n.paramPhDescriptionDrinking,
        NormsProfile.pool => l10n.paramPhDescriptionPool,
        NormsProfile.aquariumFresh => l10n.paramPhDescriptionAquarium,
        NormsProfile.hydroponics => l10n.paramPhDescriptionHydroponics,
      },
      zones: zones,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            ORP
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _orp(NormsProfile profile, AppL10n l10n) {
    final zones = switch (profile) {
      NormsProfile.pool => [
        QualityZone(min: -500, max: 600, category: QualityCategory.danger, label: l10n.zoneOrpLow),
        QualityZone(
          min: 600,
          max: 650,
          category: QualityCategory.caution,
          label: l10n.zoneOrpSlightlyLow,
        ),
        QualityZone(
          min: 650,
          max: 750,
          category: QualityCategory.excellent,
          label: l10n.zoneOrpOptimum,
        ),
        QualityZone(min: 750, max: 850, category: QualityCategory.good, label: l10n.zoneOrpHigh),
        QualityZone(
          min: 850,
          max: 1000,
          category: QualityCategory.caution,
          label: l10n.zoneOrpVeryHigh,
        ),
      ],
      _ => [
        QualityZone(
          min: -500,
          max: -100,
          category: QualityCategory.caution,
          label: l10n.zoneOrpReducing,
        ),
        QualityZone(
          min: -100,
          max: 200,
          category: QualityCategory.acceptable,
          label: l10n.zoneOrpNeutral,
        ),
        QualityZone(
          min: 200,
          max: 600,
          category: QualityCategory.excellent,
          label: l10n.zoneOrpOptimum,
        ),
        QualityZone(
          min: 600,
          max: 800,
          category: QualityCategory.good,
          label: l10n.zoneOrpOxidizing,
        ),
        QualityZone(
          min: 800,
          max: 1000,
          category: QualityCategory.caution,
          label: l10n.zoneOrpStronglyOxidizing,
        ),
      ],
    };

    return WaterParameter(
      key: 'orp',
      label: l10n.paramOrp,
      shortLabel: 'ORP',
      unit: l10n.unitMillivolt,
      scaleMin: -500,
      scaleMax: 1000,
      fractionDigits: 0,
      // Редокс-электрод шумит единицами милливольт; 5 мВ — консервативная оценка.
      noiseThreshold: 5,
      description: profile == NormsProfile.pool
          ? l10n.paramOrpDescriptionPool
          : l10n.paramOrpDescription,
      zones: zones,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            EC
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _ec(NormsProfile profile, AppL10n l10n) {
    final zones = switch (profile) {
      NormsProfile.hydroponics => [
        QualityZone(
          min: 0,
          max: 500,
          category: QualityCategory.caution,
          label: l10n.zoneEcWeakSolution,
        ),
        QualityZone(min: 500, max: 1200, category: QualityCategory.good, label: l10n.zoneEcNormal),
        QualityZone(
          min: 1200,
          max: 2000,
          category: QualityCategory.excellent,
          label: l10n.zoneEcOptimum,
        ),
        QualityZone(
          min: 2000,
          max: 2500,
          category: QualityCategory.good,
          label: l10n.zoneEcConcentrated,
        ),
        QualityZone(
          min: 2500,
          max: 3000,
          category: QualityCategory.caution,
          label: l10n.zoneEcTooStrong,
        ),
      ],
      _ => [
        QualityZone(
          min: 0,
          max: 50,
          category: QualityCategory.excellent,
          label: l10n.zoneEcPurified,
        ),
        QualityZone(min: 50, max: 500, category: QualityCategory.good, label: l10n.zoneEcNormal),
        QualityZone(
          min: 500,
          max: 1500,
          category: QualityCategory.acceptable,
          label: l10n.zoneEcAcceptable,
        ),
        QualityZone(
          min: 1500,
          max: 2500,
          category: QualityCategory.caution,
          label: l10n.zoneEcHigh,
        ),
        QualityZone(
          min: 2500,
          max: 3000,
          category: QualityCategory.danger,
          label: l10n.zoneEcVeryHigh,
        ),
      ],
    };

    return WaterParameter(
      key: 'ec',
      label: l10n.paramEc,
      shortLabel: 'EC',
      unit: l10n.unitMicrosiemens,
      scaleMin: 0,
      scaleMax: 3000,
      fractionDigits: 0,
      // Паспортные ±2%: на водопроводных ~300–500 мкСм/см это 6–10 единиц.
      noiseThreshold: 10,
      description: profile == NormsProfile.hydroponics
          ? l10n.paramEcDescriptionHydroponics
          : l10n.paramEcDescription,
      zones: zones,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            TDS
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _tds(NormsProfile profile, AppL10n l10n) {
    return WaterParameter(
      key: 'tds',
      label: l10n.paramTds,
      shortLabel: 'TDS',
      unit: 'ppm',
      scaleMin: 0,
      scaleMax: 2000,
      fractionDigits: 0,
      // TDS считается из EC тем же трактом: ±2% от типичных 250 ppm.
      noiseThreshold: 5,
      description: switch (profile) {
        NormsProfile.drinking => l10n.paramTdsDescriptionDrinking,
        NormsProfile.pool => l10n.paramTdsDescriptionPool,
        NormsProfile.aquariumFresh => l10n.paramTdsDescriptionAquarium,
        NormsProfile.hydroponics => l10n.paramTdsDescriptionHydroponics,
      },
      zones: [
        QualityZone(
          min: 0,
          max: 50,
          category: QualityCategory.excellent,
          label: l10n.zoneTdsPurified,
        ),
        QualityZone(min: 50, max: 300, category: QualityCategory.good, label: l10n.zoneTdsNormal),
        QualityZone(
          min: 300,
          max: 600,
          category: QualityCategory.acceptable,
          label: l10n.zoneTdsAcceptable,
        ),
        QualityZone(
          min: 600,
          max: 1000,
          category: QualityCategory.caution,
          label: l10n.zoneTdsHard,
        ),
        QualityZone(
          min: 1000,
          max: 2000,
          category: QualityCategory.danger,
          label: l10n.zoneTdsNotDrinkable,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            Salinity
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _salinity(NormsProfile profile, AppL10n l10n) {
    return WaterParameter(
      key: 'salinity',
      label: l10n.paramSalinity,
      shortLabel: l10n.paramSalinityShort,
      unit: 'ppm',
      scaleMin: 0,
      scaleMax: 2000,
      fractionDigits: 0,
      // Тот же тракт, что у EC и TDS.
      noiseThreshold: 5,
      description: profile == NormsProfile.pool
          ? l10n.paramSalinityDescriptionPool
          : l10n.paramSalinityDescription,
      zones: [
        QualityZone(
          min: 0,
          max: 100,
          category: QualityCategory.excellent,
          label: l10n.zoneSalinityFresh,
        ),
        QualityZone(
          min: 100,
          max: 500,
          category: QualityCategory.good,
          label: l10n.zoneSalinityLow,
        ),
        QualityZone(
          min: 500,
          max: 1000,
          category: QualityCategory.acceptable,
          label: l10n.zoneSalinityBrackish,
        ),
        QualityZone(
          min: 1000,
          max: 2000,
          category: QualityCategory.caution,
          label: l10n.zoneSalinityHigh,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            Temperature
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _temperature(NormsProfile profile, AppL10n l10n) {
    final zones = switch (profile) {
      NormsProfile.pool => [
        QualityZone(min: 0, max: 20, category: QualityCategory.caution, label: l10n.zoneTempCold),
        QualityZone(min: 20, max: 25, category: QualityCategory.good, label: l10n.zoneTempCool),
        QualityZone(
          min: 25,
          max: 30,
          category: QualityCategory.excellent,
          label: l10n.zoneTempComfort,
        ),
        QualityZone(min: 30, max: 35, category: QualityCategory.caution, label: l10n.zoneTempWarm),
        QualityZone(
          min: 35,
          max: 50,
          category: QualityCategory.danger,
          label: l10n.zoneTempOverheated,
        ),
      ],
      NormsProfile.aquariumFresh => [
        QualityZone(
          min: 0,
          max: 18,
          category: QualityCategory.danger,
          label: l10n.zoneTempAquaCold,
        ),
        QualityZone(min: 18, max: 22, category: QualityCategory.good, label: l10n.zoneTempAquaCool),
        QualityZone(
          min: 22,
          max: 27,
          category: QualityCategory.excellent,
          label: l10n.zoneTempAquaNormal,
        ),
        QualityZone(
          min: 27,
          max: 30,
          category: QualityCategory.caution,
          label: l10n.zoneTempAquaWarm,
        ),
        QualityZone(
          min: 30,
          max: 50,
          category: QualityCategory.danger,
          label: l10n.zoneTempAquaOverheat,
        ),
      ],
      _ => [
        QualityZone(
          min: 0,
          max: 5,
          category: QualityCategory.caution,
          label: l10n.zoneTempVeryCold,
        ),
        QualityZone(min: 5, max: 15, category: QualityCategory.good, label: l10n.zoneTempCold),
        QualityZone(
          min: 15,
          max: 25,
          category: QualityCategory.excellent,
          label: l10n.zoneTempRoom,
        ),
        QualityZone(min: 25, max: 35, category: QualityCategory.good, label: l10n.zoneTempWarm),
        QualityZone(min: 35, max: 50, category: QualityCategory.caution, label: l10n.zoneTempHot),
      ],
    };

    return WaterParameter(
      key: 'temperature',
      label: l10n.paramTemperature,
      shortLabel: 't°',
      unit: '°C',
      scaleMin: 0,
      scaleMax: 50,
      fractionDigits: 1,
      // Паспортная точность термодатчика ±0.5 °C.
      noiseThreshold: 0.5,
      description: l10n.paramTemperatureDescription,
      zones: zones,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            S.G.
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _specificGravity(NormsProfile profile, AppL10n l10n) {
    return WaterParameter(
      key: 'sg',
      label: l10n.paramSg,
      shortLabel: 'S.G.',
      unit: null,
      scaleMin: 0.990,
      scaleMax: 1.040,
      fractionDigits: 3,
      // Плотность выводится с тремя знаками; меньше единицы вывода различить нечем.
      noiseThreshold: 0.001,
      description: l10n.paramSgDescription,
      zones: [
        QualityZone(
          min: 0.990,
          max: 0.998,
          category: QualityCategory.acceptable,
          label: l10n.zoneSgLow,
        ),
        QualityZone(
          min: 0.998,
          max: 1.005,
          category: QualityCategory.excellent,
          label: l10n.zoneSgNormal,
        ),
        QualityZone(
          min: 1.005,
          max: 1.020,
          category: QualityCategory.good,
          label: l10n.zoneSgMineralized,
        ),
        QualityZone(
          min: 1.020,
          max: 1.040,
          category: QualityCategory.caution,
          label: l10n.zoneSgVeryDense,
        ),
      ],
    );
  }
}
