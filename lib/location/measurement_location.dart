/// Координаты, привязанные к замеру.
///
/// Отдельный тип вместо голой пары double нужен, чтобы «нет координат» было
/// одним значением `null`, а не тремя рассинхронизированными полями.
class MeasurementLocation {
  final double latitude;
  final double longitude;

  /// Радиус погрешности в метрах, как его сообщил геолокатор. `null`, если
  /// платформа не дала оценку.
  final double? accuracyMeters;

  const MeasurementLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  /// Собирает координаты из записи истории. Возвращает `null`, если замер сохранён
  /// без геометки — так вызывающему коду не нужно проверять поля по отдельности.
  static MeasurementLocation? fromNullable(
    double? latitude,
    double? longitude, {
    double? accuracyMeters,
  }) {
    if (latitude == null || longitude == null) return null;
    return MeasurementLocation(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
    );
  }

  /// «55.763118, 37.828288» — шесть знаков это ~11 см, заведомо больше точности
  /// бытового GPS, но привычный вид для копирования в карты.
  String get formatted =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Человеческая оценка точности: «±12 м». `null`, если платформа её не дала.
  String? get formattedAccuracy {
    final accuracy = accuracyMeters;
    if (accuracy == null) return null;
    return '±${accuracy.round()} м';
  }
}

/// Почему координаты не получены. UI показывает это один раз подсказкой, чтобы
/// пользователь понимал, почему у замера нет геометки, и мог это починить.
enum LocationFailure {
  /// Пользователь отказал в разрешении (в этот раз — можно спросить снова).
  permissionDenied,

  /// Отказ «навсегда» — спрашивать бесполезно, нужно идти в настройки приложения.
  permissionPermanentlyDenied,

  /// Геолокация выключена в системе.
  serviceDisabled,

  /// Фикс не успел прийти за отведённое время или платформа вернула ошибку.
  unavailable;

  String get message => switch (this) {
        LocationFailure.permissionDenied =>
          'Замер сохранён без координат: нет разрешения на геолокацию.',
        LocationFailure.permissionPermanentlyDenied =>
          'Замер сохранён без координат: доступ к геолокации запрещён. '
              'Разрешить можно в настройках приложения.',
        LocationFailure.serviceDisabled =>
          'Замер сохранён без координат: геолокация выключена в системе.',
        LocationFailure.unavailable =>
          'Замер сохранён без координат: не удалось определить местоположение.',
      };
}

/// Результат попытки получить координаты: либо координаты, либо причина отказа.
/// Оба поля одновременно не заданы никогда.
class LocationResult {
  final MeasurementLocation? location;
  final LocationFailure? failure;

  const LocationResult.success(MeasurementLocation this.location) : failure = null;

  const LocationResult.failed(LocationFailure this.failure) : location = null;

  bool get isSuccess => location != null;
}
