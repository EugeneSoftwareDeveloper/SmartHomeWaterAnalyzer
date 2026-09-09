import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:water_analyzer/location/location_service.dart';
import 'package:water_analyzer/location/measurement_location.dart';

/// Поведение [LocationService] — единственного места, где живёт плагин.
///
/// `Geolocator` вызывается статически, поэтому подменяется его платформенный
/// интерфейс. Без этой подмены ветки разрешений и таймаутов проверялись бы
/// только на устройстве, а именно в них живёт обещание проекта: **геометка
/// никогда не блокирует и не роняет сохранение замера**.
class _MockGeolocator extends Mock with MockPlatformInterfaceMixin implements GeolocatorPlatform {}

Position _position({double accuracy = 12}) {
  return Position(
    latitude: 55.7501,
    longitude: 37.6201,
    timestamp: DateTime.utc(2026, 9, 9),
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

void main() {
  late _MockGeolocator platform;
  const service = LocationService();

  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });

  setUp(() {
    platform = _MockGeolocator();
    GeolocatorPlatform.instance = platform;
  });

  /// Разрешение выдано, служба включена — «всё хорошо» по умолчанию.
  void givenReady() {
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
    when(platform.checkPermission).thenAnswer((_) async => LocationPermission.whileInUse);
  }

  group('currentLocation — путь сохранения замера', () {
    test('отдаёт координаты вместе с точностью', () async {
      givenReady();
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenAnswer((_) async => _position(accuracy: 8));

      final result = await service.currentLocation();

      expect(result.isSuccess, isTrue);
      expect(result.location!.latitude, closeTo(55.7501, 1e-9));
      expect(result.location!.accuracyMeters, 8);
      expect(result.failure, isNull);
    });

    test('выключенная служба — это причина отказа, а не исключение', () async {
      when(platform.isLocationServiceEnabled).thenAnswer((_) async => false);

      final result = await service.currentLocation();

      expect(result.isSuccess, isFalse);
      expect(result.failure, LocationFailure.serviceDisabled);
    });

    test('отказ в разрешении возвращается причиной', () async {
      when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
      when(platform.checkPermission).thenAnswer((_) async => LocationPermission.denied);
      when(platform.requestPermission).thenAnswer((_) async => LocationPermission.denied);

      final result = await service.currentLocation();

      expect(result.failure, LocationFailure.permissionDenied);
    });

    test('навсегда запрещённое разрешение отличается от разового отказа', () async {
      // Разные причины — разный текст подсказки: во втором случае помочь может
      // только переход в системные настройки.
      when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
      when(platform.checkPermission).thenAnswer((_) async => LocationPermission.deniedForever);

      final result = await service.currentLocation();

      expect(result.failure, LocationFailure.permissionPermanentlyDenied);
    });

    test('разрешение запрашивается один раз, без повторов', () async {
      when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
      when(platform.checkPermission).thenAnswer((_) async => LocationPermission.denied);
      when(platform.requestPermission).thenAnswer((_) async => LocationPermission.whileInUse);
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenAnswer((_) async => _position());

      await service.currentLocation();

      verify(platform.requestPermission).called(1);
    });

    test('не пришедший фикс не роняет сохранение', () async {
      givenReady();
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenThrow(TimeoutException('нет фикса'));

      final result = await service.currentLocation();

      expect(result.failure, LocationFailure.unavailable);
    });

    test('любая платформенная ошибка тоже становится причиной, а не исключением', () async {
      // Ключевой инвариант: замер обязан сохраниться даже если геолокация
      // сломалась совершенно неожиданным образом.
      givenReady();
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenThrow(Exception('что-то пошло не так в платформе'));

      final result = await service.currentLocation();

      expect(result.failure, LocationFailure.unavailable);
    });

    test('зависшая платформа обрывается общим бюджетом времени', () async {
      // Отдельно от таймаута на фикс: системный диалог разрешений может висеть
      // сколько угодно, и без общего бюджета кнопка «Сохранить» залипла бы.
      givenReady();
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenAnswer((_) => Completer<Position>().future);

      final result = await service.currentLocation(totalBudget: const Duration(milliseconds: 60));

      expect(result.failure, LocationFailure.unavailable);
    });

    test('у каждой причины отказа есть человеческий текст', () async {
      for (final failure in LocationFailure.values) {
        expect(failure.message, isNotEmpty, reason: failure.name);
      }
    });
  });

  group('currentLocationIfGranted — путь автоподстановки места', () {
    test('НИКОГДА не запрашивает разрешение', () async {
      // Самое важное свойство этого метода. Автоподстановка срабатывает при
      // каждом чтении показаний, и системный диалог там переехал бы с
      // осознанного «Сохранить» на простое открытие экрана.
      when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
      when(platform.checkPermission).thenAnswer((_) async => LocationPermission.denied);

      final result = await service.currentLocationIfGranted();

      expect(result, isNull);
      verifyNever(platform.requestPermission);
    });

    test('без выданного разрешения молчит', () async {
      when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
      when(platform.checkPermission).thenAnswer((_) async => LocationPermission.deniedForever);

      expect(await service.currentLocationIfGranted(), isNull);
      verifyNever(platform.requestPermission);
    });

    test('при выданном разрешении отдаёт координаты', () async {
      givenReady();
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenAnswer((_) async => _position(accuracy: 20));

      final location = await service.currentLocationIfGranted();

      expect(location, isA<MeasurementLocation>());
      expect(location!.accuracyMeters, 20);
    });

    test('выключенная служба — просто отсутствие подстановки', () async {
      when(platform.isLocationServiceEnabled).thenAnswer((_) async => false);

      expect(await service.currentLocationIfGranted(), isNull);
    });

    test('ошибка платформы не всплывает наружу', () async {
      // Подстановка места — украшение поверх показаний: любая проблема означает
      // «место не определилось», а не повод показать ошибку.
      givenReady();
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenThrow(Exception('платформа недоступна'));

      expect(await service.currentLocationIfGranted(), isNull);
    });

    test('ждёт меньше, чем путь сохранения', () async {
      // Показания важнее подсказки, и задерживать их ради неё нельзя.
      givenReady();
      when(
        () => platform.getCurrentPosition(locationSettings: any(named: 'locationSettings')),
      ).thenAnswer((_) async => _position());

      await service.currentLocationIfGranted();

      final settings =
          verify(
                () => platform.getCurrentPosition(
                  locationSettings: captureAny(named: 'locationSettings'),
                ),
              ).captured.single
              as LocationSettings;

      expect(settings.timeLimit, isNotNull);
      expect(settings.timeLimit!, lessThan(LocationService.defaultTimeout));
    });
  });
}
