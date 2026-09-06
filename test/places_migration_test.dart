import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/measurement_place.dart';
import 'package:water_analyzer/history/repository.dart';
import 'package:water_analyzer/yinmik/reading.dart';

/// Миграции каталога мест на **настоящем файле** БД.
///
/// In-memory база для этого не годится: она пересоздаётся на каждое соединение,
/// и реальный путь обновления пользователя остался бы непроверенным. Старая
/// схема создаётся сырым DDL и помечается `PRAGMA user_version`, после чего файл
/// открывается production-классом — ровно как это произойдёт на телефоне.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('water_analyzer_migration');
    dbFile = File('${tempDir.path}/history.sqlite');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Колонки замера в состоянии схемы v5 — последней перед иерархией.
  const measurementsV5 = '''
    CREATE TABLE measurements (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      device_id TEXT NOT NULL,
      label TEXT NULL,
      observed_at INTEGER NOT NULL,
      ph REAL NOT NULL,
      electrical_conductivity_us_cm INTEGER NOT NULL,
      total_dissolved_solids_ppm INTEGER NOT NULL,
      salinity_ppm INTEGER NOT NULL,
      salinity_percent REAL NOT NULL,
      temperature_celsius REAL NOT NULL,
      specific_gravity REAL NOT NULL,
      oxidation_reduction_potential_millivolts INTEGER NOT NULL,
      battery_raw_millivolts INTEGER NOT NULL,
      backlight_on INTEGER NOT NULL DEFAULT 0,
      hold_reading_on INTEGER NOT NULL DEFAULT 0,
      latitude REAL NULL,
      longitude REAL NULL,
      location_accuracy_meters REAL NULL,
      norms_profile TEXT NULL
    );
  ''';

  const placesV5 = '''
    CREATE TABLE places (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      created_at INTEGER NOT NULL,
      last_used_at INTEGER NULL
    );
  ''';

  /// Замер с меткой и, если заданы, координатами.
  void insertMeasurement(
    Database db,
    String? label,
    int observedAt, {
    double? latitude,
    double? longitude,
    double? accuracy,
  }) {
    final statement = db.prepare('''
      INSERT INTO measurements (
        device_id, label, observed_at, ph, electrical_conductivity_us_cm,
        total_dissolved_solids_ppm, salinity_ppm, salinity_percent,
        temperature_celsius, specific_gravity,
        oxidation_reduction_potential_millivolts, battery_raw_millivolts,
        latitude, longitude, location_accuracy_meters
      ) VALUES (?, ?, ?, 7.2, 250, 125, 60, 0.006, 21.5, 1.001, 380, 3050, ?, ?, ?);
    ''');
    statement.execute(['AA:BB', label, observedAt, latitude, longitude, accuracy]);
    statement.dispose();
  }

  /// Файл в состоянии v5: замеры плюс плоский каталог мест.
  void createV5Database({
    List<String?> labels = const [],
    List<String> places = const [],
    List<(double, double)> coordinates = const [],
  }) {
    final db = sqlite3.open(dbFile.path);
    db.execute(measurementsV5);
    db.execute(placesV5);

    var observedAt = DateTime.utc(2026, 8, 1).millisecondsSinceEpoch ~/ 1000;
    for (var index = 0; index < labels.length; index++) {
      observedAt += 3600;
      final point = index < coordinates.length ? coordinates[index] : null;
      insertMeasurement(
        db,
        labels[index],
        observedAt,
        latitude: point?.$1,
        longitude: point?.$2,
        accuracy: point == null ? null : 15,
      );
    }

    final createdAt = DateTime.utc(2026, 7, 1).millisecondsSinceEpoch ~/ 1000;
    for (final place in places) {
      final statement = db.prepare(
        'INSERT INTO places (name, created_at, last_used_at) VALUES (?, ?, ?);',
      );
      statement.execute([place, createdAt, createdAt]);
      statement.dispose();
    }

    db.execute('PRAGMA user_version = 5;');
    db.dispose();
  }

  /// Файл в состоянии v3 — до появления каталога вообще.
  void createV3Database(List<String?> labels) {
    final db = sqlite3.open(dbFile.path);
    // v3 отличается от v5 отсутствием norms_profile.
    db.execute(measurementsV5.replaceAll(',\n      norms_profile TEXT NULL', ''));

    var observedAt = DateTime.utc(2026, 8, 1).millisecondsSinceEpoch ~/ 1000;
    for (final label in labels) {
      observedAt += 3600;
      final statement = db.prepare('''
        INSERT INTO measurements (
          device_id, label, observed_at, ph, electrical_conductivity_us_cm,
          total_dissolved_solids_ppm, salinity_ppm, salinity_percent,
          temperature_celsius, specific_gravity,
          oxidation_reduction_potential_millivolts, battery_raw_millivolts
        ) VALUES (?, ?, ?, 7.2, 250, 125, 60, 0.006, 21.5, 1.001, 380, 3050);
      ''');
      statement.execute(['AA:BB', label, observedAt]);
      statement.dispose();
    }

    db.execute('PRAGMA user_version = 3;');
    db.dispose();
  }

  Future<AppDatabase> openMigrated() async {
    final database = AppDatabase.forTesting(NativeDatabase(dbFile));
    // Любой запрос заставляет drift выполнить миграцию.
    await database.customSelect('SELECT 1').get();
    return database;
  }

  group('v5 → v6: плоские места становятся иерархией', () {
    test('каждое место переезжает источником под «Дом»', () async {
      createV5Database(places: ['Кран на кухне', 'Аквариум']);
      final db = await openMigrated();
      addTearDown(db.close);
      final catalog = PlaceCatalogRepository(db);

      expect((await catalog.sites()).map((s) => s.name), [defaultSiteName]);

      final sources = await catalog.sources();
      expect(sources.map((s) => s.name), containsAll(['Кран на кухне', 'Аквариум']));
      expect(sources.every((s) => s.roomId == null), isTrue);
    });

    test('источник помнит плоское имя, из которого пришёл', () async {
      // Без этого замеры до обновления перестали бы находиться как база тренда.
      createV5Database(places: ['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      final source = await PlaceCatalogRepository(db).sourceByLegacyLabel('Кулер');

      expect(source, isNotNull);
      expect(source!.name, 'Кулер');
      expect(source.legacyLabel, 'Кулер');
    });

    test('время последнего использования не теряется', () async {
      createV5Database(places: ['Скважина']);
      final db = await openMigrated();
      addTearDown(db.close);

      final source = (await PlaceCatalogRepository(db).sources()).firstWhere(
        (s) => s.name == 'Скважина',
      );

      expect(source.lastUsedAt, isNotNull);
    });

    test('плоская таблица мест удаляется — двух каталогов не остаётся', () async {
      createV5Database(places: ['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      final rows = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type='table' AND name='places'")
          .get();

      expect(rows, isEmpty);
    });

    test('история замеров переживает миграцию без потерь', () async {
      createV5Database(labels: ['Кран на кухне', 'Аквариум', null], places: ['Кран на кухне']);
      final db = await openMigrated();
      addTearDown(db.close);

      final rows = await HistoryRepository(db).recent();

      expect(rows, hasLength(3));
      expect(rows.map((r) => r.label), containsAll(['Кран на кухне', 'Аквариум']));
    });

    test('у старых замеров место и комната остаются пустыми', () async {
      // Это их опознавательный признак: по нему поиск базы тренда понимает,
      // что запись сделана до иерархии.
      createV5Database(labels: ['Кулер'], places: ['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      final row = (await HistoryRepository(db).recent()).single;

      expect(row.label, 'Кулер');
      expect(row.siteName, isNull);
      expect(row.roomName, isNull);
    });
  });

  group('v5 → v6: привязка «Дома» к координатам', () {
    test('плотно расположенные замеры дают якорь', () async {
      // Все замеры в пределах одного двора — привязка осмысленна.
      createV5Database(
        labels: List.filled(5, 'Кран на кухне'),
        places: ['Кран на кухне'],
        coordinates: const [
          (55.7500, 37.6200),
          (55.7501, 37.6201),
          (55.7499, 37.6199),
          (55.7502, 37.6202),
          (55.7500, 37.6200),
        ],
      );
      final db = await openMigrated();
      addTearDown(db.close);

      final site = (await PlaceCatalogRepository(db).sites()).single;

      expect(site.latitude, isNotNull);
      expect(site.latitude, closeTo(55.75, 0.01));
      expect(site.longitude, closeTo(37.62, 0.01));
      expect(site.anchorSamples, greaterThan(0));
    });

    test('разбросанные замеры якоря не дают', () async {
      // Дом и дача в разных городах: центроид оказался бы посреди поля, и
      // автовыбор стабильно ошибался бы. Лучше не привязывать вовсе.
      createV5Database(
        labels: List.filled(4, 'Кран на кухне'),
        places: ['Кран на кухне'],
        coordinates: const [
          (55.7500, 37.6200),
          (55.7501, 37.6201),
          (56.8500, 35.9000),
          (56.8501, 35.9001),
        ],
      );
      final db = await openMigrated();
      addTearDown(db.close);

      final site = (await PlaceCatalogRepository(db).sites()).single;

      expect(site.latitude, isNull);
      expect(site.anchorSamples, 0);
    });

    test('история без координат оставляет место без якоря', () async {
      createV5Database(labels: ['Кулер'], places: ['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      final site = (await PlaceCatalogRepository(db).sites()).single;

      expect(site.latitude, isNull);
    });
  });

  group('v3 → v6: полный путь обновления', () {
    test('метки истории доезжают до источников через промежуточные версии', () async {
      // Пользователь на старой версии проходит все ветки подряд: v4 создаёт
      // плоский каталог, v6 превращает его в иерархию.
      createV3Database(['Дача, колодец', 'Дача, колодец', 'Аквариум']);
      final db = await openMigrated();
      addTearDown(db.close);

      final sources = (await PlaceCatalogRepository(db).sources()).map((s) => s.name);

      expect(sources, contains('Дача, колодец'));
      expect(sources, contains('Аквариум'));
      expect(sources, containsAll(defaultSourceNames));
    });

    test('метки, различающиеся пробелами, схлопываются в один источник', () async {
      createV3Database(['Дача', 'Дача ', ' Дача']);
      final db = await openMigrated();
      addTearDown(db.close);

      final matching = (await PlaceCatalogRepository(db).sources()).where((s) => s.name == 'Дача');

      expect(matching, hasLength(1));
    });

    test('пустые и пробельные метки в каталог не попадают', () async {
      createV3Database([null, '', '   ']);
      final db = await openMigrated();
      addTearDown(db.close);

      final sources = await PlaceCatalogRepository(db).sources();

      // Сравниваем множествами: каталог отдаётся в порядке свежести, а не в
      // порядке объявления дефолтов.
      expect(sources.map((s) => s.name).toSet(), defaultSourceNames.toSet());
    });

    test('старые замеры остаются без профиля норм', () async {
      createV3Database(['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      expect((await HistoryRepository(db).recent()).single.normsProfile, isNull);
    });
  });

  group('после миграции', () {
    test('новый замер сохраняет полный адрес', () async {
      createV5Database(places: ['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      await HistoryRepository(db).save(
        'AA:BB',
        const YinmikReading(
          ph: 7.2,
          electricalConductivityUsCm: 250,
          totalDissolvedSolidsPpm: 125,
          salinityPpm: 60,
          salinityPercent: 0.006,
          temperatureCelsius: 21.5,
          batteryRawMillivolts: 3050,
          statusFlags: 0,
          backlightOn: false,
          holdReadingOn: false,
          specificGravity: 1.001,
          oxidationReductionPotentialMillivolts: 380,
        ),
        DateTime(2026, 9, 6),
        place: const MeasurementPlace(siteName: 'Дом', roomName: 'Кухня', sourceName: 'Фильтр'),
      );

      final row = (await HistoryRepository(db).recent()).first;

      expect(row.siteName, 'Дом');
      expect(row.roomName, 'Кухня');
      expect(row.label, 'Фильтр');
    });

    test('тренд не рвётся на границе обновления', () async {
      // Ключевая проверка непрерывности: замер, сделанный до иерархии, обязан
      // остаться базой для нового замера в том же, теперь мигрировавшем источнике.
      createV5Database(labels: ['Кулер'], places: ['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      final source = await PlaceCatalogRepository(db).sourceByLegacyLabel('Кулер');
      final baseline = await HistoryRepository(db).latestForPlace(
        'AA:BB',
        const MeasurementPlace(siteName: defaultSiteName, sourceName: 'Кулер'),
        legacyLabel: source!.legacyLabel,
      );

      expect(baseline, isNotNull, reason: 'старый замер должен найтись как база');
      expect(baseline!.siteName, isNull, reason: 'нашёлся именно доиерархический замер');
    });

    test('без legacyLabel старый замер базой не считается', () async {
      // Обратная сторона: созданный вручную источник не должен присваивать себе
      // историю плоского места с тем же именем, сделанную в другом месте.
      createV5Database(labels: ['Кулер'], places: ['Кулер']);
      final db = await openMigrated();
      addTearDown(db.close);

      final baseline = await HistoryRepository(db).latestForPlace(
        'AA:BB',
        const MeasurementPlace(siteName: 'Дача', sourceName: 'Кулер'),
      );

      expect(baseline, isNull);
    });
  });
}
