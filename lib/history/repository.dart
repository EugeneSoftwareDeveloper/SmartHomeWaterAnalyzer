import 'package:drift/drift.dart';

import '../location/measurement_location.dart';
import '../quality/profile.dart';
import '../yinmik/reading.dart';
import 'database.dart';

/// Уровень абстракции над `AppDatabase`: принимает доменные `YinmikReading`, скрывает
/// drift-специфику. UI зависит от этого класса, а не от database.dart напрямую.
class HistoryRepository {
  HistoryRepository(this._database);

  final AppDatabase _database;

  /// Сохраняет новую запись истории. Возвращает id вставленной строки —
  /// нужен ReadingPage для последующего undo через `restoreFromMeasurement`.
  ///
  /// [location] необязателен: замер без геометки — валидное состояние (геометка
  /// выключена, нет разрешения, GPS не взял фикс в помещении).
  Future<int> save(
    String deviceId,
    YinmikReading reading,
    DateTime observedAt, {
    String? label,
    MeasurementLocation? location,
    NormsProfile? normsProfile,
  }) {
    final place = label?.trim();

    return _database.insertMeasurement(
      MeasurementsCompanion.insert(
        deviceId: deviceId,
        // Пустое место сохраняем как отсутствие места, а не как пустую строку:
        // иначе в истории появлялись бы записи с «пробельной» меткой, которые
        // UI показывает как названные.
        label: Value(place == null || place.isEmpty ? null : place),
        observedAt: observedAt,
        latitude: Value(location?.latitude),
        longitude: Value(location?.longitude),
        locationAccuracyMeters: Value(location?.accuracyMeters),
        normsProfile: Value(normsProfile?.name),
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
        latitude: Value(m.latitude),
        longitude: Value(m.longitude),
        locationAccuracyMeters: Value(m.locationAccuracyMeters),
        normsProfile: Value(m.normsProfile),
      ),
    );
  }

  Future<List<Measurement>> recent({String? deviceId, int limit = 200}) =>
      _database.getAllMeasurements(deviceId: deviceId, limit: limit);

  Stream<List<Measurement>> watchRecent({String? deviceId, int limit = 200}) =>
      _database.watchAllMeasurements(deviceId: deviceId, limit: limit);

  Future<void> clear({String? deviceId}) => _database.deleteAll(deviceId: deviceId);
}

/// Каталог мест замера. Отделён от [HistoryRepository], потому что это независимая
/// сущность: места живут своей жизнью и не привязаны к конкретным записям истории.
class PlacesRepository {
  PlacesRepository(this._database);

  final AppDatabase _database;

  /// Список для выбора: недавно использованные сверху, остальные по алфавиту.
  Stream<List<Place>> watchAll() => _database.watchPlaces();

  Future<List<Place>> all() => _database.getPlaces();

  /// Добавляет место или возвращает уже существующее с таким именем.
  /// Пустое имя отвергается — безымянных мест в каталоге быть не должно.
  Future<Place> add(String name, {DateTime? createdAt}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Название места не может быть пустым');
    }
    return _database.insertOrGetPlace(trimmed, createdAt ?? DateTime.now());
  }

  /// Помечает место использованным, чтобы оно поднялось в начало списка.
  /// Неизвестное имя просто игнорируется (0 затронутых строк) — например, если
  /// место удалили из каталога, но замеры с ним ещё сохраняются.
  Future<int> markUsed(String name, {DateTime? usedAt}) =>
      _database.touchPlace(name, usedAt ?? DateTime.now());

  /// Удаляет место из каталога. История замеров не меняется — сохранённые записи
  /// держат название места в своей колонке `label`.
  Future<int> deleteById(int id) => _database.deletePlaceById(id);
}
