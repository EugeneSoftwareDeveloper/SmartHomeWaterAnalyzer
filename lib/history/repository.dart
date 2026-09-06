import 'package:drift/drift.dart';

import '../location/measurement_location.dart';
import '../location/site_anchor.dart';
import '../quality/profile.dart';
import '../yinmik/reading.dart';
import 'database.dart';
import 'measurement_place.dart';
import 'place_name.dart';

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
    MeasurementPlace place = MeasurementPlace.none,
    MeasurementLocation? location,
    NormsProfile? normsProfile,
  }) {
    // Имена нормализуются тем же правилом, что и при поиске базы тренда, иначе
    // сохранённое «`Кулер`» не нашлось бы по выбранному «` Кулер `».
    // Источник по-прежнему живёт в колонке label — её смысл не изменился.
    final normalized = MeasurementPlace.normalized(
      siteName: place.siteName,
      roomName: place.roomName,
      sourceName: place.sourceName,
    );

    return _database.insertMeasurement(
      MeasurementsCompanion.insert(
        deviceId: deviceId,
        label: Value(normalized.sourceName),
        siteName: Value(normalized.siteName),
        roomName: Value(normalized.roomName),
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
        oxidationReductionPotentialMillivolts: reading.oxidationReductionPotentialMillivolts,
        batteryRawMillivolts: reading.batteryRawMillivolts,
        backlightOn: Value(reading.backlightOn),
        holdReadingOn: Value(reading.holdReadingOn),
      ),
    );
  }

  /// Изменить адрес у существующей записи. Возвращает количество затронутых
  /// строк (0 — запись не найдена).
  Future<int> updatePlace(int id, MeasurementPlace place) {
    final normalized = MeasurementPlace.normalized(
      siteName: place.siteName,
      roomName: place.roomName,
      sourceName: place.sourceName,
    );

    return _database.updateMeasurementPlace(
      id,
      siteName: normalized.siteName,
      roomName: normalized.roomName,
      sourceName: normalized.sourceName,
    );
  }

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
        oxidationReductionPotentialMillivolts: Value(m.oxidationReductionPotentialMillivolts),
        batteryRawMillivolts: Value(m.batteryRawMillivolts),
        backlightOn: Value(m.backlightOn),
        holdReadingOn: Value(m.holdReadingOn),
        latitude: Value(m.latitude),
        longitude: Value(m.longitude),
        locationAccuracyMeters: Value(m.locationAccuracyMeters),
        normsProfile: Value(m.normsProfile),
        siteName: Value(m.siteName),
        roomName: Value(m.roomName),
      ),
    );
  }

  Future<List<Measurement>> recent({String? deviceId, int limit = 200}) =>
      _database.getAllMeasurements(deviceId: deviceId, limit: limit);

  /// Предыдущий замер этого прибора в этом же месте — то, с чем экран показаний
  /// сравнивает свежее чтение. `null`, если здесь ещё не сохраняли.
  ///
  /// [legacyLabel] — плоское имя источника из версий до 1.4.0. Передаётся только
  /// для мигрировавших источников и склеивает историю через границу обновления:
  /// у старых замеров место не заполнено, и по структуре они не нашлись бы.
  Future<Measurement?> latestForPlace(
    String deviceId,
    MeasurementPlace place, {
    String? legacyLabel,
  }) {
    final normalized = MeasurementPlace.normalized(
      siteName: place.siteName,
      roomName: place.roomName,
      sourceName: place.sourceName,
    );

    return _database.latestMeasurement(
      deviceId: deviceId,
      siteName: normalized.siteName,
      roomName: normalized.roomName,
      sourceName: normalized.sourceName,
      legacyLabel: normalizePlaceName(legacyLabel),
    );
  }

  Stream<List<Measurement>> watchRecent({String? deviceId, int limit = 200}) =>
      _database.watchAllMeasurements(deviceId: deviceId, limit: limit);

  Future<void> clear({String? deviceId}) => _database.deleteAll(deviceId: deviceId);
}

/// Каталог мест, комнат и источников. Отделён от [HistoryRepository], потому что
/// это независимая сущность: каталог живёт своей жизнью и не привязан к конкретным
/// записям истории. Удаление места историю не переписывает — замер держит имена.
class PlaceCatalogRepository {
  PlaceCatalogRepository(this._database);

  final AppDatabase _database;

  // ─── Чтение ───────────────────────────────────────────────────────────────

  Stream<List<Site>> watchSites() => _database.watchSites();

  Future<List<Site>> sites() => _database.getSites();

  Stream<List<Room>> watchRooms() => _database.watchRooms();

  Future<List<Room>> rooms() => _database.getRooms();

  Stream<List<SamplingPoint>> watchSources() => _database.watchSources();

  Future<List<SamplingPoint>> sources() => _database.getSources();

  Future<SamplingPoint?> sourceById(int id) => _database.getSourceById(id);

  /// Ищет источник по плоскому имени места из версий до 1.4.0. Нужен один раз,
  /// чтобы выбранное до обновления место не потерялось.
  Future<SamplingPoint?> sourceByLegacyLabel(String label) {
    final normalized = normalizePlaceName(label);
    if (normalized == null) return Future<SamplingPoint?>.value();
    return _database.findSourceByLegacyLabel(normalized);
  }

  // ─── Создание ─────────────────────────────────────────────────────────────
  //
  // Все три метода возвращают существующую запись, если такая уже есть, а не
  // создают дубликат и не падают на уникальном индексе.

  Future<Site> addSite(String name, {String? city, DateTime? createdAt}) =>
      _database.insertOrGetSite(name, createdAt ?? DateTime.now(), city: normalizePlaceName(city));

  Future<Room> addRoom(int siteId, String name, {DateTime? createdAt}) =>
      _database.insertOrGetRoom(siteId, name, createdAt ?? DateTime.now());

  Future<SamplingPoint> addSource(int siteId, String name, {int? roomId, DateTime? createdAt}) =>
      _database.insertOrGetSource(siteId, name, createdAt ?? DateTime.now(), roomId: roomId);

  // ─── Изменение ────────────────────────────────────────────────────────────

  Future<int> renameSite(int siteId, String name, {String? city}) =>
      _database.renameSite(siteId, name, city: normalizePlaceName(city));

  Future<int> renameRoom(int roomId, String name) => _database.renameRoom(roomId, name);

  Future<int> renameSource(int sourceId, String name) => _database.renameSource(sourceId, name);

  /// Отмечает источник использованным — вместе с его комнатой и местом, чтобы
  /// свежесть поднимала всю цепочку в списке выбора.
  Future<void> markSourceUsed(int sourceId, {DateTime? usedAt}) =>
      _database.touchSource(sourceId, usedAt ?? DateTime.now());

  /// Привязывает место к координатам вручную либо сбрасывает привязку, если
  /// [anchor] равен `null`.
  Future<int> setSiteAnchor(int siteId, SiteAnchor? anchor) {
    return _database.updateSiteAnchor(
      siteId,
      latitude: anchor?.latitude,
      longitude: anchor?.longitude,
      accuracyMeters: anchor?.accuracyMeters,
      samples: anchor?.samples ?? 0,
    );
  }

  // ─── Удаление ─────────────────────────────────────────────────────────────
  //
  // История замеров не меняется: сохранённые записи держат имена в своих
  // колонках, а не ссылки на каталог.

  Future<void> deleteSite(int id) => _database.deleteSiteById(id);

  Future<void> deleteRoom(int id) => _database.deleteRoomById(id);

  Future<int> deleteSource(int id) => _database.deleteSourceById(id);
}
