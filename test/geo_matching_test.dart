import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/location/geo_distance.dart';
import 'package:water_analyzer/location/measurement_location.dart';
import 'package:water_analyzer/location/site_anchor.dart';
import 'package:water_analyzer/location/site_match.dart';

/// Географическая часть привязки мест: расстояния, распознавание места по
/// координатам и обучение якоря.
///
/// Всё чистые функции без `geolocator` — по правилу проекта плагин не выходит
/// за `location_service.dart`, и благодаря этому проверяется без устройства.
void main() {
  group('distanceMeters', () {
    test('расстояние до самой себя равно нулю', () {
      expect(distanceMeters(55.75, 37.62, 55.75, 37.62), 0);
    });

    test('градус широты — примерно 111 км', () {
      final distance = distanceMeters(55.0, 37.62, 56.0, 37.62);

      expect(distance, closeTo(111195, 500));
    });

    test('соседние дома — десятки метров', () {
      // Четвёртый знак после запятой в широте — это около 11 метров.
      final distance = distanceMeters(55.7500, 37.6200, 55.7505, 37.6200);

      expect(distance, closeTo(55, 5));
    });

    test('симметрично относительно перестановки точек', () {
      final ab = distanceMeters(55.75, 37.62, 56.85, 35.90);
      final ba = distanceMeters(56.85, 35.90, 55.75, 37.62);

      expect(ab, closeTo(ba, 1e-6));
    });

    test('Москва — Тверь примерно 161 км по большому кругу', () {
      // Не путать с расхожими «150 км»: то расстояние по трассе. По прямой
      // между центрами городов — около 161 км, и именно это считает гаверсинус.
      final distance = distanceMeters(55.7558, 37.6173, 56.8587, 35.9176);

      expect(distance, closeTo(161300, 500));
    });

    test('работает через нулевой меридиан', () {
      final distance = distanceMeters(51.5, -0.1, 51.5, 0.1);

      expect(distance, closeTo(13900, 200));
    });

    test('антиподы — половина окружности, без потери точности', () {
      // Ради этого случая взят atan2, а не asin: у asin около единицы
      // катастрофическая потеря точности.
      final distance = distanceMeters(0, 0, 0, 180);

      expect(distance, closeTo(earthRadiusMeters * 3.14159265, 1));
    });
  });

  group('matchSite', () {
    const home = SiteAnchorPoint(
      siteId: 1,
      latitude: 55.7500,
      longitude: 37.6200,
      radiusMeters: 150,
    );
    const dacha = SiteAnchorPoint(
      siteId: 2,
      latitude: 56.8500,
      longitude: 35.9000,
      radiusMeters: 150,
    );

    MeasurementLocation at(double lat, double lon, {double? accuracy}) =>
        MeasurementLocation(latitude: lat, longitude: lon, accuracyMeters: accuracy);

    test('пустой список мест не даёт совпадения', () {
      expect(matchSite(const [], at(55.75, 37.62)), isNull);
    });

    test('находит место, рядом с которым стоим', () {
      final match = matchSite(const [home, dacha], at(55.7501, 37.6201));

      expect(match, isNotNull);
      expect(match!.siteId, 1);
      expect(match.distanceMeters, lessThan(50));
    });

    test('вдали от всех мест совпадения нет', () {
      expect(matchSite(const [home, dacha], at(59.93, 30.33)), isNull);
    });

    test('погрешность фикса расширяет радиус', () {
      // 300 метров от дома при радиусе 150 — мимо. Но если сам фикс известен
      // с точностью ±250 м, отвергать его нельзя: именно в помещении, где GPS
      // хуже всего, автовыбор нужен больше всего.
      final without = matchSite(const [home], at(55.7527, 37.6200));
      final with_ = matchSite(const [home], at(55.7527, 37.6200, accuracy: 250));

      expect(without, isNull);
      expect(with_, isNotNull);
    });

    test('из двух кандидатов выбирается явно ближайший', () {
      const neighbour = SiteAnchorPoint(
        siteId: 3,
        latitude: 55.7520,
        longitude: 37.6200,
        radiusMeters: 150,
      );

      final match = matchSite(const [home, neighbour], at(55.7500, 37.6200));

      expect(match!.siteId, 1);
    });

    test('при сопоставимой близости выбор не делается', () {
      // Две квартиры в соседних домах: молча подменять одну другой хуже, чем
      // не подставлять ничего — ошибку пользователь заметит не сразу.
      const first = SiteAnchorPoint(
        siteId: 1,
        latitude: 55.7500,
        longitude: 37.6200,
        radiusMeters: 150,
      );
      const second = SiteAnchorPoint(
        siteId: 2,
        latitude: 55.7502,
        longitude: 37.6200,
        radiusMeters: 150,
      );

      final match = matchSite(const [first, second], at(55.7501, 37.6200));

      expect(match, isNull, reason: 'кандидаты почти одинаково близки');
    });

    test('точное попадание в якорь выигрывает всегда', () {
      const other = SiteAnchorPoint(
        siteId: 2,
        latitude: 55.7501,
        longitude: 37.6200,
        radiusMeters: 150,
      );

      final match = matchSite(const [home, other], at(55.7500, 37.6200));

      expect(match!.siteId, 1);
    });
  });

  group('updateAnchor', () {
    MeasurementLocation fix(double lat, double lon, double accuracy) =>
        MeasurementLocation(latitude: lat, longitude: lon, accuracyMeters: accuracy);

    test('первый фикс задаёт якорь целиком', () {
      final anchor = updateAnchor(null, fix(55.75, 37.62, 12));

      expect(anchor.latitude, 55.75);
      expect(anchor.longitude, 37.62);
      expect(anchor.samples, 1);
    });

    test('второй фикс уточняет якорь и увеличивает счётчик', () {
      final first = updateAnchor(null, fix(55.7500, 37.6200, 10));
      final second = updateAnchor(first, fix(55.7502, 37.6200, 10));

      expect(second.samples, 2);
      expect(second.latitude, greaterThan(55.7500));
      expect(second.latitude, lessThan(55.7502));
    });

    test('точный фикс тянет якорь сильнее неточного', () {
      final base = updateAnchor(null, fix(55.7500, 37.6200, 100));
      final precise = updateAnchor(base, fix(55.7510, 37.6200, 5));

      // Точный фикс весит в 400 раз больше (1/5² против 1/100²), поэтому
      // якорь должен уехать почти к нему.
      expect(precise.latitude, closeTo(55.7510, 0.0002));
    });

    test('выброс из другого города якорь не двигает', () {
      final base = updateAnchor(null, fix(55.7500, 37.6200, 10));
      final afterOutlier = updateAnchor(base, fix(56.8500, 35.9000, 10));

      expect(afterOutlier.latitude, base.latitude);
      expect(afterOutlier.samples, base.samples, reason: 'выброс не считается наблюдением');
    });

    test('фикс без сообщённой точности не обнуляет вес', () {
      final anchor = updateAnchor(
        null,
        const MeasurementLocation(latitude: 55.75, longitude: 37.62),
      );

      expect(anchor.accuracyMeters, SiteAnchor.accuracyFloorMeters);
    });

    test('точность якоря растёт с числом согласных фиксов', () {
      var anchor = updateAnchor(null, fix(55.7500, 37.6200, 20));
      final afterFirst = anchor.accuracyMeters;

      for (var i = 0; i < 5; i++) {
        anchor = updateAnchor(anchor, fix(55.7500, 37.6200, 20));
      }

      expect(anchor.accuracyMeters, lessThan(afterFirst));
    });
  });

  group('anchorFromFixes', () {
    MeasurementLocation fix(double lat, double lon) =>
        MeasurementLocation(latitude: lat, longitude: lon, accuracyMeters: 15);

    test('пустая история якоря не даёт', () {
      expect(anchorFromFixes(const []), isNull);
    });

    test('плотная кучка фиксов даёт якорь в её центре', () {
      final anchor = anchorFromFixes([
        fix(55.7500, 37.6200),
        fix(55.7501, 37.6201),
        fix(55.7499, 37.6199),
      ]);

      expect(anchor, isNotNull);
      expect(anchor!.latitude, closeTo(55.75, 0.001));
    });

    test('фиксы из двух городов якоря не дают', () {
      // Центроид оказался бы посреди поля между ними, и автовыбор стабильно
      // ошибался бы. Лучше не привязывать вовсе.
      final anchor = anchorFromFixes([
        fix(55.7500, 37.6200),
        fix(55.7501, 37.6201),
        fix(56.8500, 35.9000),
        fix(56.8501, 35.9001),
      ]);

      expect(anchor, isNull);
    });

    test('одиночный выброс не мешает, если основная масса кучкуется', () {
      final anchor = anchorFromFixes([
        fix(55.7500, 37.6200),
        fix(55.7501, 37.6201),
        fix(55.7499, 37.6199),
        fix(55.7500, 37.6202),
        fix(55.7501, 37.6200),
        fix(56.8500, 35.9000),
      ]);

      expect(anchor, isNotNull);
      expect(anchor!.latitude, closeTo(55.75, 0.001), reason: 'выброс не утащил якорь');
    });
  });
}
