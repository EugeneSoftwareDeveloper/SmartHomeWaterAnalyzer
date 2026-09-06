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

  /// Координаты для автоопределения места — **без запроса разрешения**.
  ///
  /// Возвращает `null`, если разрешения ещё нет, служба выключена или фикс не
  /// пришёл. Отдельный метод нужен именно ради отсутствия системного диалога:
  /// автовыбор срабатывает при каждом чтении показаний, и просить разрешение
  /// там значило бы перенести диалог с осознанного «Сохранить» на открытие
  /// экрана — приложение стало бы навязчивее ровно там, где обещало не мешать.
  ///
  /// Ждёт меньше обычного: подстановка места — удобство, и задерживать ради неё
  /// показания незачем.
  Future<MeasurementLocation?> currentLocationIfGranted({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      final permission = await Geolocator.checkPermission();
      final granted =
          permission == LocationPermission.always || permission == LocationPermission.whileInUse;
      if (!granted) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: defaultAccuracy, timeLimit: timeout),
      );

      return MeasurementLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
    } on Object catch (_) {
      // Автовыбор — украшение поверх показаний: любая проблема означает просто
      // «место не определилось», а не ошибку, о которой стоит сообщать.
      return null;
    }
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
