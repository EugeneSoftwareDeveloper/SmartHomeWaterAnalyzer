import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/repository.dart';
import 'package:water_analyzer/quality/profile.dart';
import 'package:water_analyzer/yinmik/reading.dart';

YinmikReading _reading() {
  return const YinmikReading(
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
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NormsProfile.resolve', () {
    test('известное имя разбирается', () {
      expect(
        NormsProfile.resolve('pool', fallback: NormsProfile.drinking),
        NormsProfile.pool,
      );
    });

    test('null — замер до 1.2.0, берём текущий профиль', () {
      expect(
        NormsProfile.resolve(null, fallback: NormsProfile.hydroponics),
        NormsProfile.hydroponics,
      );
    });

    test('пустая строка ведёт себя как null', () {
      expect(
        NormsProfile.resolve('', fallback: NormsProfile.pool),
        NormsProfile.pool,
      );
    });

    test('неизвестное имя не роняет приложение', () {
      // Запись могла прийти из более новой версии, где профилей стало больше
      // (например, восстановление бэкапа на старую сборку).
      expect(
        NormsProfile.resolve('seaWater', fallback: NormsProfile.drinking),
        NormsProfile.drinking,
      );
    });

    test('все профили переживают круг «сохранить → разобрать»', () {
      for (final profile in NormsProfile.values) {
        expect(
          NormsProfile.resolve(profile.name, fallback: NormsProfile.drinking),
          profile,
          reason: '$profile не восстановился из своего же имени',
        );
      }
    });
  });

  group('сохранение профиля в замере', () {
    late AppDatabase db;
    late HistoryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = HistoryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('профиль пишется в запись', () async {
      await repo.save(
        'AA:BB',
        _reading(),
        DateTime(2026, 8, 31),
        normsProfile: NormsProfile.pool,
      );

      expect((await repo.recent()).single.normsProfile, 'pool');
    });

    test('без профиля колонка остаётся пустой', () async {
      await repo.save('AA:BB', _reading(), DateTime(2026, 8, 31));

      expect((await repo.recent()).single.normsProfile, isNull);
    });

    test('замер судится по своему профилю, а не по текущей настройке', () async {
      // Суть фичи: замер в бассейне, просмотренный после переключения профиля
      // на питьевую воду, не должен задним числом становиться «опасным».
      await repo.save(
        'AA:BB',
        _reading(),
        DateTime(2026, 8, 31),
        normsProfile: NormsProfile.pool,
      );
      final row = (await repo.recent()).single;

      final resolved = NormsProfile.resolve(
        row.normsProfile,
        fallback: NormsProfile.drinking, // «текущая настройка» сменилась
      );

      expect(resolved, NormsProfile.pool);
    });

    test('undo удаления не теряет профиль', () async {
      final id = await repo.save(
        'AA:BB',
        _reading(),
        DateTime(2026, 8, 31),
        normsProfile: NormsProfile.aquariumFresh,
      );
      final original = (await repo.recent()).single;
      await repo.deleteById(id);

      await repo.restoreFromMeasurement(original);

      expect((await repo.recent()).single.normsProfile, 'aquariumFresh');
    });
  });

  group('нормализация места при сохранении', () {
    late AppDatabase db;
    late HistoryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = HistoryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('пробельное место сохраняется как отсутствие места', () async {
      // До 1.2.0 место было свободным вводом, и в настройках могла остаться
      // строка из пробелов. Без нормализации запись выглядела бы «названной».
      await repo.save('AA:BB', _reading(), DateTime(2026, 8, 31), label: '   ');

      expect((await repo.recent()).single.label, isNull);
    });

    test('пробелы по краям обрезаются', () async {
      await repo.save(
        'AA:BB',
        _reading(),
        DateTime(2026, 8, 31),
        label: '  Кран на кухне  ',
      );

      expect((await repo.recent()).single.label, 'Кран на кухне');
    });
  });
}
