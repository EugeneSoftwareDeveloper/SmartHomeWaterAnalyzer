import 'database.dart';
import 'measurement_place.dart';

/// Каталог мест целиком: места, комнаты и источники вместе.
///
/// Три таблицы приходят из БД тремя независимыми стримами, а интерфейсу почти
/// всегда нужна их связка — «какие источники у этого места», «какой полный адрес
/// у этого источника». Собирать это в каждом виджете значило бы размазать одни и
/// те же join'ы по экранам и потерять возможность проверить их без `WidgetTester`.
///
/// Тип неизменяемый и чистый: ни drift-запросов, ни Flutter. Индексы строятся
/// один раз в конструкторе, потому что список выбора обращается к ним на каждый
/// кадр прокрутки.
class PlaceCatalog {
  final List<Site> sites;
  final List<Room> rooms;
  final List<SamplingPoint> sources;

  final Map<int, Site> _sitesById;
  final Map<int, Room> _roomsById;
  final Map<int, SamplingPoint> _sourcesById;

  PlaceCatalog({required this.sites, required this.rooms, required this.sources})
    : _sitesById = {for (final site in sites) site.id: site},
      _roomsById = {for (final room in rooms) room.id: room},
      _sourcesById = {for (final source in sources) source.id: source};

  static final PlaceCatalog empty = PlaceCatalog(sites: [], rooms: [], sources: []);

  bool get isEmpty => sources.isEmpty && sites.isEmpty;

  Site? siteById(int? id) => id == null ? null : _sitesById[id];

  Room? roomById(int? id) => id == null ? null : _roomsById[id];

  SamplingPoint? sourceById(int? id) => id == null ? null : _sourcesById[id];

  /// Комнаты одного места — в том же порядке, в каком пришли из БД
  /// (недавно использованные сверху).
  List<Room> roomsOfSite(int siteId) =>
      rooms.where((room) => room.siteId == siteId).toList(growable: false);

  /// Источники, висящие прямо на месте, без комнаты.
  List<SamplingPoint> sourcesDirectlyOnSite(int siteId) => sources
      .where((source) => source.siteId == siteId && source.roomId == null)
      .toList(growable: false);

  List<SamplingPoint> sourcesOfRoom(int roomId) =>
      sources.where((source) => source.roomId == roomId).toList(growable: false);

  /// Все источники места — и в комнатах, и без них.
  List<SamplingPoint> sourcesOfSite(int siteId) =>
      sources.where((source) => source.siteId == siteId).toList(growable: false);

  /// Полный адрес источника: имена места, комнаты и его собственное.
  ///
  /// Именно эти имена уезжают в замер, поэтому здесь собирается ровно то, что
  /// потом окажется в истории.
  MeasurementPlace placeOf(SamplingPoint source) {
    return MeasurementPlace(
      siteName: siteById(source.siteId)?.name,
      roomName: roomById(source.roomId)?.name,
      sourceName: source.name,
    );
  }

  /// Адрес по ссылке на источник. `null`, если источник удалили — выбор в
  /// настройках может пережить удаление, и это нормальное состояние.
  MeasurementPlace? placeOfSourceId(int? sourceId) {
    final source = sourceById(sourceId);
    return source == null ? null : placeOf(source);
  }

  /// Самый свежий источник места — то, что подставляется, когда место
  /// определилось по координатам. При единственном источнике это он и есть,
  /// а такой случай пользователь назвал самым частым.
  SamplingPoint? mostRecentSourceOfSite(int siteId) {
    final candidates = sourcesOfSite(siteId);
    if (candidates.isEmpty) return null;

    // Список уже отсортирован «недавние сверху», но сортировка глобальная:
    // внутри одного места порядок сохраняется, поэтому берём первый.
    return candidates.first;
  }
}
