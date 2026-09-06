import 'geo_distance.dart';
import 'measurement_location.dart';

/// Место с известной точкой привязки — вход для сопоставления.
///
/// Отдельный тип, а не строка таблицы: сопоставление обязано быть чистым, без
/// drift и без Flutter, чтобы его можно было проверить без устройства и без БД.
class SiteAnchorPoint {
  final int siteId;
  final double latitude;
  final double longitude;

  /// Радиус, в пределах которого координаты считаются принадлежащими месту.
  final double radiusMeters;

  const SiteAnchorPoint({
    required this.siteId,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
}

/// Место, распознанное по координатам.
class SiteMatch {
  final int siteId;

  /// Расстояние до якоря в метрах — показывается пользователю, чтобы
  /// подстановка не выглядела необъяснимой.
  final double distanceMeters;

  const SiteMatch({required this.siteId, required this.distanceMeters});
}

/// Насколько ближайшее место должно опережать следующее, чтобы выбор считался
/// однозначным. Две квартиры в соседних домах не должны молча подменять друг
/// друга: если оба кандидата примерно одинаково близки, честнее не выбирать
/// ничего, чем выбрать наугад и заставить пользователя это замечать.
const double _unambiguousRatio = 2;

/// Определяет место по координатам.
///
/// Возвращает `null`, если подходящего места нет или выбор неоднозначен.
///
/// Погрешность фикса складывается с радиусом места: при точности в сотню метров
/// требовать попадания в радиус 150 м значило бы не срабатывать ровно там, где
/// автовыбор нужнее всего — в помещении, где GPS хуже всего.
SiteMatch? matchSite(List<SiteAnchorPoint> anchors, MeasurementLocation position) {
  if (anchors.isEmpty) return null;

  final accuracy = position.accuracyMeters ?? 0;
  final candidates = <SiteMatch>[];

  for (final anchor in anchors) {
    final distance = distanceMeters(
      anchor.latitude,
      anchor.longitude,
      position.latitude,
      position.longitude,
    );
    if (distance <= anchor.radiusMeters + accuracy) {
      candidates.add(SiteMatch(siteId: anchor.siteId, distanceMeters: distance));
    }
  }

  if (candidates.isEmpty) return null;
  if (candidates.length == 1) return candidates.first;

  candidates.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  final nearest = candidates[0];
  final runnerUp = candidates[1];

  // Ноль в знаменателе не нужен: если ближайшее место буквально под ногами,
  // оно и есть ответ.
  if (nearest.distanceMeters == 0) return nearest;

  return runnerUp.distanceMeters >= nearest.distanceMeters * _unambiguousRatio ? nearest : null;
}
