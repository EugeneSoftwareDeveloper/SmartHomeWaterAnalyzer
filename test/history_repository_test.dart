import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/repository.dart';
import 'package:water_analyzer/yinmik/reading.dart';

YinmikReading _reading({double ph = 7.2, int orp = 380}) {
  return YinmikReading(
    ph: ph,
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
    oxidationReductionPotentialMillivolts: orp,
  );
}

void main() {
  // drift в тестах требует initialized binding (например, для NativeDatabase.memory)
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryRepository', () {
    late AppDatabase db;
    late HistoryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = HistoryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('save возвращает положительный id и запись появляется в recent', () async {
      final id = await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 10));

      expect(id, greaterThan(0));
      final rows = await repo.recent();
      expect(rows, hasLength(1));
      expect(rows.first.id, id);
      expect(rows.first.deviceId, 'AA:BB');
    });

    test('save с label сохраняет метку, без label — null', () async {
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 10), label: 'Кухня');
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 11));

      final rows = await repo.recent();
      expect(rows, hasLength(2));
      // Сортировка desc by observedAt — первой будет 11:00.
      expect(rows[0].label, isNull);
      expect(rows[1].label, 'Кухня');
    });

    test('recent отсортирован по убыванию observedAt', () async {
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 20));
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24));
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 22));

      final rows = await repo.recent();
      expect(
        rows.map((m) => m.observedAt).toList(),
        [DateTime(2026, 5, 24), DateTime(2026, 5, 22), DateTime(2026, 5, 20)],
      );
    });

    test('recent с deviceId фильтрует только записи указанного устройства', () async {
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 10));
      await repo.save('CC:DD', _reading(), DateTime(2026, 5, 24, 11));
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 12));

      final filtered = await repo.recent(deviceId: 'AA:BB');
      expect(filtered, hasLength(2));
      expect(filtered.every((m) => m.deviceId == 'AA:BB'), isTrue);
    });

    test('updateLabel меняет только метку, прочие поля остаются', () async {
      final id = await repo.save(
        'AA:BB',
        _reading(ph: 6.9, orp: 350),
        DateTime(2026, 5, 24, 10),
        label: 'Старая метка',
      );

      final affected = await repo.updateLabel(id, 'Новая метка');

      expect(affected, 1);
      final rows = await repo.recent();
      expect(rows.first.label, 'Новая метка');
      expect(rows.first.ph, 6.9);
      expect(rows.first.oxidationReductionPotentialMillivolts, 350);
    });

    test('updateLabel со строкой из одних пробелов делает label = null', () async {
      final id = await repo.save(
        'AA:BB',
        _reading(),
        DateTime(2026, 5, 24, 10),
        label: 'Кухня',
      );

      await repo.updateLabel(id, '   ');

      final rows = await repo.recent();
      expect(rows.first.label, isNull);
    });

    test('updateLabel у несуществующего id возвращает 0', () async {
      final affected = await repo.updateLabel(9999, 'что-то');
      expect(affected, 0);
    });

    test('deleteById удаляет одну запись', () async {
      final id1 = await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 10));
      final id2 = await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 11));

      final affected = await repo.deleteById(id1);

      expect(affected, 1);
      final rows = await repo.recent();
      expect(rows, hasLength(1));
      expect(rows.first.id, id2);
    });

    test('deleteById несуществующего id возвращает 0', () async {
      final affected = await repo.deleteById(9999);
      expect(affected, 0);
    });

    test('restoreFromMeasurement восстанавливает запись с тем же id', () async {
      final id = await repo.save(
        'AA:BB',
        _reading(ph: 7.5),
        DateTime(2026, 5, 24, 10),
        label: 'Перед удалением',
      );
      final original = (await repo.recent()).first;

      await repo.deleteById(id);
      expect(await repo.recent(), isEmpty);

      final affected = await repo.restoreFromMeasurement(original);

      expect(affected, 1);
      final restored = (await repo.recent()).single;
      expect(restored.id, id, reason: 'id должен сохраниться');
      expect(restored.label, 'Перед удалением');
      expect(restored.ph, 7.5);
      expect(restored.observedAt, DateTime(2026, 5, 24, 10));
    });

    test('clear полностью очищает таблицу', () async {
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 10));
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 11));
      await repo.save('CC:DD', _reading(), DateTime(2026, 5, 24, 12));

      await repo.clear();

      expect(await repo.recent(), isEmpty);
    });

    test('clear с deviceId удаляет только записи указанного устройства', () async {
      await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 10));
      await repo.save('CC:DD', _reading(), DateTime(2026, 5, 24, 11));

      await repo.clear(deviceId: 'AA:BB');

      final rows = await repo.recent();
      expect(rows, hasLength(1));
      expect(rows.first.deviceId, 'CC:DD');
    });

    test('watchRecent — стрим перерисовывается при insert и delete', () async {
      final stream = repo.watchRecent();
      final events = <int>[];
      final subscription = stream.listen((rows) => events.add(rows.length));

      // Даём drift инициализировать стрим (первое событие — пустой список).
      await Future<void>.delayed(Duration.zero);
      final id = await repo.save('AA:BB', _reading(), DateTime(2026, 5, 24, 10));
      await Future<void>.delayed(Duration.zero);
      await repo.deleteById(id);
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      // Ожидаем как минимум: пусто → 1 → пусто.
      expect(events, containsAllInOrder([0, 1, 0]));
    });
  });
}
