import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../location/measurement_location.dart';
import '../location/site_anchor.dart';
import 'catalog_seed.dart';

part 'database.g.dart';

/// Таблица сохранённых измерений. Каждая запись = один кадр FF02 с привязкой к устройству и времени.
class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// BLE-remoteId прибора, который выдал кадр.
  TextColumn get deviceId => text()();

  /// Пользовательский ярлык замера (например, «Москва, квартира»). Необязательно.
  TextColumn get label => text().nullable()();

  DateTimeColumn get observedAt => dateTime()();

  RealColumn get ph => real()();
  IntColumn get electricalConductivityUsCm => integer()();
  IntColumn get totalDissolvedSolidsPpm => integer()();
  IntColumn get salinityPpm => integer()();
  RealColumn get salinityPercent => real()();
  RealColumn get temperatureCelsius => real()();
  RealColumn get specificGravity => real()();
  IntColumn get oxidationReductionPotentialMillivolts => integer()();
  IntColumn get batteryRawMillivolts => integer()();
  BoolColumn get backlightOn => boolean().withDefault(const Constant(false))();
  BoolColumn get holdReadingOn => boolean().withDefault(const Constant(false))();

  /// Геометка замера — где физически находился телефон в момент сохранения.
  /// Nullable по трём причинам: пользователь мог выключить геометку в настройках,
  /// отказать в разрешении, или GPS не успел взять фикс (в помещении это норма).
  /// Отсутствие координат никогда не мешает сохранить замер.
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  /// Радиус погрешности в метрах, как его сообщил геолокатор. Нужен, чтобы
  /// в UI не показывать «точку на карте» там, где на самом деле известен только
  /// район (по сети это сотни метров).
  RealColumn get locationAccuracyMeters => real().nullable()();

  /// Профиль норм, по которому замер оценивался в момент сохранения (имя
  /// значения `NormsProfile`).
  ///
  /// Хранится в самой записи, потому что «опасно / норма» — свойство замера, а
  /// не текущей настройки приложения. Без этого замер в бассейне, просмотренный
  /// после переключения профиля на питьевую воду, задним числом краснел бы.
  ///
  /// Nullable: у записей, сделанных до версии 1.2.0, профиль неизвестен — для
  /// них UI берёт текущий из настроек, то есть ведёт себя как раньше.
  TextColumn get normsProfile => text().nullable()();

  /// Имя места (дом, дача, квартира), где сделан замер.
  ///
  /// Nullable по двум причинам сразу: у записей до версии 1.4.0 иерархии не было
  /// вовсе, и `null` здесь — признак «доиерархической» записи, по которому
  /// поиск базы тренда узнаёт старые замеры. Кроме того, замер можно сохранить
  /// вообще без выбранного источника.
  ///
  /// Как и [label], хранит **имя**, а не ссылку: переименование места не должно
  /// переписывать историю задним числом.
  TextColumn get siteName => text().nullable()();

  /// Имя комнаты внутри места. `null` — источник висит прямо на месте
  /// («Дача · Скважина»), это штатная ситуация, а не отсутствие данных:
  /// комната — необязательный уровень.
  TextColumn get roomName => text().nullable()();
}

/// Место замера — дом, дача, квартира. Верхний уровень иерархии и **единственный,
/// который вообще можно определить по координатам**: GPS отличает дачу от квартиры,
/// но не кухню от ванной, где разница в метры при точности в десятки.
///
/// Каталог хранится отдельно от [Measurements] сознательно: замер держит **имена**
/// места, комнаты и источника, а не ссылки на строки каталога. Так переименование
/// или удаление не переписывает историю задним числом.
class Sites extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Название места. Уникально — два «Дома» в списке выбора бессмысленны.
  TextColumn get name => text().unique()();

  /// Город. Нужен, чтобы различать одинаково названные места («Дом» в двух
  /// городах) в списке выбора; на логику не влияет.
  TextColumn get city => text().nullable()();

  /// Якорь привязки — точка, к которой место считается «рядом».
  ///
  /// Nullable: место без якоря просто не участвует в автовыборе. Якорь
  /// появляется либо из первого сохранённого здесь замера, либо вручную.
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  /// Точность якоря в метрах — взвешенная по вкладам фиксов, из которых он
  /// сложился. Хранится, чтобы новые фиксы уточняли якорь тем сильнее, чем они
  /// точнее: фикс по сети с погрешностью 500 м не должен сдвигать якорь так же,
  /// как фикс по спутникам с погрешностью 5 м.
  RealColumn get anchorAccuracyMeters => real().nullable()();

  /// Сколько фиксов уже вошло в якорь. Ноль означает «якоря нет».
  IntColumn get anchorSamples => integer().withDefault(const Constant(0))();

  /// Радиус, в пределах которого координаты считаются принадлежащими этому месту.
  /// Дефолт покрывает участок с постройками и типичную городскую погрешность.
  RealColumn get radiusMeters => real().withDefault(const Constant(150))();

  DateTimeColumn get createdAt => dateTime()();

  /// Когда местом пользовались в последний раз — недавние поднимаются в начало.
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
}

/// Комната внутри места — необязательный средний уровень.
///
/// Существует отдельной таблицей, а не строковым полем источника, чтобы комнату
/// можно было переименовать один раз, а не в каждом источнике по отдельности,
/// и чтобы список выбора группировался по реальной сущности.
class Rooms extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get siteId => integer().references(Sites, #id)();

  TextColumn get name => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  /// Одинаковые имена комнат в разных местах допустимы — «Кухня» есть и дома,
  /// и на даче. Уникальность только внутри одного места.
  @override
  List<Set<Column>> get uniqueKeys => [
    {siteId, name},
  ];
}

/// Источник воды — то, что реально измеряют: кран, фильтр, скважина, аквариум.
///
/// [roomId] необязателен: источник может висеть прямо на месте («Дача · Скважина»).
/// [siteId] дублируется сюда из комнаты намеренно — иначе источник без комнаты
/// не имел бы связи с местом, и каждый запрос уходил бы в join через `rooms`.
class SamplingPoints extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get siteId => integer().references(Sites, #id)();

  IntColumn get roomId => integer().nullable().references(Rooms, #id)();

  TextColumn get name => text()();

  /// Плоское имя места из версий до 1.4.0, из которого этот источник мигрировал.
  ///
  /// Нужно ровно для одного: у замеров до обновления `siteName` пустой, и поиск
  /// базы тренда должен узнавать их по старому имени. Только для мигрировавших
  /// источников — иначе созданный вручную «Дача · Фильтр» унаследовал бы историю
  /// доиерархического «Фильтра», сделанного на самом деле дома.
  TextColumn get legacyLabel => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  // Уникальность имени внутри места задаётся ЧАСТИЧНЫМИ индексами в миграции,
  // а не здесь: в SQLite NULL'ы в составном UNIQUE считаются различными, поэтому
  // `{siteId, roomId, name}` пропустил бы два одинаковых источника без комнаты.
}

@DriftDatabase(tables: [Measurements, Sites, Rooms, SamplingPoints])
class AppDatabase extends _$AppDatabase {
  /// Имена первого места и стартовых источников. Приходят снаружи, потому что
  /// это данные на языке пользователя, а не подписи интерфейса — подробности в
  /// [CatalogSeed].
  final CatalogSeed seed;

  AppDatabase(this.seed) : super(_openConnection());

  /// Конструктор для unit-тестов: позволяет передать произвольный `QueryExecutor`,
  /// обычно `NativeDatabase.memory()` для in-memory SQLite. Production-код использует
  /// дефолтный конструктор с файловой БД в documents-directory.
  AppDatabase.forTesting(super.executor, this.seed);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createSamplingPointIndexes();
      // Свежая установка: сразу даём место «Дом» с готовым набором источников,
      // чтобы первый замер можно было подписать, ничего не придумывая.
      await _seedDefaultCatalog();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v2: добавляем колонку label для пользовательских меток замеров.
        await m.addColumn(measurements, measurements.label);
      }
      if (from < 3) {
        // v3: геометка замера. Все три колонки nullable — существующие записи
        // остаются без координат, это валидное состояние.
        await m.addColumn(measurements, measurements.latitude);
        await m.addColumn(measurements, measurements.longitude);
        await m.addColumn(measurements, measurements.locationAccuracyMeters);
      }
      if (from < 4) {
        // v4: плоский каталог мест. Выражен сырым SQL, а не drift-таблицей,
        // потому что в версии 6 эта таблица удаляется и из схемы приложения
        // ушла. Миграция обязана уметь пройти путь пользователя целиком, даже
        // если структуры, которую она создаёт, в текущем коде уже нет.
        await _createLegacyPlacesTable();
        // Импорт идёт ПЕРЕД сидированием, и это важно. Обе вставки —
        // INSERT OR IGNORE, поэтому выигрывает пришедшая первой. Метка
        // пользователя несёт last_used_at (время его последнего замера), а
        // дефолт — нет; при обратном порядке «Аквариум» был бы отброшен как
        // дубликат уже вставленного дефолта, потерял бы время использования
        // и уехал в конец списка ниже мест, которыми никогда не пользовались.
        await _importLegacyPlacesFromLabels();
        await _seedLegacyPlaces();
      }
      if (from < 5) {
        // v5: профиль норм, по которому оценивался замер. Старые записи
        // остаются с null — для них UI берёт текущий профиль из настроек,
        // то есть ведёт себя ровно как до обновления.
        await m.addColumn(measurements, measurements.normsProfile);
      }
      if (from < 6) {
        // v6: иерархия «место → комната → источник» вместо плоского списка.
        await m.createTable(sites);
        await m.createTable(rooms);
        await m.createTable(samplingPoints);
        await _createSamplingPointIndexes();

        // Колонки замера хранят ИМЕНА, а не ссылки, — тот же инвариант, что и
        // у label. Старые записи остаются с null в обеих, и это их признак:
        // по нему поиск базы тренда узнаёт доиерархические замеры.
        await m.addColumn(measurements, measurements.siteName);
        await m.addColumn(measurements, measurements.roomName);

        await _migrateLegacyPlacesIntoHierarchy();
      }
    },
  );

  /// Частичные индексы уникальности источника внутри места.
  ///
  /// Два отдельных индекса, а не один составной `UNIQUE(site_id, room_id, name)`:
  /// в SQLite NULL'ы в уникальном ключе считаются различными, поэтому составной
  /// индекс пропустил бы две «Скважины» без комнаты под одним местом.
  Future<void> _createSamplingPointIndexes() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS ux_sampling_points_room '
      'ON sampling_points (site_id, room_id, name) WHERE room_id IS NOT NULL',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS ux_sampling_points_site '
      'ON sampling_points (site_id, name) WHERE room_id IS NULL',
    );
  }

  /// Свежая установка: место «Дом» и готовый набор источников в нём.
  Future<void> _seedDefaultCatalog() async {
    final now = DateTime.now();
    final siteId = await into(sites).insert(
      SitesCompanion.insert(name: seed.siteName, createdAt: now),
      mode: InsertMode.insertOrIgnore,
    );

    await batch((batch) {
      batch.insertAll(samplingPoints, [
        for (final name in seed.sourceNames)
          SamplingPointsCompanion.insert(siteId: siteId, name: name, createdAt: now),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  // ─── Наследие версий 4–5: плоская таблица `places` ────────────────────────
  // Всё ниже существует только ради прохождения миграции со старых версий.
  // В работающем приложении этой таблицы нет.

  Future<void> _createLegacyPlacesTable() async {
    await customStatement(
      'CREATE TABLE IF NOT EXISTS places ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL UNIQUE, '
      'created_at INTEGER NOT NULL, '
      'last_used_at INTEGER NULL)',
    );
  }

  /// Переносит уже использованные метки замеров в плоский каталог.
  ///
  /// `GROUP BY TRIM(label)` схлопывает «Дача» и «Дача » в одно место, а
  /// `MAX(observed_at)` отдаёт схлопнутому месту самое свежее время
  /// использования — иначе оно унаследовало бы время случайно первой метки.
  Future<void> _importLegacyPlacesFromLabels() async {
    await customStatement(
      'INSERT OR IGNORE INTO places (name, created_at, last_used_at) '
      'SELECT TRIM(label), ?, MAX(observed_at) FROM measurements '
      "WHERE label IS NOT NULL AND TRIM(label) <> '' "
      'GROUP BY TRIM(label)',
      [DateTime.now().millisecondsSinceEpoch ~/ 1000],
    );
  }

  Future<void> _seedLegacyPlaces() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final name in seed.sourceNames) {
      await customStatement('INSERT OR IGNORE INTO places (name, created_at) VALUES (?, ?)', [
        name,
        now,
      ]);
    }
  }

  /// Переносит плоские места в иерархию и удаляет старую таблицу.
  ///
  /// Все места становятся источниками без комнаты под местом «Дом»: разложить их
  /// по комнатам автоматически нельзя — «Кран на кухне» выглядит как комната плюс
  /// источник, а «Скважина» и «Бутилированная» не про комнаты вовсе, и угадывание
  /// дало бы мусор, который пользователю пришлось бы разбирать руками.
  ///
  /// `legacy_label` сохраняет исходное плоское имя: по нему замеры до обновления
  /// продолжают находиться как база тренда.
  Future<void> _migrateLegacyPlacesIntoHierarchy() async {
    final now = DateTime.now();
    final siteId = await into(sites).insert(
      SitesCompanion.insert(name: seed.siteName, createdAt: now),
      mode: InsertMode.insertOrIgnore,
    );

    await customStatement(
      'INSERT OR IGNORE INTO sampling_points '
      '(site_id, room_id, name, legacy_label, created_at, last_used_at) '
      'SELECT ?, NULL, name, name, created_at, last_used_at FROM places',
      [siteId],
    );

    // Два каталога одновременно — ровно та путаница, которую убираем.
    await customStatement('DROP TABLE IF EXISTS places');

    await _seedAnchorFromHistory(siteId);
  }

  /// Пробует привязать «Дом» к координатам уже накопленных замеров.
  ///
  /// Это подарок пользователю с историей: автовыбор начинает работать сразу
  /// после обновления, а не после первого нового замера. Но только если фиксы
  /// плотно кучкуются — решение принимает [anchorFromFixes]. Если человек мерил
  /// и дома, и на даче, якорь останется пустым: неверная привязка хуже, чем её
  /// отсутствие, потому что молча подставляет не то место.
  Future<void> _seedAnchorFromHistory(int siteId) async {
    final rows = await (select(
      measurements,
    )..where((t) => t.latitude.isNotNull() & t.longitude.isNotNull())).get();

    final fixes = <MeasurementLocation>[
      for (final row in rows)
        ?MeasurementLocation.fromNullable(
          row.latitude,
          row.longitude,
          accuracyMeters: row.locationAccuracyMeters,
        ),
    ];

    final anchor = anchorFromFixes(fixes);
    if (anchor == null) return;

    await updateSiteAnchor(
      siteId,
      latitude: anchor.latitude,
      longitude: anchor.longitude,
      accuracyMeters: anchor.accuracyMeters,
      samples: anchor.samples,
    );
  }

  // ─── Каталог: места, комнаты, источники ───────────────────────────────────
  //
  // Везде один порядок сортировки: сначала недавно использованные, затем
  // остальные по алфавиту. В SQLite NULL меньше любого значения, поэтому при
  // DESC никогда не использованные записи естественным образом уходят в хвост.

  Stream<List<Site>> watchSites() => _sitesQuery().watch();

  Future<List<Site>> getSites() => _sitesQuery().get();

  SimpleSelectStatement<$SitesTable, Site> _sitesQuery() {
    return select(sites)
      ..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt), (t) => OrderingTerm.asc(t.name)]);
  }

  Stream<List<Room>> watchRooms() => _roomsQuery().watch();

  Future<List<Room>> getRooms() => _roomsQuery().get();

  SimpleSelectStatement<$RoomsTable, Room> _roomsQuery() {
    return select(rooms)
      ..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt), (t) => OrderingTerm.asc(t.name)]);
  }

  Stream<List<SamplingPoint>> watchSources() => _sourcesQuery().watch();

  Future<List<SamplingPoint>> getSources() => _sourcesQuery().get();

  SimpleSelectStatement<$SamplingPointsTable, SamplingPoint> _sourcesQuery() {
    return select(samplingPoints)
      ..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt), (t) => OrderingTerm.asc(t.name)]);
  }

  Future<SamplingPoint?> getSourceById(int id) =>
      (select(samplingPoints)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Ищет источник по плоскому имени из версий до 1.4.0. Нужен один раз при
  /// первом запуске после обновления, чтобы выбранное ранее место не потерялось.
  Future<SamplingPoint?> findSourceByLegacyLabel(String label) {
    return (select(
      samplingPoints,
    )..where((t) => t.legacyLabel.equals(label.trim()))).getSingleOrNull();
  }

  /// Добавляет место или возвращает существующее с тем же именем.
  ///
  /// Везде в каталоге вставка идёт через `insertOrIgnore` с последующим
  /// чтением, а не «сначала проверить, потом вставить»: между проверкой и
  /// вставкой есть окно, в которое успевает пролезть второй вызов (кнопка «+»
  /// и submit с клавиатуры срабатывают почти одновременно), и БД отвечает
  /// `UNIQUE constraint failed`.
  Future<Site> insertOrGetSite(String name, DateTime createdAt, {String? city}) async {
    final trimmed = _requireName(name, 'site');

    await into(sites).insert(
      SitesCompanion.insert(name: trimmed, createdAt: createdAt, city: Value(city)),
      mode: InsertMode.insertOrIgnore,
    );

    return (select(sites)..where((t) => t.name.equals(trimmed))).getSingle();
  }

  Future<Room> insertOrGetRoom(int siteId, String name, DateTime createdAt) async {
    final trimmed = _requireName(name, 'room');

    await into(rooms).insert(
      RoomsCompanion.insert(siteId: siteId, name: trimmed, createdAt: createdAt),
      mode: InsertMode.insertOrIgnore,
    );

    return (select(
      rooms,
    )..where((t) => t.siteId.equals(siteId) & t.name.equals(trimmed))).getSingle();
  }

  /// Добавляет источник или возвращает существующий с тем же именем в том же
  /// месте и той же комнате. [roomId] = null означает источник прямо на месте.
  Future<SamplingPoint> insertOrGetSource(
    int siteId,
    String name,
    DateTime createdAt, {
    int? roomId,
  }) async {
    final trimmed = _requireName(name, 'source');

    await into(samplingPoints).insert(
      SamplingPointsCompanion.insert(
        siteId: siteId,
        name: trimmed,
        createdAt: createdAt,
        roomId: Value(roomId),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    // `roomId IS NULL` отдельной веткой: в SQL сравнение с NULL не истинно
    // никогда, и источник без комнаты иначе не нашёлся бы после вставки.
    final query = select(samplingPoints)
      ..where((t) => t.siteId.equals(siteId) & t.name.equals(trimmed));
    if (roomId == null) {
      query.where((t) => t.roomId.isNull());
    } else {
      query.where((t) => t.roomId.equals(roomId));
    }

    return query.getSingle();
  }

  static String _requireName(String name, String what) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      // Без этой проверки пустое имя молча создавало бы безымянную запись:
      // пустая строка проходит в TEXT NOT NULL и занимает уникальный индекс.
      // Сообщение английское и не переводится: пустое имя до базы не
      // доходит — UI отсекает его раньше, — и увидеть эту ошибку может только
      // тот, кто читает стектрейс.
      throw ArgumentError.value(name, 'name', 'A $what name must not be empty');
    }
    return trimmed;
  }

  /// Отмечает источник использованным — вместе с его комнатой и местом.
  ///
  /// Поднимается вся цепочка, а не только источник: список выбора сортирует по
  /// свежести на каждом уровне, и место, где только что мерили, должно быть
  /// сверху так же, как источник внутри него.
  Future<void> touchSource(int sourceId, DateTime usedAt) async {
    final source = await getSourceById(sourceId);
    if (source == null) return;

    await transaction(() async {
      await (update(samplingPoints)..where((t) => t.id.equals(sourceId))).write(
        SamplingPointsCompanion(lastUsedAt: Value(usedAt)),
      );
      await (update(
        sites,
      )..where((t) => t.id.equals(source.siteId))).write(SitesCompanion(lastUsedAt: Value(usedAt)));

      final roomId = source.roomId;
      if (roomId != null) {
        await (update(
          rooms,
        )..where((t) => t.id.equals(roomId))).write(RoomsCompanion(lastUsedAt: Value(usedAt)));
      }
    });
  }

  /// Обновляет якорь привязки места.
  Future<int> updateSiteAnchor(
    int siteId, {
    required double? latitude,
    required double? longitude,
    required double? accuracyMeters,
    required int samples,
  }) {
    return (update(sites)..where((t) => t.id.equals(siteId))).write(
      SitesCompanion(
        latitude: Value(latitude),
        longitude: Value(longitude),
        anchorAccuracyMeters: Value(accuracyMeters),
        anchorSamples: Value(samples),
      ),
    );
  }

  Future<int> renameSite(int siteId, String name, {String? city}) {
    return (update(sites)..where((t) => t.id.equals(siteId))).write(
      SitesCompanion(name: Value(_requireName(name, 'site')), city: Value(city)),
    );
  }

  Future<int> renameRoom(int roomId, String name) {
    return (update(rooms)..where((t) => t.id.equals(roomId))).write(
      RoomsCompanion(name: Value(_requireName(name, 'room'))),
    );
  }

  Future<int> renameSource(int sourceId, String name) {
    return (update(samplingPoints)..where((t) => t.id.equals(sourceId))).write(
      SamplingPointsCompanion(name: Value(_requireName(name, 'source'))),
    );
  }

  /// Удаляет место со всеми комнатами и источниками.
  ///
  /// Чистка идёт явной транзакцией, а не `ON DELETE CASCADE`: каскад в SQLite
  /// работает только при `PRAGMA foreign_keys = ON`, а включать его для всей
  /// базы ради одной операции значит заодно поменять поведение всех остальных
  /// таблиц. История замеров не трогается — она хранит имена, а не ссылки.
  Future<void> deleteSiteById(int id) async {
    await transaction(() async {
      await (delete(samplingPoints)..where((t) => t.siteId.equals(id))).go();
      await (delete(rooms)..where((t) => t.siteId.equals(id))).go();
      await (delete(sites)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Удаляет комнату вместе с её источниками.
  Future<void> deleteRoomById(int id) async {
    await transaction(() async {
      await (delete(samplingPoints)..where((t) => t.roomId.equals(id))).go();
      await (delete(rooms)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<int> deleteSourceById(int id) =>
      (delete(samplingPoints)..where((t) => t.id.equals(id))).go();

  /// Все записи отсортированы по времени, новые сверху.
  Future<List<Measurement>> getAllMeasurements({String? deviceId, int? limit}) {
    final query = select(measurements);
    if (deviceId != null) query.where((tbl) => tbl.deviceId.equals(deviceId));
    query.orderBy([(t) => OrderingTerm.desc(t.observedAt)]);
    if (limit != null) query.limit(limit);
    return query.get();
  }

  /// Последний сохранённый замер этого прибора в этом месте — база для сравнения
  /// «стало / было» на экране показаний.
  ///
  /// Место сравнивается точным равенством, а отсутствие места — через `IS NULL`:
  /// в SQL `label = NULL` не истинно никогда, поэтому замеры без места иначе
  /// не находили бы базу вовсе и вечно выглядели бы как первые.
  ///
  /// Прибор входит в условие, потому что у разных экземпляров своя калибровка
  /// электрода: сравнивать замер нового тестера со старым — сравнивать приборы,
  /// а не воду.
  /// [legacyLabel] — плоское имя, из которого источник мигрировал. Задан только у
  /// мигрировавших источников и нужен, чтобы замеры, сделанные до появления
  /// иерархии, продолжали служить базой: у них `siteName` пустой, и по структуре
  /// они не нашлись бы. У созданных вручную источников он пуст, иначе новый
  /// «Дача · Фильтр» присвоил бы себе историю старого «Фильтра», сделанного дома.
  Future<Measurement?> latestMeasurement({
    required String deviceId,
    String? siteName,
    String? roomName,
    String? sourceName,
    String? legacyLabel,
  }) {
    final query = select(measurements)..where((tbl) => tbl.deviceId.equals(deviceId));

    if (sourceName == null) {
      // Замеры без источника сравниваются только между собой. Сравнение с NULL
      // в SQL не истинно никогда, поэтому нужна отдельная ветка.
      query.where((tbl) => tbl.label.isNull());
    } else {
      query.where((tbl) {
        final structured =
            tbl.label.equals(sourceName) &
            (siteName == null ? tbl.siteName.isNull() : tbl.siteName.equals(siteName)) &
            (roomName == null ? tbl.roomName.isNull() : tbl.roomName.equals(roomName));

        if (legacyLabel == null) return structured;

        return structured | (tbl.siteName.isNull() & tbl.label.equals(legacyLabel));
      });
    }

    query.orderBy([(t) => OrderingTerm.desc(t.observedAt)]);
    query.limit(1);
    return query.getSingleOrNull();
  }

  /// Стрим: UI получает свежий список без явного refresh при каждом insert/delete.
  Stream<List<Measurement>> watchAllMeasurements({String? deviceId, int? limit}) {
    final query = select(measurements);
    if (deviceId != null) query.where((tbl) => tbl.deviceId.equals(deviceId));
    query.orderBy([(t) => OrderingTerm.desc(t.observedAt)]);
    if (limit != null) query.limit(limit);
    return query.watch();
  }

  Future<int> insertMeasurement(MeasurementsCompanion entry) => into(measurements).insert(entry);

  /// Меняет адрес замера — место, комнату и источник — у одной строки.
  /// Возвращает количество затронутых записей (0 если запись не найдена).
  ///
  /// Все три колонки пишутся вместе: смена источника почти всегда означает и
  /// смену места, а частичное обновление оставило бы запись вроде «Дача · Кухня ·
  /// Кран», где кухня осталась от прежнего адреса.
  Future<int> updateMeasurementPlace(
    int id, {
    required String? siteName,
    required String? roomName,
    required String? sourceName,
  }) {
    return (update(measurements)..where((tbl) => tbl.id.equals(id))).write(
      MeasurementsCompanion(
        label: Value(sourceName),
        siteName: Value(siteName),
        roomName: Value(roomName),
      ),
    );
  }

  /// Удаляет одну запись по id. Возвращает количество затронутых записей.
  Future<int> deleteMeasurementById(int id) =>
      (delete(measurements)..where((tbl) => tbl.id.equals(id))).go();

  /// Восстановление удалённой записи через undo: вставляет с указанным id, чтобы
  /// сохранить связи (PageView-индексы, сравнения и т.п.). Возвращает количество
  /// затронутых записей.
  Future<int> restoreMeasurement(MeasurementsCompanion entry) =>
      into(measurements).insert(entry, mode: InsertMode.insertOrReplace);

  Future<int> deleteAll({String? deviceId}) {
    if (deviceId == null) return delete(measurements).go();
    return (delete(measurements)..where((tbl) => tbl.deviceId.equals(deviceId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'water_analyzer.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
