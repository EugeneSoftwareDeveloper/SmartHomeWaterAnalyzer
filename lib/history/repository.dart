import 'package:drift/drift.dart';

import '../yinmik/reading.dart';
import 'database.dart';

/// Уровень абстракции над `AppDatabase`: принимает доменные `YinmikReading`, скрывает
/// drift-специфику. UI зависит от этого класса, а не от database.dart напрямую.
class HistoryRepository {
  HistoryRepository(this._database);

  final AppDatabase _database;

  Future<void> save(
    String deviceId,
    YinmikReading reading,
    DateTime observedAt, {
    String? label,
  }) {
    return _database.insertMeasurement(
      MeasurementsCompanion.insert(
        deviceId: deviceId,
        label: Value(label),
        observedAt: observedAt,
        ph: reading.ph,
        electricalConductivityUsCm: reading.electricalConductivityUsCm,
        totalDissolvedSolidsPpm: reading.totalDissolvedSolidsPpm,
        salinityPpm: reading.salinityPpm,
        salinityPercent: reading.salinityPercent,
        temperatureCelsius: reading.temperatureCelsius,
        specificGravity: reading.specificGravity,
        oxidationReductionPotentialMillivolts:
            reading.oxidationReductionPotentialMillivolts,
        batteryRawMillivolts: reading.batteryRawMillivolts,
        backlightOn: Value(reading.backlightOn),
        holdReadingOn: Value(reading.holdReadingOn),
      ),
    );
  }

  Future<List<Measurement>> recent({String? deviceId, int limit = 200}) =>
      _database.getAllMeasurements(deviceId: deviceId, limit: limit);

  Stream<List<Measurement>> watchRecent({String? deviceId, int limit = 200}) =>
      _database.watchAllMeasurements(deviceId: deviceId, limit: limit);

  Future<void> clear({String? deviceId}) => _database.deleteAll(deviceId: deviceId);
}
