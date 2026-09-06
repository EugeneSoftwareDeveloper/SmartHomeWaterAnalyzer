import 'database.dart';
import 'place_name.dart';

/// Разделитель уровней в отображаемом пути. Точка-посередине, а не дефис или
/// стрелка: она не путается с минусом в числах рядом и не намекает на движение.
const String placeSeparator = ' · ';

/// Адрес замера: место → (комната) → источник.
///
/// Хранит **имена**, а не ссылки на каталог, — тот же инвариант, что и у колонок
/// замера. Переименование места в каталоге не должно менять уже сохранённый адрес.
///
/// Все три уровня необязательны, и каждая комбинация осмысленна:
/// - все три — «Дом · Кухня · Фильтр»;
/// - без комнаты — «Дача · Скважина», источник висит прямо на месте;
/// - только источник — запись до версии 1.4.0, когда иерархии не было;
/// - пусто — замер сохранён без адреса.
class MeasurementPlace {
  final String? siteName;
  final String? roomName;
  final String? sourceName;

  const MeasurementPlace({this.siteName, this.roomName, this.sourceName});

  /// Замер без адреса.
  static const MeasurementPlace none = MeasurementPlace();

  /// Собирает адрес, приводя имена к каноничному виду тем же правилом, которым
  /// они пишутся в базу. Без этого выбранное «` Кулер `» не совпало бы с
  /// сохранённым «`Кулер`» при поиске базы тренда.
  factory MeasurementPlace.normalized({String? siteName, String? roomName, String? sourceName}) {
    return MeasurementPlace(
      siteName: normalizePlaceName(siteName),
      roomName: normalizePlaceName(roomName),
      sourceName: normalizePlaceName(sourceName),
    );
  }

  /// Адрес сохранённого замера.
  factory MeasurementPlace.ofMeasurement(Measurement measurement) {
    return MeasurementPlace(
      siteName: measurement.siteName,
      roomName: measurement.roomName,
      // Источник живёт в колонке label: до версии 1.4.0 она несла плоское имя
      // места, и смысл «что именно измеряли» у неё не изменился. Благодаря
      // этому история до обновления осталась валидной без переписывания.
      sourceName: measurement.label,
    );
  }

  /// Есть ли вообще что показывать.
  bool get isEmpty => siteName == null && roomName == null && sourceName == null;

  bool get isNotEmpty => !isEmpty;

  /// Запись сделана до появления иерархии: источник известен, место — нет.
  bool get isLegacy => siteName == null && sourceName != null;

  /// Путь для показа: «Дом · Кухня · Фильтр». Пустые уровни пропускаются, поэтому
  /// источник без комнаты даёт «Дача · Скважина», а не «Дача ·  · Скважина».
  String get formatted =>
      [siteName, roomName, sourceName].where((part) => part != null).join(placeSeparator);

  /// Короткий вид для тесных мест — источник и, если он есть, место.
  /// Комната опускается: внутри одного места она редко нужна для узнавания.
  String get short => [siteName, sourceName].where((part) => part != null).join(placeSeparator);

  @override
  bool operator ==(Object other) =>
      other is MeasurementPlace &&
      other.siteName == siteName &&
      other.roomName == roomName &&
      other.sourceName == sourceName;

  @override
  int get hashCode => Object.hash(siteName, roomName, sourceName);

  @override
  String toString() => isEmpty ? 'MeasurementPlace(пусто)' : 'MeasurementPlace($formatted)';
}
