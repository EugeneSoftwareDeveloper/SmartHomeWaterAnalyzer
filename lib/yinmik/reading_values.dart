import '../history/database.dart';
import 'reading.dart';

/// Извлекает значения параметров из доменного [YinmikReading] в формат,
/// который понимает `WaterQualityOverview.compute` и список карточек:
/// `Map<parameterKey, double>`.
///
/// Эта функция — single source of truth для маппинга «BLE-кадр → значения по ключам».
/// Если завтра добавится новый параметр (например, FC — свободный хлор), его нужно
/// дописать только здесь.
Map<String, double> readingValues(YinmikReading reading) {
  return {
    'ph': reading.ph,
    'orp': reading.oxidationReductionPotentialMillivolts.toDouble(),
    'ec': reading.electricalConductivityUsCm.toDouble(),
    'tds': reading.totalDissolvedSolidsPpm.toDouble(),
    'salinity': reading.salinityPpm.toDouble(),
    'temperature': reading.temperatureCelsius,
    'sg': reading.specificGravity,
  };
}

/// То же самое для записи из БД истории. Логика идентична — оба класса имеют одни
/// и те же поля по конструкции.
Map<String, double> measurementValues(Measurement m) {
  return {
    'ph': m.ph,
    'orp': m.oxidationReductionPotentialMillivolts.toDouble(),
    'ec': m.electricalConductivityUsCm.toDouble(),
    'tds': m.totalDissolvedSolidsPpm.toDouble(),
    'salinity': m.salinityPpm.toDouble(),
    'temperature': m.temperatureCelsius,
    'sg': m.specificGravity,
  };
}

/// Собирает доменный [YinmikReading] из записи БД, чтобы переиспользовать UI-виджеты,
/// которые ждут «свежий кадр» (`SummaryHeader`, например).
YinmikReading readingFromMeasurement(Measurement m) {
  return YinmikReading(
    ph: m.ph,
    electricalConductivityUsCm: m.electricalConductivityUsCm,
    totalDissolvedSolidsPpm: m.totalDissolvedSolidsPpm,
    salinityPpm: m.salinityPpm,
    salinityPercent: m.salinityPercent,
    temperatureCelsius: m.temperatureCelsius,
    batteryRawMillivolts: m.batteryRawMillivolts,
    statusFlags: (m.backlightOn ? 0x08 : 0) | (m.holdReadingOn ? 0x10 : 0),
    backlightOn: m.backlightOn,
    holdReadingOn: m.holdReadingOn,
    specificGravity: m.specificGravity,
    oxidationReductionPotentialMillivolts: m.oxidationReductionPotentialMillivolts,
  );
}
