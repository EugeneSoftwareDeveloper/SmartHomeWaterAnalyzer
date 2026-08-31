import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/location/measurement_location.dart';
import 'package:water_analyzer/ui/widgets/location_card.dart';

void main() {
  group('MeasurementLocation.fromNullable', () {
    test('обе координаты заданы — объект собирается', () {
      final location = MeasurementLocation.fromNullable(55.76, 37.82);

      expect(location, isNotNull);
      expect(location!.latitude, 55.76);
      expect(location.longitude, 37.82);
    });

    test('нет широты — null (замер без геометки)', () {
      expect(MeasurementLocation.fromNullable(null, 37.82), isNull);
    });

    test('нет долготы — null', () {
      expect(MeasurementLocation.fromNullable(55.76, null), isNull);
    });

    test('нет обеих — null', () {
      expect(MeasurementLocation.fromNullable(null, null), isNull);
    });

    test('координата 0.0 — валидна, это не «нет значения»', () {
      // Гвинейский залив: 0,0 — реальная точка. Проверка на null не должна
      // путать её с отсутствием координат.
      final location = MeasurementLocation.fromNullable(0, 0);

      expect(location, isNotNull);
      expect(location!.formatted, '0.000000, 0.000000');
    });
  });

  group('форматирование', () {
    test('координаты — шесть знаков после точки', () {
      const location = MeasurementLocation(
        latitude: 55.7631176800056,
        longitude: 37.8282875782027,
      );

      expect(location.formatted, '55.763118, 37.828288');
    });

    test('отрицательные координаты сохраняют знак', () {
      const location = MeasurementLocation(latitude: -33.8688, longitude: -70.65);

      expect(location.formatted, '-33.868800, -70.650000');
    });

    test('точность округляется до целых метров', () {
      const location = MeasurementLocation(
        latitude: 55.76,
        longitude: 37.82,
        accuracyMeters: 12.4,
      );

      expect(location.formattedAccuracy, '±12 м');
    });

    test('без точности — null, UI не показывает строку', () {
      const location = MeasurementLocation(latitude: 55.76, longitude: 37.82);

      expect(location.formattedAccuracy, isNull);
    });
  });

  group('mapUris', () {
    const location = MeasurementLocation(
      latitude: 55.7631176800056,
      longitude: 37.8282875782027,
    );

    test('первым идёт geo:-интент, вторым https-fallback', () {
      final uris = mapUris(location);

      expect(uris, hasLength(2));
      expect(uris[0].scheme, 'geo');
      expect(uris[1].scheme, 'https');
      expect(uris[1].host, 'www.google.com');
    });

    test('десятичный разделитель — точка, а не запятая', () {
      // На русской локали toString() мог бы дать «55,76» и сломать разбор ссылки.
      final geo = mapUris(location)[0].toString();

      expect(geo, contains('55.763118'));
      expect(geo, contains('37.828288'));
      expect(geo, isNot(contains('55,763118')));
    });

    test('метка попадает в geo-ссылку и экранируется', () {
      final geo = mapUris(location, label: 'Кухня, кран').toList()[0].toString();

      expect(geo, contains(Uri.encodeComponent('Кухня, кран')));
    });

    test('пустая метка не добавляет пустые скобки', () {
      final geo = mapUris(location, label: '   ')[0].toString();

      expect(geo, isNot(contains('()')));
    });

    test('без метки ссылка остаётся валидной', () {
      final geo = mapUris(location)[0].toString();

      expect(geo, 'geo:55.763118,37.828288?q=55.763118,37.828288');
    });
  });

  group('LocationFailure', () {
    test('у каждой причины есть человеческое объяснение', () {
      for (final failure in LocationFailure.values) {
        expect(failure.message, isNotEmpty, reason: '$failure без сообщения');
        expect(
          failure.message,
          contains('без координат'),
          reason: 'сообщение должно объяснять, что замер сохранён, но без геометки',
        );
      }
    });
  });
}
