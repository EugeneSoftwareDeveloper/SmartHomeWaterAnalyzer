import 'dart:math' as math;

/// Средний радиус Земли в метрах (IUGG). Ошибка сферической модели против
/// эллипсоида — доли процента, а речь о сотнях метров вокруг дома, поэтому
/// точности хватает с запасом.
const double earthRadiusMeters = 6371008.8;

/// Расстояние по большому кругу между двумя точками, в метрах.
///
/// Чистая функция без `geolocator`: по правилу проекта плагин не выходит за
/// пределы `location_service.dart`, иначе привязку мест нельзя было бы
/// протестировать без устройства. Формула — гаверсинус: он устойчив на малых
/// расстояниях, где «плоская» формула через разность координат теряет знаки
/// после запятой, а именно малые расстояния здесь и важны.
double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  final phi1 = _radians(lat1);
  final phi2 = _radians(lat2);
  final deltaPhi = _radians(lat2 - lat1);
  final deltaLambda = _radians(lon2 - lon1);

  final sinHalfPhi = math.sin(deltaPhi / 2);
  final sinHalfLambda = math.sin(deltaLambda / 2);

  final a =
      sinHalfPhi * sinHalfPhi + math.cos(phi1) * math.cos(phi2) * sinHalfLambda * sinHalfLambda;

  // atan2, а не asin(sqrt(a)): у asin катастрофическая потеря точности при a → 1,
  // то есть для почти противоположных точек.
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusMeters * c;
}

double _radians(double degrees) => degrees * math.pi / 180;
