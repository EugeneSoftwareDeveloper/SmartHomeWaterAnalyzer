import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlacesRepository', () {
    late AppDatabase db;
    late PlacesRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = PlacesRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('на свежей базе каталог заполнен дефолтными местами', () async {
      final places = await repo.all();

      expect(places.map((p) => p.name), containsAll(defaultPlaceNames));
      expect(places, hasLength(defaultPlaceNames.length));
    });

    test('дефолтные места покрывают основные сценарии тестера', () async {
      final names = (await repo.all()).map((p) => p.name).toSet();

      // Питьевая вода — самый частый сценарий, аквариум и бассейн соответствуют
      // профилям норм. Если набор менялся, тест должен об этом сказать.
      expect(names, contains('Кран на кухне'));
      expect(names, contains('После фильтра'));
      expect(names, contains('Аквариум'));
      expect(names, contains('Бассейн'));
    });

    test('add создаёт новое место', () async {
      final place = await repo.add('Дача, колонка');

      expect(place.name, 'Дача, колонка');
      expect((await repo.all()).map((p) => p.name), contains('Дача, колонка'));
    });

    test('add с существующим именем возвращает то же место, а не дубликат', () async {
      final first = await repo.add('Дача');
      final second = await repo.add('Дача');

      expect(second.id, first.id);
      expect(
        (await repo.all()).where((p) => p.name == 'Дача'),
        hasLength(1),
      );
    });

    test('add обрезает пробелы — «Дача » и «Дача» это одно место', () async {
      final first = await repo.add('Дача');
      final second = await repo.add('  Дача  ');

      expect(second.id, first.id);
    });

    test('add отвергает пустое имя', () async {
      expect(() => repo.add('   '), throwsArgumentError);
    });

    test('markUsed поднимает место в начало списка', () async {
      // «Бассейн» в алфавите первый среди дефолтных, «Родник» — нет.
      await repo.markUsed('Родник', usedAt: DateTime(2026, 8, 31, 12));

      final places = await repo.all();

      expect(places.first.name, 'Родник');
    });

    test('среди использованных первым идёт более свежий', () async {
      await repo.markUsed('Родник', usedAt: DateTime(2026, 8, 30));
      await repo.markUsed('Кулер', usedAt: DateTime(2026, 8, 31));

      final names = (await repo.all()).map((p) => p.name).toList();

      expect(names[0], 'Кулер');
      expect(names[1], 'Родник');
    });

    test('неиспользованные места идут по алфавиту после использованных', () async {
      await repo.markUsed('Родник', usedAt: DateTime(2026, 8, 31));

      final names = (await repo.all()).map((p) => p.name).toList();

      final unused = names.sublist(1);
      final sorted = [...unused]..sort();
      expect(unused, sorted, reason: 'хвост списка должен быть отсортирован по алфавиту');
    });

    test('markUsed для несуществующего места ничего не ломает', () async {
      final affected = await repo.markUsed('Такого места нет');

      expect(affected, 0);
    });

    test('deleteById убирает место из каталога', () async {
      final place = await repo.add('Временное');

      await repo.deleteById(place.id);

      expect((await repo.all()).map((p) => p.name), isNot(contains('Временное')));
    });

    test('параллельное добавление одного имени не падает на уникальном индексе',
        () async {
      // Регрессия: insertOrGetPlace был «проверить, потом вставить», и два
      // одновременных вызова (кнопка «+» и submit с клавиатуры срабатывают
      // почти вместе) упирались в UNIQUE constraint failed.
      final results = await Future.wait([
        repo.add('Одновременно'),
        repo.add('Одновременно'),
        repo.add('Одновременно'),
      ]);

      expect(results.map((p) => p.id).toSet(), hasLength(1));
      expect(
        (await repo.all()).where((p) => p.name == 'Одновременно'),
        hasLength(1),
      );
    });

    test('watchAll отдаёт обновления при добавлении', () async {
      final counts = <int>[];
      final subscription = repo.watchAll().listen((rows) => counts.add(rows.length));

      await Future<void>.delayed(Duration.zero);
      await repo.add('Новое место');
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      expect(counts.first, defaultPlaceNames.length);
      expect(counts.last, defaultPlaceNames.length + 1);
    });
  });
}
