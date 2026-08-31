import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/repository.dart';
import 'package:water_analyzer/quality/profile.dart';
import 'package:water_analyzer/yinmik/reading.dart';

/// Миграция v3 → v4 на «боевой» базе: у пользователя уже есть история с метками,
/// и после обновления его собственные названия должны оказаться в каталоге мест,
/// а не исчезнуть. Это самая рискованная часть изменения — проверяем на настоящем
/// файле БД, а не на пустой in-memory.
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

  /// Создаёт файл БД в состоянии схемы v3 (до появления каталога мест) и
  /// наполняет его замерами с метками.
  void createV3Database(List<String?> labels) {
    final db = sqlite3.open(dbFile.path);
    db.execute('''
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
        location_accuracy_meters REAL NULL
      );
    ''');

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

  test('метки из истории переносятся в каталог мест', () async {
    createV3Database(['Кухня, кран', 'Дача, колодец']);

    final db = await openMigrated();
    addTearDown(db.close);
    final names = (await PlacesRepository(db).all()).map((p) => p.name).toSet();

    expect(names, contains('Кухня, кран'));
    expect(names, contains('Дача, колодец'));
  });

  test('дефолтные места добавляются вместе с импортированными', () async {
    createV3Database(['Кухня, кран']);

    final db = await openMigrated();
    addTearDown(db.close);
    final names = (await PlacesRepository(db).all()).map((p) => p.name).toSet();

    expect(names, containsAll(defaultPlaceNames));
    expect(names, contains('Кухня, кран'));
  });

  test('метка, совпадающая с дефолтным местом, не создаёт дубликат', () async {
    createV3Database(['Аквариум', 'Аквариум']);

    final db = await openMigrated();
    addTearDown(db.close);
    final places = await PlacesRepository(db).all();

    expect(places.where((p) => p.name == 'Аквариум'), hasLength(1));
  });

  test('метка, совпадающая с дефолтным местом, сохраняет время использования', () async {
    // Регрессия: сидирование дефолтов шло перед импортом, и метка «Аквариум»
    // отбрасывалась insertOrIgnore как дубликат уже вставленного дефолта.
    // Место теряло lastUsedAt и уезжало в конец списка — ниже мест, которыми
    // пользователь не пользовался ни разу.
    createV3Database(['Аквариум']);

    final db = await openMigrated();
    addTearDown(db.close);
    final places = await PlacesRepository(db).all();
    final aquarium = places.firstWhere((p) => p.name == 'Аквариум');

    expect(
      aquarium.lastUsedAt,
      isNotNull,
      reason: 'использованное место должно помнить, когда им пользовались',
    );
    expect(
      places.first.name,
      'Аквариум',
      reason: 'единственное использованное место обязано быть первым в списке',
    );
  });

  test('пустые и null-метки не попадают в каталог', () async {
    createV3Database([null, '', '   ', 'Реальное место']);

    final db = await openMigrated();
    addTearDown(db.close);
    final places = await PlacesRepository(db).all();

    expect(places.map((p) => p.name), contains('Реальное место'));
    expect(
      places.where((p) => p.name.trim().isEmpty),
      isEmpty,
      reason: 'безымянных мест в каталоге быть не должно',
    );
    expect(places, hasLength(defaultPlaceNames.length + 1));
  });

  test('импортированное место получает время последнего замера с этой меткой', () async {
    createV3Database(['Старое место', 'Новое место']);

    final db = await openMigrated();
    addTearDown(db.close);
    final places = await PlacesRepository(db).all();
    final imported = places.where((p) => p.name.endsWith('место')).toList();

    // Обе метки использовались, поэтому у них есть lastUsedAt и они идут
    // впереди неиспользованных дефолтных мест.
    expect(imported.every((p) => p.lastUsedAt != null), isTrue);
    expect(
      places.take(2).map((p) => p.name),
      containsAll(<String>['Старое место', 'Новое место']),
    );
  });

  test('история замеров переживает миграцию без потерь', () async {
    createV3Database(['Кухня, кран', 'Дача, колодец', null]);

    final db = await openMigrated();
    addTearDown(db.close);
    final rows = await HistoryRepository(db).recent();

    expect(rows, hasLength(3));
    expect(rows.map((m) => m.label), containsAll(<String?>['Кухня, кран', 'Дача, колодец']));
  });

  test('база без меток получает только дефолтные места', () async {
    createV3Database([null, null]);

    final db = await openMigrated();
    addTearDown(db.close);
    final places = await PlacesRepository(db).all();

    expect(places, hasLength(defaultPlaceNames.length));
  });

  test('метки, различающиеся пробелами, схлопываются в одно место', () async {
    // GROUP BY в SQL идёт по сырому значению, поэтому «Дача» и «Дача » приходят
    // разными строками и после trim() дали бы конфликт по уникальному имени.
    createV3Database(['Дача', 'Дача ', ' Дача']);

    final db = await openMigrated();
    addTearDown(db.close);
    final places = await PlacesRepository(db).all();

    expect(places.where((p) => p.name == 'Дача'), hasLength(1));
    expect(places, hasLength(defaultPlaceNames.length + 1));
  });

  test('схлопнутое место получает самое свежее время использования', () async {
    // Замеры создаются с шагом в час, последний — самый свежий. Место должно
    // унаследовать именно его время, а не время первой попавшейся метки.
    createV3Database(['Дача ', 'Дача']);

    final db = await openMigrated();
    addTearDown(db.close);
    final dacha = (await PlacesRepository(db).all())
        .firstWhere((p) => p.name == 'Дача');
    final rows = await HistoryRepository(db).recent();
    final newest = rows
        .map((m) => m.observedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    expect(dacha.lastUsedAt, newest);
  });

  test('миграция v3 → v5 оставляет старые замеры без профиля норм', () async {
    // Профиль появился в v5. У записей, сделанных раньше, он неизвестен —
    // и это валидное состояние: UI для них берёт текущий профиль из настроек.
    createV3Database(['Кухня, кран']);

    final db = await openMigrated();
    addTearDown(db.close);
    final rows = await HistoryRepository(db).recent();

    expect(rows, isNotEmpty);
    expect(rows.every((m) => m.normsProfile == null), isTrue);
  });

  test('после миграции новые замеры сохраняют профиль', () async {
    createV3Database(['Кухня, кран']);

    final db = await openMigrated();
    addTearDown(db.close);
    final repo = HistoryRepository(db);
    await repo.save(
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
      DateTime(2026, 9),
      normsProfile: NormsProfile.pool,
    );

    final newest = (await repo.recent()).first;
    expect(newest.normsProfile, 'pool');
  });
}
