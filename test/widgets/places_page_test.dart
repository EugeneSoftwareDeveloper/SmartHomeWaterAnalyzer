import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/repository.dart';
import 'package:water_analyzer/location/location_service.dart';
import 'package:water_analyzer/location/measurement_location.dart';
import 'package:water_analyzer/location/site_anchor.dart';
import 'package:water_analyzer/providers/history_provider.dart';
import 'package:water_analyzer/providers/location_provider.dart';
import 'package:water_analyzer/ui/places_page.dart';

/// Управление каталогом мест.
///
/// Здесь проверяется не вёрстка, а обещания экрана: удаление спрашивает
/// подтверждение, пустое имя не создаёт запись, а привязка к координатам не
/// пишет якорь, когда координат нет. Ошибка в любом из них молча портит каталог.
///
/// Каталог и геолокация подменены: настоящая БД держала бы drift-стрим живым, и
/// `pumpAndSettle` ждал бы его таймер бесконечно.
class _MockCatalog extends Mock implements PlaceCatalogRepository {}

class _MockLocation extends Mock implements LocationService {}

Site _site(int id, String name, {String? city, double? latitude, int anchorSamples = 0}) {
  return Site(
    id: id,
    name: name,
    city: city,
    latitude: latitude,
    longitude: latitude == null ? null : 37.62,
    anchorAccuracyMeters: latitude == null ? null : 12,
    anchorSamples: anchorSamples,
    radiusMeters: 150,
    createdAt: DateTime(2026, 9, 1),
    lastUsedAt: null,
  );
}

Room _room(int id, int siteId, String name) =>
    Room(id: id, siteId: siteId, name: name, createdAt: DateTime(2026, 9, 1), lastUsedAt: null);

SamplingPoint _source(int id, int siteId, String name, {int? roomId}) {
  return SamplingPoint(
    id: id,
    siteId: siteId,
    roomId: roomId,
    name: name,
    legacyLabel: null,
    createdAt: DateTime(2026, 9, 1),
    lastUsedAt: null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockCatalog catalog;
  late _MockLocation location;

  setUpAll(() {
    registerFallbackValue(
      const SiteAnchor(latitude: 0, longitude: 0, accuracyMeters: 10, samples: 1),
    );
  });

  setUp(() {
    catalog = _MockCatalog();
    location = _MockLocation();

    when(
      () => catalog.addSite(any(), city: any(named: 'city')),
    ).thenAnswer((_) async => _site(99, 'новое'));
    when(() => catalog.addRoom(any(), any())).thenAnswer((_) async => _room(99, 1, 'новая'));
    when(
      () => catalog.addSource(any(), any(), roomId: any(named: 'roomId')),
    ).thenAnswer((_) async => _source(99, 1, 'новый'));
    when(
      () => catalog.renameSite(any(), any(), city: any(named: 'city')),
    ).thenAnswer((_) async => 1);
    when(() => catalog.renameRoom(any(), any())).thenAnswer((_) async => 1);
    when(() => catalog.renameSource(any(), any())).thenAnswer((_) async => 1);
    when(() => catalog.setSiteAnchor(any(), any())).thenAnswer((_) async => 1);
    when(() => catalog.deleteSite(any())).thenAnswer((_) async {});
    when(() => catalog.deleteRoom(any())).thenAnswer((_) async {});
    when(() => catalog.deleteSource(any())).thenAnswer((_) async => 1);
  });

  Future<void> pump(
    WidgetTester tester, {
    List<Site> sites = const [],
    List<Room> rooms = const [],
    List<SamplingPoint> sources = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placeCatalogProvider.overrideWithValue(catalog),
          locationServiceProvider.overrideWithValue(location),
          sitesProvider.overrideWith((ref) => Stream.value(sites)),
          roomsProvider.overrideWith((ref) => Stream.value(rooms)),
          sourcesProvider.overrideWith((ref) => Stream.value(sources)),
        ],
        child: const MaterialApp(home: PlacesPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Меню места — самое верхнее в дереве: `trailing` идёт раньше `children`.
  Future<void> openSiteMenu(WidgetTester tester, String item) async {
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  group('содержимое', () {
    testWidgets('пустой каталог объясняет, с чего начать', (tester) async {
      await pump(tester);

      expect(find.textContaining('Пока нет ни одного места'), findsOneWidget);
    });

    testWidgets('показывает всю иерархию сразу, без раскрытия', (tester) async {
      await pump(
        tester,
        sites: [_site(1, 'Дом')],
        rooms: [_room(5, 1, 'Кухня')],
        sources: [_source(10, 1, 'Фильтр', roomId: 5), _source(11, 1, 'Скважина')],
      );

      expect(find.text('Дом'), findsOneWidget);
      expect(find.text('Кухня'), findsOneWidget);
      expect(find.text('Фильтр'), findsOneWidget);
      // Источник без комнаты висит прямо на месте — это штатный случай.
      expect(find.text('Скважина'), findsOneWidget);
    });

    testWidgets('место без привязки честно говорит, что не подставится', (tester) async {
      await pump(tester, sites: [_site(1, 'Дом')]);

      expect(find.textContaining('без привязки'), findsOneWidget);
      expect(find.byIcon(Icons.location_disabled_outlined), findsOneWidget);
    });

    testWidgets('привязанное место показывает город и число замеров', (tester) async {
      await pump(
        tester,
        sites: [_site(1, 'Дача', city: 'Тверь', latitude: 56.85, anchorSamples: 7)],
      );

      expect(find.text('Тверь · привязано по 7 замерам'), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('место без источников не выглядит сломанным', (tester) async {
      await pump(tester, sites: [_site(1, 'Дом')]);

      expect(find.text('Источников пока нет'), findsOneWidget);
    });
  });

  group('создание', () {
    testWidgets('кнопка добавляет место с городом', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Место'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Дача');
      await tester.enterText(find.byType(TextField).at(1), 'Тверь');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verify(() => catalog.addSite('Дача', city: 'Тверь')).called(1);
    });

    testWidgets('город необязателен', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Место'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Дача');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verify(() => catalog.addSite('Дача', city: null)).called(1);
    });

    testWidgets('пустое имя места ничего не создаёт', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Место'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '   ');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verifyNever(() => catalog.addSite(any(), city: any(named: 'city')));
    });

    testWidgets('отмена ничего не создаёт', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Место'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Дача');
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      verifyNever(() => catalog.addSite(any(), city: any(named: 'city')));
    });

    testWidgets('комната создаётся внутри своего места', (tester) async {
      await pump(tester, sites: [_site(7, 'Дом')]);
      await openSiteMenu(tester, 'Добавить комнату');

      await tester.enterText(find.byType(TextField), 'Ванная');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verify(() => catalog.addRoom(7, 'Ванная')).called(1);
    });

    testWidgets('источник от места создаётся без комнаты', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача')]);
      await openSiteMenu(tester, 'Добавить источник');

      await tester.enterText(find.byType(TextField), 'Скважина');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verify(() => catalog.addSource(7, 'Скважина')).called(1);
    });

    testWidgets('источник от комнаты запоминает комнату', (tester) async {
      await pump(tester, sites: [_site(7, 'Дом')], rooms: [_room(5, 7, 'Кухня')]);

      // Второе меню сверху — комнатное: место идёт раньше своих детей.
      await tester.tap(find.byIcon(Icons.more_vert).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Добавить источник'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Аквариум');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verify(() => catalog.addSource(7, 'Аквариум', roomId: 5)).called(1);
    });
  });

  group('переименование', () {
    testWidgets('место переименовывается вместе с городом', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача', city: 'Тверь')]);
      await openSiteMenu(tester, 'Переименовать');

      await tester.enterText(find.byType(TextField).at(0), 'Дом у озера');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verify(() => catalog.renameSite(7, 'Дом у озера', city: 'Тверь')).called(1);
    });

    testWidgets('пустое имя не стирает название места', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача')]);
      await openSiteMenu(tester, 'Переименовать');

      await tester.enterText(find.byType(TextField).at(0), '');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verifyNever(() => catalog.renameSite(any(), any(), city: any(named: 'city')));
    });

    testWidgets('источник переименовывается по своему меню', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача')], sources: [_source(10, 7, 'Скважина')]);

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Переименовать'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Колодец');
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      verify(() => catalog.renameSource(10, 'Колодец')).called(1);
    });
  });

  group('удаление', () {
    testWidgets('место удаляется только после подтверждения', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача')]);
      await openSiteMenu(tester, 'Удалить место');

      expect(find.text('Удалить «Дача»?'), findsOneWidget);
      // Пользователю прямо сказано, что история не пострадает.
      expect(find.textContaining('Замеры останутся в истории'), findsOneWidget);

      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      verify(() => catalog.deleteSite(7)).called(1);
    });

    testWidgets('отмена сохраняет место', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача')]);
      await openSiteMenu(tester, 'Удалить место');
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      verifyNever(() => catalog.deleteSite(any()));
    });

    testWidgets('источник удаляется по своему меню', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача')], sources: [_source(10, 7, 'Скважина')]);

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить источник'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      verify(() => catalog.deleteSource(10)).called(1);
    });
  });

  group('привязка к координатам', () {
    testWidgets('успешный фикс становится якорем места', (tester) async {
      when(location.currentLocation).thenAnswer(
        (_) async => const LocationResult.success(
          MeasurementLocation(latitude: 55.75, longitude: 37.62, accuracyMeters: 18),
        ),
      );

      await pump(tester, sites: [_site(7, 'Дача')]);
      await openSiteMenu(tester, 'Привязать здесь');

      final anchor =
          verify(() => catalog.setSiteAnchor(7, captureAny())).captured.single as SiteAnchor;
      expect(anchor.latitude, closeTo(55.75, 1e-9));
      expect(anchor.longitude, closeTo(37.62, 1e-9));
      expect(anchor.samples, 1);
      expect(find.text('Место привязано к этой точке'), findsOneWidget);
    });

    testWidgets('без координат якорь не переписывается', (tester) async {
      // Иначе одна неудачная попытка стёрла бы накопленную привязку.
      when(
        location.currentLocation,
      ).thenAnswer((_) async => const LocationResult.failed(LocationFailure.serviceDisabled));

      await pump(tester, sites: [_site(7, 'Дача', latitude: 56.85, anchorSamples: 4)]);
      await openSiteMenu(tester, 'Привязать здесь');

      verifyNever(() => catalog.setSiteAnchor(any(), any()));
      expect(find.text(LocationFailure.serviceDisabled.message), findsOneWidget);
    });

    testWidgets('сброс привязки очищает координаты', (tester) async {
      await pump(tester, sites: [_site(7, 'Дача', latitude: 56.85, anchorSamples: 4)]);
      await openSiteMenu(tester, 'Сбросить привязку');

      verify(() => catalog.setSiteAnchor(7, null)).called(1);
      verifyNever(location.currentLocation);
    });
  });
}
