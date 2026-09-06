import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/place_catalog.dart';
import 'package:water_analyzer/history/repository.dart';
import 'package:water_analyzer/location/site_anchor.dart';

/// Каталог «место → комната → источник».
///
/// Главное, что здесь проверяется: уникальность имён считается **внутри** места,
/// а не глобально (иначе «Кухня» не могла бы существовать и дома, и на даче),
/// и что необязательная комната не ломает эту уникальность.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PlaceCatalogRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PlaceCatalogRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('свежая база', () {
    test('содержит место «Дом» с готовым набором источников', () async {
      final sites = await repo.sites();
      final sources = await repo.sources();

      expect(sites.map((s) => s.name), [defaultSiteName]);
      expect(sources.map((s) => s.name), containsAll(defaultSourceNames));
      expect(sources, hasLength(defaultSourceNames.length));
    });

    test('дефолтные источники висят прямо на месте, без комнаты', () async {
      // Разложить их по комнатам автоматически нельзя: «Скважина» и
      // «Бутилированная» не про комнаты вовсе.
      final sources = await repo.sources();

      expect(sources.every((s) => s.roomId == null), isTrue);
    });

    test('источники покрывают основные сценарии тестера', () async {
      final names = (await repo.sources()).map((s) => s.name).toSet();

      expect(names, contains('Кран на кухне'));
      expect(names, contains('После фильтра'));
      expect(names, contains('Аквариум'));
      expect(names, contains('Бассейн'));
    });
  });

  group('создание', () {
    test('добавляет место, комнату и источник', () async {
      final site = await repo.addSite('Дача', city: 'Тверь');
      final room = await repo.addRoom(site.id, 'Кухня');
      final source = await repo.addSource(site.id, 'Фильтр', roomId: room.id);

      expect(site.city, 'Тверь');
      expect(room.siteId, site.id);
      expect(source.siteId, site.id);
      expect(source.roomId, room.id);
    });

    test('повторное добавление возвращает существующее, а не дубликат', () async {
      final first = await repo.addSite('Дача');
      final second = await repo.addSite('Дача');

      expect(second.id, first.id);
      expect((await repo.sites()).where((s) => s.name == 'Дача'), hasLength(1));
    });

    test('пробелы по краям обрезаются при создании', () async {
      final site = await repo.addSite('  Дача  ');

      expect(site.name, 'Дача');
    });

    test('пустое имя отвергается на каждом уровне', () async {
      final site = await repo.addSite('Дача');

      expect(() => repo.addSite('   '), throwsArgumentError);
      expect(() => repo.addRoom(site.id, ''), throwsArgumentError);
      expect(() => repo.addSource(site.id, '  '), throwsArgumentError);
    });

    test('одноимённые комнаты живут в разных местах', () async {
      // Уникальность внутри места, а не глобально: «Кухня» есть и дома, и на даче.
      final home = await repo.addSite('Дом');
      final dacha = await repo.addSite('Дача');

      final homeKitchen = await repo.addRoom(home.id, 'Кухня');
      final dachaKitchen = await repo.addRoom(dacha.id, 'Кухня');

      expect(homeKitchen.id, isNot(dachaKitchen.id));
    });

    test('одноимённые источники живут в разных комнатах одного места', () async {
      final site = await repo.addSite('Дом');
      final kitchen = await repo.addRoom(site.id, 'Кухня');
      final bathroom = await repo.addRoom(site.id, 'Ванная');

      final a = await repo.addSource(site.id, 'Кран', roomId: kitchen.id);
      final b = await repo.addSource(site.id, 'Кран', roomId: bathroom.id);

      expect(a.id, isNot(b.id));
    });

    test('в кухне уживаются фильтр и аквариум — это разные источники', () async {
      // Сценарий пользователя дословно: два отдельных измерения в одной комнате.
      final site = await repo.addSite('Дом');
      final kitchen = await repo.addRoom(site.id, 'Кухня');

      final filter = await repo.addSource(site.id, 'Фильтр', roomId: kitchen.id);
      final aquarium = await repo.addSource(site.id, 'Аквариум', roomId: kitchen.id);

      expect(filter.id, isNot(aquarium.id));
      expect(await repo.sources(), hasLength(defaultSourceNames.length + 2));
    });

    test('источник без комнаты не дублируется в пределах места', () async {
      // Ради этого случая уникальность задана частичными индексами: составной
      // UNIQUE считает NULL'ы различными и пропустил бы две «Скважины».
      final site = await repo.addSite('Дача');

      final first = await repo.addSource(site.id, 'Скважина');
      final second = await repo.addSource(site.id, 'Скважина');

      expect(second.id, first.id);
    });

    test('источник с комнатой и без неё — разные записи', () async {
      final site = await repo.addSite('Дом');
      final kitchen = await repo.addRoom(site.id, 'Кухня');

      final onSite = await repo.addSource(site.id, 'Кран');
      final inRoom = await repo.addSource(site.id, 'Кран', roomId: kitchen.id);

      expect(onSite.id, isNot(inRoom.id));
      expect(onSite.roomId, isNull);
      expect(inRoom.roomId, kitchen.id);
    });

    test('параллельное добавление одного имени не падает на уникальном индексе', () async {
      // Кнопка «+» и submit с клавиатуры срабатывают почти одновременно.
      final site = await repo.addSite('Дом');

      final results = await Future.wait([
        repo.addSource(site.id, 'Родник'),
        repo.addSource(site.id, 'Родник'),
        repo.addSource(site.id, 'Родник'),
      ]);

      expect(results.map((s) => s.id).toSet(), hasLength(1));
    });
  });

  group('порядок и свежесть', () {
    test('использованный источник поднимает и себя, и своё место', () async {
      final dacha = await repo.addSite('Дача');
      final well = await repo.addSource(dacha.id, 'Скважина');

      await repo.markSourceUsed(well.id, usedAt: DateTime(2026, 9, 6, 12));

      final sites = await repo.sites();
      final sources = await repo.sources();

      expect(sites.first.name, 'Дача', reason: 'место, где только что мерили, идёт первым');
      expect(sources.first.name, 'Скважина');
    });

    test('комната тоже поднимается вместе с источником', () async {
      final site = await repo.addSite('Дом');
      final kitchen = await repo.addRoom(site.id, 'Кухня');
      await repo.addRoom(site.id, 'Ванная');
      final filter = await repo.addSource(site.id, 'Фильтр', roomId: kitchen.id);

      await repo.markSourceUsed(filter.id, usedAt: DateTime(2026, 9, 6, 12));

      expect((await repo.rooms()).first.name, 'Кухня');
    });

    test('отметка несуществующего источника безопасна', () async {
      await expectLater(repo.markSourceUsed(99999), completes);
    });
  });

  group('удаление', () {
    test('удаление места уносит его комнаты и источники', () async {
      final site = await repo.addSite('Дача');
      final room = await repo.addRoom(site.id, 'Баня');
      await repo.addSource(site.id, 'Кран', roomId: room.id);
      await repo.addSource(site.id, 'Скважина');

      await repo.deleteSite(site.id);

      expect((await repo.sites()).where((s) => s.id == site.id), isEmpty);
      expect((await repo.rooms()).where((r) => r.siteId == site.id), isEmpty);
      expect((await repo.sources()).where((s) => s.siteId == site.id), isEmpty);
    });

    test('удаление места не трогает соседнее', () async {
      final dacha = await repo.addSite('Дача');
      await repo.addSource(dacha.id, 'Скважина');

      await repo.deleteSite(dacha.id);

      // Дефолтное место со своими источниками осталось нетронутым.
      expect((await repo.sites()).map((s) => s.name), [defaultSiteName]);
      expect(await repo.sources(), hasLength(defaultSourceNames.length));
    });

    test('удаление комнаты уносит её источники, но не место', () async {
      final site = await repo.addSite('Дом');
      final kitchen = await repo.addRoom(site.id, 'Кухня');
      await repo.addSource(site.id, 'Фильтр', roomId: kitchen.id);

      await repo.deleteRoom(kitchen.id);

      expect((await repo.rooms()).where((r) => r.id == kitchen.id), isEmpty);
      expect((await repo.sources()).where((s) => s.roomId == kitchen.id), isEmpty);
      expect((await repo.sites()).where((s) => s.id == site.id), hasLength(1));
    });
  });

  group('привязка к координатам', () {
    test('якорь записывается и читается', () async {
      final site = await repo.addSite('Дача');

      await repo.setSiteAnchor(
        site.id,
        const SiteAnchor(latitude: 56.85, longitude: 35.9, accuracyMeters: 12, samples: 3),
      );

      final stored = (await repo.sites()).firstWhere((s) => s.id == site.id);
      expect(stored.latitude, closeTo(56.85, 1e-9));
      expect(stored.longitude, closeTo(35.9, 1e-9));
      expect(stored.anchorAccuracyMeters, closeTo(12, 1e-9));
      expect(stored.anchorSamples, 3);
    });

    test('сброс привязки очищает координаты и счётчик', () async {
      final site = await repo.addSite('Дача');
      await repo.setSiteAnchor(
        site.id,
        const SiteAnchor(latitude: 56.85, longitude: 35.9, accuracyMeters: 12, samples: 3),
      );

      await repo.setSiteAnchor(site.id, null);

      final stored = (await repo.sites()).firstWhere((s) => s.id == site.id);
      expect(stored.latitude, isNull);
      expect(stored.longitude, isNull);
      expect(stored.anchorSamples, 0);
    });

    test('свежее место якоря не имеет и в автовыборе не участвует', () async {
      final site = await repo.addSite('Новое');

      expect(site.latitude, isNull);
      expect(site.anchorSamples, 0);
    });
  });

  group('PlaceCatalog собирает иерархию', () {
    test('отдаёт полный адрес источника', () async {
      final site = await repo.addSite('Дача');
      final room = await repo.addRoom(site.id, 'Баня');
      final source = await repo.addSource(site.id, 'Кран', roomId: room.id);

      final catalog = PlaceCatalog(
        sites: await repo.sites(),
        rooms: await repo.rooms(),
        sources: await repo.sources(),
      );

      expect(catalog.placeOf(source).formatted, 'Дача · Баня · Кран');
    });

    test('источник без комнаты даёт путь из двух уровней', () async {
      final site = await repo.addSite('Дача');
      final source = await repo.addSource(site.id, 'Скважина');

      final catalog = PlaceCatalog(
        sites: await repo.sites(),
        rooms: await repo.rooms(),
        sources: await repo.sources(),
      );

      expect(catalog.placeOf(source).formatted, 'Дача · Скважина');
    });

    test('адрес удалённого источника не находится', () async {
      final catalog = PlaceCatalog(
        sites: await repo.sites(),
        rooms: await repo.rooms(),
        sources: await repo.sources(),
      );

      expect(catalog.placeOfSourceId(99999), isNull);
      expect(catalog.placeOfSourceId(null), isNull);
    });
  });
}
