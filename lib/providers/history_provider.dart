import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../history/database.dart';
import '../history/place_catalog.dart';
import '../history/repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(appDatabaseProvider)),
);

final recentMeasurementsProvider = StreamProvider<List<Measurement>>(
  (ref) => ref.watch(historyRepositoryProvider).watchRecent(),
);

final placeCatalogProvider = Provider<PlaceCatalogRepository>(
  (ref) => PlaceCatalogRepository(ref.watch(appDatabaseProvider)),
);

/// Места (дом, дача) — верхний уровень каталога. Недавно использованные сверху.
final sitesProvider = StreamProvider<List<Site>>(
  (ref) => ref.watch(placeCatalogProvider).watchSites(),
);

/// Комнаты всех мест одним списком. Разложить по местам дешевле в UI, чем держать
/// провайдер-семейство на каждое место: комнат единицы, а перестройка списка при
/// смене места стоила бы отдельной подписки.
final roomsProvider = StreamProvider<List<Room>>(
  (ref) => ref.watch(placeCatalogProvider).watchRooms(),
);

/// Источники всех мест одним списком — по той же причине, что и комнаты.
final sourcesProvider = StreamProvider<List<SamplingPoint>>(
  (ref) => ref.watch(placeCatalogProvider).watchSources(),
);

/// Каталог целиком — места, комнаты и источники, собранные вместе.
///
/// Три отдельных стрима сводятся здесь, а не в виджетах: почти каждому экрану
/// нужна их связка, и повторять сведение в каждом значило бы размазать одни и те
/// же join'ы по интерфейсу.
///
/// Состояния трёх источников сводятся честно: ошибка любого — ошибка целого,
/// загрузка любого — загрузка целого. Подменять недогруженный стрим пустым
/// списком нельзя: список выбора показал бы «мест нет» там, где они просто
/// ещё не приехали.
final placeCatalogViewProvider = Provider<AsyncValue<PlaceCatalog>>((ref) {
  final sites = ref.watch(sitesProvider);
  final rooms = ref.watch(roomsProvider);
  final sources = ref.watch(sourcesProvider);

  for (final part in [sites, rooms, sources]) {
    if (part.hasError) {
      return AsyncValue<PlaceCatalog>.error(part.error!, part.stackTrace ?? StackTrace.current);
    }
  }

  final siteRows = sites.valueOrNull;
  final roomRows = rooms.valueOrNull;
  final sourceRows = sources.valueOrNull;
  if (siteRows == null || roomRows == null || sourceRows == null) {
    return const AsyncValue<PlaceCatalog>.loading();
  }

  return AsyncValue<PlaceCatalog>.data(
    PlaceCatalog(sites: siteRows, rooms: roomRows, sources: sourceRows),
  );
});
