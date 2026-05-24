/// Декодированный набор показаний YINMIK BLE-C600 (один кадр FF02).
///
/// Поля сопоставлены с протоколом, зафиксированным в SmartHomeService/docs/09:
/// pH, EC, TDS, соленость в ppm и %, температура, сырое напряжение батареи в mV,
/// флаги состояния, удельная плотность, ORP.
class YinmikReading {
  final double ph;
  final int electricalConductivityUsCm;
  final int totalDissolvedSolidsPpm;
  final int salinityPpm;
  final double salinityPercent;
  final double temperatureCelsius;
  final int batteryRawMillivolts;
  final int statusFlags;
  final bool backlightOn;
  final bool holdReadingOn;
  final double specificGravity;
  final int oxidationReductionPotentialMillivolts;

  const YinmikReading({
    required this.ph,
    required this.electricalConductivityUsCm,
    required this.totalDissolvedSolidsPpm,
    required this.salinityPpm,
    required this.salinityPercent,
    required this.temperatureCelsius,
    required this.batteryRawMillivolts,
    required this.statusFlags,
    required this.backlightOn,
    required this.holdReadingOn,
    required this.specificGravity,
    required this.oxidationReductionPotentialMillivolts,
  });

  /// Грубая оценка процента батареи по формуле BLE-YC01 (100 % при ~3190 mV, 0 % при ~1950 mV).
  /// Для BLE-C600 точная калибровка не подтверждена — отображаем как примерное значение.
  int get batteryPercentEstimate {
    const minMv = 1950;
    const maxMv = 3190;
    final clamped = batteryRawMillivolts.clamp(minMv, maxMv);
    return (100 * (clamped - minMv) / (maxMv - minMv)).round();
  }

  @override
  String toString() =>
      'YinmikReading(pH=$ph, EC=${electricalConductivityUsCm}uS/cm, TDS=${totalDissolvedSolidsPpm}ppm, '
      'Salinity=${salinityPpm}ppm/$salinityPercent%, Temp=$temperatureCelsius°C, '
      'Battery=${batteryRawMillivolts}mV (~$batteryPercentEstimate%), '
      'SG=$specificGravity, ORP=${oxidationReductionPotentialMillivolts}mV, '
      'backlight=$backlightOn, hold=$holdReadingOn)';
}
