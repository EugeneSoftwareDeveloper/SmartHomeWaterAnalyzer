import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/l10n/generated/app_localizations.dart';
import 'package:water_analyzer/history/repository.dart';
import 'package:water_analyzer/providers/history_provider.dart';
import 'package:water_analyzer/providers/preferences_provider.dart';
import 'package:water_analyzer/ui/widgets/place_picker.dart';

/// Выбор адреса замера.
///
/// Логики здесь больше, чем кажется по вёрстке: поле показывает **весь путь**,
/// а не имя источника, лист различает «закрыли» и «выбрали без адреса», а выбор
/// поднимает источник в списке.
///
/// Каталог подставляется готовыми списками, а не настоящей БД: drift держит
/// стрим живым, и `pumpAndSettle` ждал бы его таймер бесконечно. Сама база
/// проверяется отдельно в `place_catalog_repository_test.dart`, здесь же
/// проверяется виджет.
/// Локаль зафиксирована русской: тексты сравниваются буквально, и без этого
/// тесты читали бы системную локаль машины, где их запускают.
class _MockCatalog extends Mock implements PlaceCatalogRepository {}

Site _site(int id, String name, {String? city, double? latitude}) {
  return Site(
    id: id,
    name: name,
    city: city,
    latitude: latitude,
    longitude: latitude == null ? null : 37.62,
    anchorAccuracyMeters: null,
    anchorSamples: latitude == null ? 0 : 3,
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

  late SharedPreferences prefs;
  late _MockCatalog catalog;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    catalog = _MockCatalog();
    when(() => catalog.markSourceUsed(any())).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    List<Site> sites = const [],
    List<Room> rooms = const [],
    List<SamplingPoint> sources = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          placeCatalogProvider.overrideWithValue(catalog),
          sitesProvider.overrideWith((ref) => Stream.value(sites)),
          roomsProvider.overrideWith((ref) => Stream.value(rooms)),
          sourcesProvider.overrideWith((ref) => Stream.value(sources)),
        ],
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('PlacePickerField', () {
    testWidgets('без выбора показывает «Не выбрано»', (tester) async {
      await pump(tester, const PlacePickerField());

      expect(find.text('Не выбрано'), findsOneWidget);
      expect(find.text('Где мерим'), findsOneWidget);
    });

    testWidgets('показывает весь путь, а не одно имя источника', (tester) async {
      // Ради этого поле и переписано: «Кран» есть и дома, и на даче.
      await prefs.setInt('settings.currentSourceId', 10);

      await pump(
        tester,
        const PlacePickerField(),
        sites: [_site(1, 'Дача')],
        rooms: [_room(5, 1, 'Баня')],
        sources: [_source(10, 1, 'Кран', roomId: 5)],
      );

      expect(find.text('Дача · Баня · Кран'), findsOneWidget);
    });

    testWidgets('источник без комнаты даёт путь из двух уровней', (tester) async {
      await prefs.setInt('settings.currentSourceId', 10);

      await pump(
        tester,
        const PlacePickerField(),
        sites: [_site(1, 'Дача')],
        sources: [_source(10, 1, 'Скважина')],
      );

      expect(find.text('Дача · Скважина'), findsOneWidget);
    });

    testWidgets('удалённый источник не оставляет висеть старый адрес', (tester) async {
      // Выбор в настройках может пережить удаление — это штатное состояние.
      await prefs.setInt('settings.currentSourceId', 999);

      await pump(tester, const PlacePickerField(), sites: [_site(1, 'Дача')]);

      expect(find.text('Не выбрано'), findsOneWidget);
    });

    testWidgets('подпись про координаты показывается, когда она передана', (tester) async {
      await pump(tester, const PlacePickerField(hint: 'определено по координатам, 40 м'));

      expect(find.text('определено по координатам, 40 м'), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('без подписи лишней строки не появляется', (tester) async {
      await pump(tester, const PlacePickerField());

      expect(find.byIcon(Icons.my_location), findsNothing);
    });
  });

  group('лист выбора', () {
    final home = _site(1, 'Дом');
    final dacha = _site(2, 'Дача', city: 'Тверь', latitude: 56.85);
    final kitchen = _room(5, 1, 'Кухня');
    final filter = _source(10, 1, 'Фильтр', roomId: 5);
    final aquarium = _source(11, 1, 'Аквариум', roomId: 5);
    final well = _source(12, 2, 'Скважина');

    Future<void> openSheet(WidgetTester tester, {String tapOn = 'Не выбрано'}) async {
      await tester.tap(find.text(tapOn));
      await tester.pumpAndSettle();
    }

    testWidgets('группирует источники по местам и комнатам', (tester) async {
      await pump(
        tester,
        const PlacePickerField(),
        sites: [home, dacha],
        rooms: [kitchen],
        sources: [filter, aquarium, well],
      );
      await openSheet(tester);

      expect(find.text('Дом'), findsOneWidget);
      expect(find.text('Кухня'), findsOneWidget);
      // Кухня с фильтром и аквариумом — сценарий из задания дословно.
      expect(find.text('Фильтр'), findsOneWidget);
      expect(find.text('Аквариум'), findsOneWidget);
      expect(find.text('Скважина'), findsOneWidget);
    });

    testWidgets('город показывается рядом с местом, когда задан', (tester) async {
      await pump(tester, const PlacePickerField(), sites: [dacha], sources: [well]);
      await openSheet(tester);

      expect(find.text('Дача · Тверь'), findsOneWidget);
    });

    testWidgets('привязанное место помечено значком', (tester) async {
      await pump(tester, const PlacePickerField(), sites: [home, dacha], sources: [filter, well]);
      await openSheet(tester);

      // Только у дачи задан якорь, у дома — нет.
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('выбор источника записывается в настройки', (tester) async {
      await pump(tester, const PlacePickerField(), sites: [dacha], sources: [well]);
      await openSheet(tester);
      await tester.tap(find.text('Скважина'));
      await tester.pumpAndSettle();

      expect(prefs.getInt('settings.currentSourceId'), 12);
      expect(find.text('Дача · Скважина'), findsOneWidget);
    });

    testWidgets('выбор отмечает источник использованным', (tester) async {
      await pump(tester, const PlacePickerField(), sites: [dacha], sources: [well]);
      await openSheet(tester);
      await tester.tap(find.text('Скважина'));
      await tester.pumpAndSettle();

      verify(() => catalog.markSourceUsed(12)).called(1);
    });

    testWidgets('сбой отметки не отменяет сам выбор', (tester) async {
      // Порядок списка не стоит того, чтобы отказывать в выбранном источнике.
      when(() => catalog.markSourceUsed(any())).thenThrow(Exception('БД недоступна'));

      await pump(tester, const PlacePickerField(), sites: [dacha], sources: [well]);
      await openSheet(tester);
      await tester.tap(find.text('Скважина'));
      await tester.pumpAndSettle();

      expect(prefs.getInt('settings.currentSourceId'), 12);
    });

    testWidgets('«Без адреса» — осознанный выбор, а не отсутствие выбора', (tester) async {
      await prefs.setInt('settings.currentSourceId', 12);

      await pump(tester, const PlacePickerField(), sites: [dacha], sources: [well]);
      await openSheet(tester, tapOn: 'Дача · Скважина');
      await tester.tap(find.text('Без адреса'));
      await tester.pumpAndSettle();

      expect(prefs.getInt('settings.currentSourceId'), isNull);
      expect(find.text('Не выбрано'), findsOneWidget);
    });

    testWidgets('закрытый лист выбор не меняет', (tester) async {
      // Отличие «закрыли» от «выбрали без адреса» — ради него в PlaceSelection
      // отдельный тип вместо голого int?.
      await prefs.setInt('settings.currentSourceId', 12);

      await pump(tester, const PlacePickerField(), sites: [dacha], sources: [well]);
      await openSheet(tester, tapOn: 'Дача · Скважина');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(prefs.getInt('settings.currentSourceId'), 12);
      verifyNever(() => catalog.markSourceUsed(any()));
    });

    testWidgets('выбранный источник отмечен в списке', (tester) async {
      await prefs.setInt('settings.currentSourceId', 12);

      await pump(tester, const PlacePickerField(), sites: [dacha], sources: [well]);
      await openSheet(tester, tapOn: 'Дача · Скважина');

      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });
  });
}
