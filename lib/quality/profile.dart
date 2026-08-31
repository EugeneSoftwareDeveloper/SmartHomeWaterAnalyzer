/// Профили норм качества воды. Зоны параметров зависят от сценария использования:
/// у питьевой и аквариумной воды кардинально разные «хорошие» диапазоны.
enum NormsProfile {
  drinking,
  pool,
  aquariumFresh,
  hydroponics;

  /// Локализованное имя берётся из `AppL10n` в UI; здесь — fallback на случай тестов.
  String get fallbackLabel => switch (this) {
        NormsProfile.drinking => 'Питьевая вода',
        NormsProfile.pool => 'Бассейн',
        NormsProfile.aquariumFresh => 'Аквариум (пресный)',
        NormsProfile.hydroponics => 'Гидропоника',
      };

  /// Разбирает имя профиля, сохранённое в записи истории.
  ///
  /// Возвращает `fallback`, если имя пустое (замер сделан до версии 1.2.0, когда
  /// профиль ещё не сохранялся) или неизвестное (запись из более новой версии
  /// приложения, где профилей стало больше). Оба случая означают одно: судить
  /// замер приходится по текущей настройке — так же, как это делалось раньше.
  static NormsProfile resolve(String? storedName, {required NormsProfile fallback}) {
    if (storedName == null || storedName.isEmpty) return fallback;

    for (final profile in NormsProfile.values) {
      if (profile.name == storedName) return profile;
    }
    return fallback;
  }
}
