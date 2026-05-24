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
}
