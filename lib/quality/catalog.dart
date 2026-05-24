import 'parameter.dart';
import 'zone.dart';

/// Каталог параметров качества воды для MVP. Нормы рассчитаны на **питьевую воду**.
/// Зоны идут слева направо вдоль шкалы и не перекрываются. Цвета подобраны так, чтобы
/// «здоровый» центр был зелёно-синим, а края — жёлтый/красный.
abstract final class WaterParameterCatalog {
  /// pH: 6.5–8.5 норма для питьевой воды (ВОЗ). За пределами — кислая или щелочная среда.
  static const WaterParameter ph = WaterParameter(
    key: 'ph',
    label: 'pH',
    unit: null,
    scaleMin: 0,
    scaleMax: 14,
    fractionDigits: 2,
    description: 'Кислотность/щёлочность. Норма для питьевой воды 6.5–8.5.',
    zones: [
      QualityZone(min: 0, max: 4.5, category: QualityCategory.danger, label: 'Сильно кислая'),
      QualityZone(min: 4.5, max: 6.5, category: QualityCategory.caution, label: 'Кислая'),
      QualityZone(min: 6.5, max: 7.2, category: QualityCategory.good, label: 'Норма'),
      QualityZone(min: 7.2, max: 7.8, category: QualityCategory.excellent, label: 'Оптимум'),
      QualityZone(min: 7.8, max: 8.5, category: QualityCategory.good, label: 'Норма'),
      QualityZone(min: 8.5, max: 10.5, category: QualityCategory.caution, label: 'Щелочная'),
      QualityZone(min: 10.5, max: 14, category: QualityCategory.danger, label: 'Сильно щелочная'),
    ],
  );

  /// ORP (Oxidation-Reduction Potential): для питьевой воды желателен положительный
  /// потенциал. Высокие значения — окислительная среда (хлорирование), отрицательные —
  /// восстановительная (антиоксидантные свойства). Зоны — ориентир, не строгий норматив.
  static const WaterParameter orp = WaterParameter(
    key: 'orp',
    label: 'ORP',
    unit: 'мВ',
    scaleMin: -500,
    scaleMax: 1000,
    fractionDigits: 0,
    description:
        'Окислительно-восстановительный потенциал. Для питьевой воды обычно 200–600 мВ.',
    zones: [
      QualityZone(min: -500, max: -100, category: QualityCategory.caution, label: 'Восстановительная'),
      QualityZone(min: -100, max: 200, category: QualityCategory.acceptable, label: 'Нейтральная'),
      QualityZone(min: 200, max: 600, category: QualityCategory.excellent, label: 'Оптимум'),
      QualityZone(min: 600, max: 800, category: QualityCategory.good, label: 'Окислительная'),
      QualityZone(min: 800, max: 1000, category: QualityCategory.caution, label: 'Сильно окислительная'),
    ],
  );

  /// EC (Electrical Conductivity): для питьевой воды до ~1500 µS/cm.
  static const WaterParameter electricalConductivity = WaterParameter(
    key: 'ec',
    label: 'EC',
    unit: 'µС/см',
    scaleMin: 0,
    scaleMax: 3000,
    fractionDigits: 0,
    description: 'Электропроводность. Для питьевой воды до 1500 µС/см.',
    zones: [
      QualityZone(min: 0, max: 50, category: QualityCategory.excellent, label: 'Очищенная'),
      QualityZone(min: 50, max: 500, category: QualityCategory.good, label: 'Норма'),
      QualityZone(min: 500, max: 1500, category: QualityCategory.acceptable, label: 'Приемлемо'),
      QualityZone(min: 1500, max: 2500, category: QualityCategory.caution, label: 'Высоко'),
      QualityZone(min: 2500, max: 3000, category: QualityCategory.danger, label: 'Очень высоко'),
    ],
  );

  /// TDS (Total Dissolved Solids): ВОЗ рекомендует до 1000 ppm для питья.
  static const WaterParameter totalDissolvedSolids = WaterParameter(
    key: 'tds',
    label: 'TDS',
    unit: 'ppm',
    scaleMin: 0,
    scaleMax: 2000,
    fractionDigits: 0,
    description: 'Общая минерализация. Для питьевой воды до 1000 ppm.',
    zones: [
      QualityZone(min: 0, max: 50, category: QualityCategory.excellent, label: 'Очищенная'),
      QualityZone(min: 50, max: 300, category: QualityCategory.good, label: 'Норма'),
      QualityZone(min: 300, max: 600, category: QualityCategory.acceptable, label: 'Приемлемо'),
      QualityZone(min: 600, max: 1000, category: QualityCategory.caution, label: 'Жёсткая'),
      QualityZone(min: 1000, max: 2000, category: QualityCategory.danger, label: 'Не питьевая'),
    ],
  );

  /// Соленость в ppm: для пресной питьевой воды должна быть очень низкой.
  static const WaterParameter salinity = WaterParameter(
    key: 'salinity',
    label: 'Соленость',
    unit: 'ppm',
    scaleMin: 0,
    scaleMax: 2000,
    fractionDigits: 0,
    description: 'Соленость в ppm. Для пресной воды близко к нулю.',
    zones: [
      QualityZone(min: 0, max: 100, category: QualityCategory.excellent, label: 'Пресная'),
      QualityZone(min: 100, max: 500, category: QualityCategory.good, label: 'Низко'),
      QualityZone(min: 500, max: 1000, category: QualityCategory.acceptable, label: 'Солоноватая'),
      QualityZone(min: 1000, max: 2000, category: QualityCategory.caution, label: 'Высоко'),
    ],
  );

  /// Температура: комфортная для питья — комнатная (15–25 °C).
  static const WaterParameter temperature = WaterParameter(
    key: 'temperature',
    label: 'Температура',
    unit: '°C',
    scaleMin: 0,
    scaleMax: 50,
    fractionDigits: 1,
    description: 'Температура воды.',
    zones: [
      QualityZone(min: 0, max: 5, category: QualityCategory.caution, label: 'Очень холодная'),
      QualityZone(min: 5, max: 15, category: QualityCategory.good, label: 'Холодная'),
      QualityZone(min: 15, max: 25, category: QualityCategory.excellent, label: 'Комнатная'),
      QualityZone(min: 25, max: 35, category: QualityCategory.good, label: 'Тёплая'),
      QualityZone(min: 35, max: 50, category: QualityCategory.caution, label: 'Горячая'),
    ],
  );

  /// Удельная плотность (S.G.): для пресной воды близка к 1.000.
  static const WaterParameter specificGravity = WaterParameter(
    key: 'sg',
    label: 'S.G.',
    unit: null,
    scaleMin: 0.990,
    scaleMax: 1.040,
    fractionDigits: 3,
    description: 'Удельная плотность. Для пресной воды близко к 1.000.',
    zones: [
      QualityZone(min: 0.990, max: 0.998, category: QualityCategory.acceptable, label: 'Низкая'),
      QualityZone(min: 0.998, max: 1.005, category: QualityCategory.excellent, label: 'Норма'),
      QualityZone(min: 1.005, max: 1.020, category: QualityCategory.good, label: 'Минерализованная'),
      QualityZone(min: 1.020, max: 1.040, category: QualityCategory.caution, label: 'Очень плотная'),
    ],
  );

  /// Все параметры в порядке, в котором их показываем на экране.
  static const List<WaterParameter> all = [
    ph,
    orp,
    electricalConductivity,
    totalDissolvedSolids,
    salinity,
    temperature,
    specificGravity,
  ];
}
