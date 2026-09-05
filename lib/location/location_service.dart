import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'measurement_location.dart';

/// Получение координат для геометки замера.
///
/// Главное свойство: **никогда не блокирует сохранение замера**. Любой отказ —
/// нет разрешения, выключен GPS, не пришёл фикс — возвращается как
/// [LocationFailure], а замер сохраняется без координат. Поэтому здесь жёсткий
/// таймаут: в помещении (а вода меряется обычно на кухне) фикс может не прийти
/// вовсе, и ждать его дольше нескольких секунд бессмысленно.
class LocationService {
  /// Сколько ждём фикс. Пять секунд — компромисс: холодный старт GPS дольше,
  /// но по сети/Wi-Fi позиция обычно приходит быстрее, а замер важнее координат.
  static const Duration defaultTimeout = Duration(seconds: 5);

  /// Точности достаточно уровня «дом», метровая не нужна и дольше берётся.
  static const LocationAccuracy defaultAccuracy = LocationAccuracy.medium;

  const LocationService();

  /// Общий предел на весь вызов, включая ожидание ответа на системный диалог
  /// разрешений. Без него первое сохранение замера могло зависнуть навсегда:
  /// [defaultTimeout] ограничивает только получение фикса, а `requestPermission`
  /// ждёт пользователя — если он свернёт приложение с открытым диалогом, ответа
  /// не будет вообще.
  static const Duration defaultTotalBudget = Duration(seconds: 30);

  Future<LocationResult> currentLocation({
    Duration timeout = defaultTimeout,
    Duration totalBudget = defaultTotalBudget,
    LocationAccuracy accuracy = defaultAccuracy,
  }) {
    return _currentLocation(timeout: timeout, accuracy: accuracy).timeout(
      totalBudget,
      onTimeout: () {
        return const LocationResult.failed(LocationFailure.unavailable);
      },
    );
  }

  Future<LocationResult> _currentLocation({
    required Duration timeout,
    required LocationAccuracy accuracy,
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.failed(LocationFailure.serviceDisabled);
      }

      final permission = await _ensurePermission();
      if (permission != null) return LocationResult.failed(permission);

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy, timeLimit: timeout),
      );

      return LocationResult.success(
        MeasurementLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
        ),
      );
    } on TimeoutException {
      return const LocationResult.failed(LocationFailure.unavailable);
    } on Object {
      // Платформенные ошибки геолокатора не должны ронять сохранение замера.
      return const LocationResult.failed(LocationFailure.unavailable);
    }
  }

  /// Возвращает `null`, если разрешение есть, иначе — причину отказа.
  Future<LocationFailure?> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => null,
      LocationPermission.deniedForever => LocationFailure.permissionPermanentlyDenied,
      _ => LocationFailure.permissionDenied,
    };
  }
}
