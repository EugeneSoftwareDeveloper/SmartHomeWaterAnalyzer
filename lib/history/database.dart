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
}

@DriftDatabase(tables: [Measurements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: добавляем колонку label для пользовательских меток замеров.
            await m.addColumn(measurements, measurements.label);
          }
        },
      );

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
