import 'parameter.dart';
import 'profile.dart';
import 'zone.dart';

/// Каталог параметров качества воды. Зоны параметров зависят от выбранного профиля норм:
/// питьевая вода / бассейн / аквариум / гидропоника. Для отсутствующего варианта возвращаем
/// зоны питьевой воды по умолчанию.
abstract final class WaterParameterCatalog {
  static List<WaterParameter> forProfile(NormsProfile profile) {
    return [
      _ph(profile),
      _orp(profile),
      _ec(profile),
      _tds(profile),
      _salinity(profile),
      _temperature(profile),
      _specificGravity(profile),
    ];
  }

  static WaterParameter parameterFor(NormsProfile profile, String key) {
    return forProfile(profile).firstWhere((item) => item.key == key);
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            pH
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _ph(NormsProfile profile) {
    final zones = switch (profile) {
      NormsProfile.pool => const [
          QualityZone(min: 0, max: 6.8, category: QualityCategory.danger, label: 'Кислая'),
          QualityZone(min: 6.8, max: 7.2, category: QualityCategory.caution, label: 'Низкая'),
          QualityZone(min: 7.2, max: 7.6, category: QualityCategory.excellent, label: 'Оптимум'),
          QualityZone(min: 7.6, max: 7.8, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 7.8, max: 8.4, category: QualityCategory.caution, label: 'Высокая'),
          QualityZone(min: 8.4, max: 14, category: QualityCategory.danger, label: 'Щелочная'),
        ],
      NormsProfile.aquariumFresh => const [
          QualityZone(min: 0, max: 5.5, category: QualityCategory.danger, label: 'Кислая'),
          QualityZone(min: 5.5, max: 6.5, category: QualityCategory.caution, label: 'Низкая'),
          QualityZone(min: 6.5, max: 7.0, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 7.0, max: 7.5, category: QualityCategory.excellent, label: 'Оптимум'),
          QualityZone(min: 7.5, max: 8.2, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 8.2, max: 9.0, category: QualityCategory.caution, label: 'Высокая'),
          QualityZone(min: 9.0, max: 14, category: QualityCategory.danger, label: 'Щелочная'),
        ],
      NormsProfile.hydroponics => const [
          QualityZone(min: 0, max: 4.5, category: QualityCategory.danger, label: 'Кислая'),
          QualityZone(min: 4.5, max: 5.5, category: QualityCategory.caution, label: 'Низкая'),
          QualityZone(min: 5.5, max: 5.8, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 5.8, max: 6.5, category: QualityCategory.excellent, label: 'Оптимум'),
          QualityZone(min: 6.5, max: 7.0, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 7.0, max: 8.0, category: QualityCategory.caution, label: 'Высокая'),
          QualityZone(min: 8.0, max: 14, category: QualityCategory.danger, label: 'Щелочная'),
        ],
      NormsProfile.drinking => const [
          QualityZone(min: 0, max: 4.5, category: QualityCategory.danger, label: 'Сильно кислая'),
          QualityZone(min: 4.5, max: 6.5, category: QualityCategory.caution, label: 'Кислая'),
          QualityZone(min: 6.5, max: 7.2, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 7.2, max: 7.8, category: QualityCategory.excellent, label: 'Оптимум'),
          QualityZone(min: 7.8, max: 8.5, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 8.5, max: 10.5, category: QualityCategory.caution, label: 'Щелочная'),
          QualityZone(min: 10.5, max: 14, category: QualityCategory.danger, label: 'Сильно щелочная'),
        ],
    };

    return WaterParameter(
      key: 'ph',
      label: 'Кислотность',
      shortLabel: 'pH',
      unit: null,
      scaleMin: 0,
      scaleMax: 14,
      fractionDigits: 2,
      description: _phDescription(profile),
      zones: zones,
    );
  }

  static String _phDescription(NormsProfile profile) => switch (profile) {
        NormsProfile.drinking => 'Кислотность/щёлочность. Норма питьевой воды 6.5–8.5.',
        NormsProfile.pool => 'Кислотность бассейна. Оптимум 7.2–7.6 для эффективной дезинфекции.',
        NormsProfile.aquariumFresh =>
          'Кислотность аквариума. Большинство пресноводных рыб 6.5–7.5; уточняй по видам.',
        NormsProfile.hydroponics =>
          'Кислотность раствора. Оптимум 5.8–6.5 для усвоения большинства питательных веществ.',
      };

  // ────────────────────────────────────────────────────────────────────────────
  //                            ORP
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _orp(NormsProfile profile) {
    final zones = switch (profile) {
      NormsProfile.pool => const [
          QualityZone(min: -500, max: 600, category: QualityCategory.danger, label: 'Низкий'),
          QualityZone(min: 600, max: 650, category: QualityCategory.caution, label: 'Маловато'),
          QualityZone(min: 650, max: 750, category: QualityCategory.excellent, label: 'Оптимум'),
          QualityZone(min: 750, max: 850, category: QualityCategory.good, label: 'Высокий'),
          QualityZone(min: 850, max: 1000, category: QualityCategory.caution, label: 'Сильно высокий'),
        ],
      _ => const [
          QualityZone(min: -500, max: -100, category: QualityCategory.caution, label: 'Восстановит.'),
          QualityZone(min: -100, max: 200, category: QualityCategory.acceptable, label: 'Нейтральная'),
          QualityZone(min: 200, max: 600, category: QualityCategory.excellent, label: 'Оптимум'),
          QualityZone(min: 600, max: 800, category: QualityCategory.good, label: 'Окислит.'),
          QualityZone(min: 800, max: 1000, category: QualityCategory.caution, label: 'Сильно окислит.'),
        ],
    };

    return WaterParameter(
      key: 'orp',
      label: 'Редокс-потенциал',
      shortLabel: 'ORP',
      unit: 'мВ',
      scaleMin: -500,
      scaleMax: 1000,
      fractionDigits: 0,
      description: profile == NormsProfile.pool
          ? 'Окислительный потенциал бассейна. ВОЗ рекомендует ≥650 мВ для безопасности.'
          : 'Окислительно-восстановительный потенциал. Для питьевой воды обычно 200–600 мВ.',
      zones: zones,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            EC
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _ec(NormsProfile profile) {
    final zones = switch (profile) {
      NormsProfile.hydroponics => const [
          QualityZone(min: 0, max: 500, category: QualityCategory.caution, label: 'Слабый раствор'),
          QualityZone(min: 500, max: 1200, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 1200, max: 2000, category: QualityCategory.excellent, label: 'Оптимум'),
          QualityZone(min: 2000, max: 2500, category: QualityCategory.good, label: 'Концентрир.'),
          QualityZone(min: 2500, max: 3000, category: QualityCategory.caution, label: 'Слишком'),
        ],
      _ => const [
          QualityZone(min: 0, max: 50, category: QualityCategory.excellent, label: 'Очищенная'),
          QualityZone(min: 50, max: 500, category: QualityCategory.good, label: 'Норма'),
          QualityZone(min: 500, max: 1500, category: QualityCategory.acceptable, label: 'Приемлемо'),
          QualityZone(min: 1500, max: 2500, category: QualityCategory.caution, label: 'Высоко'),
          QualityZone(min: 2500, max: 3000, category: QualityCategory.danger, label: 'Очень высоко'),
        ],
    };

    return WaterParameter(
      key: 'ec',
      label: 'Электропроводность',
      shortLabel: 'EC',
      unit: 'µС/см',
      scaleMin: 0,
      scaleMax: 3000,
      fractionDigits: 0,
      description: profile == NormsProfile.hydroponics
          ? 'Концентрация раствора. Большинство культур 1200–2000 µС/см.'
          : 'Электропроводность. Для питьевой воды до 1500 µС/см.',
      zones: zones,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            TDS
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _tds(NormsProfile profile) {
    return WaterParameter(
      key: 'tds',
      label: 'Минерализация',
      shortLabel: 'TDS',
      unit: 'ppm',
      scaleMin: 0,
      scaleMax: 2000,
      fractionDigits: 0,
      description: switch (profile) {
        NormsProfile.drinking => 'Общая минерализация. Для питьевой воды до 1000 ppm.',
        NormsProfile.pool => 'Минерализация бассейна.',
        NormsProfile.aquariumFresh => 'Минерализация. Для большинства пресноводных рыб 80–300 ppm.',
        NormsProfile.hydroponics => 'Минерализация раствора.',
      },
      zones: const [
        QualityZone(min: 0, max: 50, category: QualityCategory.excellent, label: 'Очищенная'),
        QualityZone(min: 50, max: 300, category: QualityCategory.good, label: 'Норма'),
        QualityZone(min: 300, max: 600, category: QualityCategory.acceptable, label: 'Приемлемо'),
        QualityZone(min: 600, max: 1000, category: QualityCategory.caution, label: 'Жёсткая'),
        QualityZone(min: 1000, max: 2000, category: QualityCategory.danger, label: 'Не питьевая'),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            Salinity
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _salinity(NormsProfile profile) {
    return WaterParameter(
      key: 'salinity',
      label: 'Солёность',
      shortLabel: 'Соль',
      unit: 'ppm',
      scaleMin: 0,
      scaleMax: 2000,
      fractionDigits: 0,
      description: profile == NormsProfile.pool
          ? 'Соленость бассейна. Для соляных систем 2700–3400 ppm (вне шкалы).'
          : 'Соленость в ppm. Для пресной воды близко к нулю.',
      zones: const [
        QualityZone(min: 0, max: 100, category: QualityCategory.excellent, label: 'Пресная'),
        QualityZone(min: 100, max: 500, category: QualityCategory.good, label: 'Низко'),
        QualityZone(min: 500, max: 1000, category: QualityCategory.acceptable, label: 'Солоноватая'),
        QualityZone(min: 1000, max: 2000, category: QualityCategory.caution, label: 'Высоко'),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            Temperature
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _temperature(NormsProfile profile) {
    final zones = switch (profile) {
      NormsProfile.pool => const [
          QualityZone(min: 0, max: 20, category: QualityCategory.caution, label: 'Холодная'),
          QualityZone(min: 20, max: 25, category: QualityCategory.good, label: 'Прохладная'),
          QualityZone(min: 25, max: 30, category: QualityCategory.excellent, label: 'Комфорт'),
          QualityZone(min: 30, max: 35, category: QualityCategory.caution, label: 'Тёплая'),
          QualityZone(min: 35, max: 50, category: QualityCategory.danger, label: 'Перегрета'),
        ],
      NormsProfile.aquariumFresh => const [
          QualityZone(min: 0, max: 18, category: QualityCategory.danger, label: 'Холодно'),
          QualityZone(min: 18, max: 22, category: QualityCategory.good, label: 'Прохладно'),
          QualityZone(min: 22, max: 27, category: QualityCategory.excellent, label: 'Норма'),
          QualityZone(min: 27, max: 30, category: QualityCategory.caution, label: 'Тёпло'),
          QualityZone(min: 30, max: 50, category: QualityCategory.danger, label: 'Перегрев'),
        ],
      _ => const [
          QualityZone(min: 0, max: 5, category: QualityCategory.caution, label: 'Очень холодная'),
          QualityZone(min: 5, max: 15, category: QualityCategory.good, label: 'Холодная'),
          QualityZone(min: 15, max: 25, category: QualityCategory.excellent, label: 'Комнатная'),
          QualityZone(min: 25, max: 35, category: QualityCategory.good, label: 'Тёплая'),
          QualityZone(min: 35, max: 50, category: QualityCategory.caution, label: 'Горячая'),
        ],
    };

    return WaterParameter(
      key: 'temperature',
      label: 'Температура',
      shortLabel: 't°',
      unit: '°C',
      scaleMin: 0,
      scaleMax: 50,
      fractionDigits: 1,
      description: 'Температура воды.',
      zones: zones,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //                            S.G.
  // ────────────────────────────────────────────────────────────────────────────

  static WaterParameter _specificGravity(NormsProfile profile) {
    return const WaterParameter(
      key: 'sg',
      label: 'Плотность воды',
      shortLabel: 'S.G.',
      unit: null,
      scaleMin: 0.990,
      scaleMax: 1.040,
      fractionDigits: 3,
      description: 'Удельная плотность. Для пресной воды близко к 1.000.',
      zones: [
        QualityZone(min: 0.990, max: 0.998, category: QualityCategory.acceptable, label: 'Низкая'),
        QualityZone(min: 0.998, max: 1.005, category: QualityCategory.excellent, label: 'Норма'),
        QualityZone(min: 1.005, max: 1.020, category: QualityCategory.good, label: 'Минерализован.'),
        QualityZone(min: 1.020, max: 1.040, category: QualityCategory.caution, label: 'Очень плотная'),
      ],
    );
  }

  /// Совместимость с прежним кодом, который ожидает статический `all`. Возвращает профиль
  /// «питьевая вода» (default).
  static List<WaterParameter> get all => forProfile(NormsProfile.drinking);

  // Геттеры для совместимости с UI, которые ссылаются на конкретный параметр по точечной ссылке.
  static WaterParameter get ph => parameterFor(NormsProfile.drinking, 'ph');
  static WaterParameter get orp => parameterFor(NormsProfile.drinking, 'orp');
  static WaterParameter get electricalConductivity =>
      parameterFor(NormsProfile.drinking, 'ec');
  static WaterParameter get totalDissolvedSolids =>
      parameterFor(NormsProfile.drinking, 'tds');
  static WaterParameter get salinity => parameterFor(NormsProfile.drinking, 'salinity');
  static WaterParameter get temperature => parameterFor(NormsProfile.drinking, 'temperature');
  static WaterParameter get specificGravity => parameterFor(NormsProfile.drinking, 'sg');
}
