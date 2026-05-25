import 'package:drift/drift.dart';

import '../yinmik/reading.dart';
import 'database.dart';

/// Уровень абстракции над `AppDatabase`: принимает доменные `YinmikReading`, скрывает
/// drift-специфику. UI зависит от этого класса, а не от database.dart напрямую.
class HistoryRepository {
  HistoryRepository(this._database);

  final AppDatabase _database;

  /// Сохраняет новую запись истории. Возвращает id вставленной строки —
  /// нужен ReadingPage для последующего undo через `restoreFromMeasurement`.
  Future<int> save(
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

  /// Изменить только метку у существующей записи (например, исправить опечатку).
  /// Возвращает количество затронутых строк (0 — запись не найдена).
  Future<int> updateLabel(int id, String? label) =>
      _database.updateMeasurementLabel(id, label?.trim().isEmpty == true ? null : label);

  /// Удалить одну запись по id. Возвращает количество затронутых строк (0 — запись
  /// не найдена, 1 — успех).
  Future<int> deleteById(int id) => _database.deleteMeasurementById(id);

  /// Восстановить ранее удалённую запись с её исходным id. Используется для undo
  /// в swipe-to-delete: после удаления у пользователя 5 секунд нажать «Отменить».
  Future<int> restoreFromMeasurement(Measurement m) {
    return _database.restoreMeasurement(
      MeasurementsCompanion(
        id: Value(m.id),
        deviceId: Value(m.deviceId),
        label: Value(m.label),
        observedAt: Value(m.observedAt),
        ph: Value(m.ph),
        electricalConductivityUsCm: Value(m.electricalConductivityUsCm),
        totalDissolvedSolidsPpm: Value(m.totalDissolvedSolidsPpm),
        salinityPpm: Value(m.salinityPpm),
        salinityPercent: Value(m.salinityPercent),
        temperatureCelsius: Value(m.temperatureCelsius),
        specificGravity: Value(m.specificGravity),
        oxidationReductionPotentialMillivolts:
            Value(m.oxidationReductionPotentialMillivolts),
        batteryRawMillivolts: Value(m.batteryRawMillivolts),
        backlightOn: Value(m.backlightOn),
        holdReadingOn: Value(m.holdReadingOn),
      ),
    );
  }

  Future<List<Measurement>> recent({String? deviceId, int limit = 200}) =>
      _database.getAllMeasurements(deviceId: deviceId, limit: limit);

  Stream<List<Measurement>> watchRecent({String? deviceId, int limit = 200}) =>
      _database.watchAllMeasurements(deviceId: deviceId, limit: limit);

  Future<void> clear({String? deviceId}) => _database.deleteAll(deviceId: deviceId);
}
