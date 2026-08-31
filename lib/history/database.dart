import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
}

/// Каталог мест замера — «Кран на кухне», «Аквариум», «Скважина».
///
/// Хранится отдельно от [Measurements] сознательно: сам замер держит **имя** места
/// в своей колонке `label`, а не ссылку на строку этой таблицы. Так переименование
/// или удаление места не переписывает историю задним числом — записанное «Кран на
/// кухне» останется тем, чем было в момент замера.
class Places extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Название места. Уникально — два одинаковых пункта в списке выбора бессмысленны.
  TextColumn get name => text().unique()();

  DateTimeColumn get createdAt => dateTime()();

  /// Когда местом пользовались в последний раз. Недавние поднимаются в начало
  /// списка выбора: на практике человек меряет 2-3 точки, остальные — редкий хвост.
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
}

/// Места, которые предлагаются при первом запуске. Подобраны под реальные сценарии
/// бытового тестера воды и профили норм: питьевая вода (кран / фильтр / кулер /
/// бутилированная), автономные источники (скважина, колодец, родник), аквариум и
/// бассейн. Пользователь может удалить лишние и добавить свои.
const List<String> defaultPlaceNames = <String>[
  'Кран на кухне',
  'После фильтра',
  'Кулер',
  'Бутилированная',
  'Скважина',
  'Колодец',
  'Родник',
  'Аквариум',
  'Бассейн',
];

@DriftDatabase(tables: [Measurements, Places])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Конструктор для unit-тестов: позволяет передать произвольный `QueryExecutor`,
  /// обычно `NativeDatabase.memory()` для in-memory SQLite. Production-код использует
  /// дефолтный конструктор с файловой БД в documents-directory.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Свежая установка: предлагаем готовый набор мест, чтобы первый замер
          // можно было подписать сразу, не придумывая названия.
          await _seedDefaultPlaces();
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
            // v4: каталог мест замера.
            await m.createTable(places);
            // Импорт идёт ПЕРЕД сидированием, и это важно. Обе вставки используют
            // insertOrIgnore, поэтому выигрывает та, что пришла первой. Метка
            // пользователя несёт lastUsedAt (время его последнего замера), а
            // дефолт — нет; при обратном порядке метка «Аквариум» была бы
            // проигнорирована как дубликат уже вставленного дефолта, потеряла бы
            // lastUsedAt и уехала в конец списка ниже мест, которыми никогда не
            // пользовались.
            await _importPlacesFromExistingLabels();
            await _seedDefaultPlaces();
          }
        },
      );

  /// Вставляет дефолтные места. `insertOrIgnore` — потому что имя уникально:
  /// повторный вызов или совпадение с уже импортированной меткой не должны падать.
  Future<void> _seedDefaultPlaces() async {
    final now = DateTime.now();
    await batch((batch) {
      batch.insertAll(
        places,
        [
          for (final name in defaultPlaceNames)
            PlacesCompanion.insert(name: name, createdAt: now),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Переносит уже использованные метки замеров в каталог мест.
  ///
  /// `lastUsedAt` берётся из времени последнего замера с этой меткой — так место,
  /// которым пользовались недавно, окажется в начале списка выбора сразу после
  /// обновления, а не только после первого повторного использования.
  Future<void> _importPlacesFromExistingLabels() async {
    final labelColumn = measurements.label;
    final lastUsed = measurements.observedAt.max();

    final rows = await (selectOnly(measurements)
          ..addColumns([labelColumn, lastUsed])
          ..where(labelColumn.isNotNull())
          ..groupBy([labelColumn]))
        .get();

    final entries = <PlacesCompanion>[];
    final now = DateTime.now();
    for (final row in rows) {
      final name = row.read(labelColumn)?.trim();
      if (name == null || name.isEmpty) continue;
      entries.add(
        PlacesCompanion.insert(
          name: name,
          createdAt: now,
          lastUsedAt: Value(row.read(lastUsed)),
        ),
      );
    }
    if (entries.isEmpty) return;

    await batch((batch) {
      batch.insertAll(places, entries, mode: InsertMode.insertOrIgnore);
    });
  }

  /// Места для списка выбора: сначала недавно использованные, затем остальные
  /// по алфавиту. В SQLite NULL меньше любого значения, поэтому при `DESC`
  /// неиспользованные места естественным образом уходят в хвост.
  Stream<List<Place>> watchPlaces() {
    return (select(places)
          ..orderBy([
            (t) => OrderingTerm.desc(t.lastUsedAt),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  Future<List<Place>> getPlaces() {
    return (select(places)
          ..orderBy([
            (t) => OrderingTerm.desc(t.lastUsedAt),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
  }

  /// Добавляет место. Если такое имя уже есть — возвращает существующее,
  /// а не создаёт дубликат и не падает на нарушении уникальности.
  ///
  /// Вставка идёт через `insertOrIgnore`, а не «сначала проверить, потом
  /// вставить»: между проверкой и вставкой есть окно, в которое успевает
  /// пролезть второй вызов (кнопка «+» и submit с клавиатуры срабатывают
  /// почти одновременно), и БД отвечает `UNIQUE constraint failed`.
  Future<Place> insertOrGetPlace(String name, DateTime createdAt) async {
    final trimmed = name.trim();

    await into(places).insert(
      PlacesCompanion.insert(name: trimmed, createdAt: createdAt),
      mode: InsertMode.insertOrIgnore,
    );

    return (select(places)..where((t) => t.name.equals(trimmed))).getSingle();
  }

  /// Отмечает место как только что использованное — оно поднимется в начало списка.
  Future<int> touchPlace(String name, DateTime usedAt) {
    return (update(places)..where((t) => t.name.equals(name.trim())))
        .write(PlacesCompanion(lastUsedAt: Value(usedAt)));
  }

  /// Удаляет место из каталога. Замеры, сделанные в нём, сохраняют своё название
  /// в `label` — история не переписывается.
  Future<int> deletePlaceById(int id) =>
      (delete(places)..where((t) => t.id.equals(id))).go();

  /// Все записи отсортированы по времени, новые сверху.
  Future<List<Measurement>> getAllMeasurements({String? deviceId, int? limit}) {
    final query = select(measurements);
    if (deviceId != null) query.where((tbl) => tbl.deviceId.equals(deviceId));
    query.orderBy([(t) => OrderingTerm.desc(t.observedAt)]);
    if (limit != null) query.limit(limit);
    return query.get();
  }

  /// Стрим: UI получает свежий список без явного refresh при каждом insert/delete.
  Stream<List<Measurement>> watchAllMeasurements({String? deviceId, int? limit}) {
    final query = select(measurements);
    if (deviceId != null) query.where((tbl) => tbl.deviceId.equals(deviceId));
    query.orderBy([(t) => OrderingTerm.desc(t.observedAt)]);
    if (limit != null) query.limit(limit);
    return query.watch();
  }

  Future<int> insertMeasurement(MeasurementsCompanion entry) =>
      into(measurements).insert(entry);

  /// Меняет только колонку `label` у одной строки. Возвращает количество затронутых записей
  /// (0 если запись с таким id не найдена, 1 при успехе).
  Future<int> updateMeasurementLabel(int id, String? label) {
    return (update(measurements)..where((tbl) => tbl.id.equals(id))).write(
      MeasurementsCompanion(label: Value(label)),
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
