import 'dart:math' as math;

import 'geo_distance.dart';
import 'measurement_location.dart';

/// Точка привязки места и её накопленная надёжность.
///
/// Якорь не задаётся раз и навсегда: он уточняется каждым новым замером,
/// сохранённым в этом месте. Поэтому кроме координат нужны [accuracyMeters]
/// (насколько якорю можно верить) и [samples] (из скольких фиксов он сложился).
class SiteAnchor {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final int samples;

  const SiteAnchor({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.samples,
  });

  /// Ниже этого значения точность не опускаем. Платформа иногда рапортует
  /// единицы метров и даже нули; без пола вес такого фикса ушёл бы в
  /// бесконечность и один случайный замер намертво зафиксировал бы якорь.
  static const double accuracyFloorMeters = 5;

  /// Насколько далеко фикс может отстоять от якоря и всё ещё считаться этим же
  /// местом при обучении. Шире радиуса места намеренно: замер у калитки —
  /// это всё ещё дача, а вот фикс из другого города в якорь пускать нельзя.
  static double outlierGateMeters(double radiusMeters) =>
      radiusMeters * 3 > 500 ? radiusMeters * 3 : 500;

  double get _weight {
    final effective = accuracyMeters < accuracyFloorMeters ? accuracyFloorMeters : accuracyMeters;
    return 1 / (effective * effective);
  }
}

/// Уточняет якорь новым фиксом.
///
/// Возвращает [current] без изменений, если фикс — выброс: пользователь мог
/// выбрать место руками, находясь в другом городе, и такой замер не должен
/// утаскивать якорь за собой.
SiteAnchor updateAnchor(SiteAnchor? current, MeasurementLocation fix, {double radiusMeters = 150}) {
  final fixAccuracy = fix.accuracyMeters ?? SiteAnchor.accuracyFloorMeters;

  if (current == null) {
    return SiteAnchor(
      latitude: fix.latitude,
      longitude: fix.longitude,
      accuracyMeters: fixAccuracy,
      samples: 1,
    );
  }

  final distance = distanceMeters(current.latitude, current.longitude, fix.latitude, fix.longitude);
  if (distance > SiteAnchor.outlierGateMeters(radiusMeters)) return current;

  // Среднее, взвешенное по 1/точность²: фикс по спутникам с погрешностью 5 м
  // должен двигать якорь заметно сильнее, чем сетевой с погрешностью 500 м.
  final incoming = SiteAnchor(
    latitude: fix.latitude,
    longitude: fix.longitude,
    accuracyMeters: fixAccuracy,
    samples: 1,
  );

  final currentWeight = current._weight * current.samples;
  final incomingWeight = incoming._weight;
  final total = currentWeight + incomingWeight;

  return SiteAnchor(
    latitude: (current.latitude * currentWeight + fix.latitude * incomingWeight) / total,
    longitude: (current.longitude * currentWeight + fix.longitude * incomingWeight) / total,
    // Точность якоря растёт как у среднего: чем больше согласных фиксов, тем
    // увереннее оценка. sqrt(1/сумма весов) — стандартная ошибка среднего.
    accuracyMeters: _standardError(total),
    samples: current.samples + 1,
  );
}

/// Собирает якорь из уже накопленных фиксов — для одноразового заполнения при
/// обновлении, когда история замеров есть, а мест ещё нет.
///
/// Возвращает `null`, если фиксы разбросаны: у пользователя с историей и дома,
/// и на даче центроид оказался бы посреди поля между ними, и автовыбор
/// стабильно ошибался бы. Лучше не привязывать вовсе — якорь появится сам при
/// первом же сохранении.
SiteAnchor? anchorFromFixes(
  List<MeasurementLocation> fixes, {
  double clusterRadiusMeters = 200,
  double requiredShare = 0.8,
}) {
  if (fixes.isEmpty) return null;

  final medianLat = _median(fixes.map((f) => f.latitude).toList());
  final medianLon = _median(fixes.map((f) => f.longitude).toList());

  // Медиана, а не среднее: она не уезжает от одного далёкого выброса, а именно
  // выбросы и надо здесь распознать.
  final clustered = fixes
      .where(
        (f) => distanceMeters(medianLat, medianLon, f.latitude, f.longitude) <= clusterRadiusMeters,
      )
      .toList();

  if (clustered.length < fixes.length * requiredShare) return null;

  SiteAnchor? anchor;
  for (final fix in clustered) {
    anchor = updateAnchor(anchor, fix, radiusMeters: clusterRadiusMeters);
  }
  return anchor;
}

/// Стандартная ошибка среднего для весов 1/точность²: чем больше согласных
/// фиксов вошло в якорь, тем меньше остаточная неопределённость.
double _standardError(double totalWeight) => totalWeight <= 0 ? 0 : 1 / math.sqrt(totalWeight);

double _median(List<double> values) {
  final sorted = [...values]..sort();
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
}
