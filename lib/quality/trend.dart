import 'parameter.dart';

/// Куда сдвинулось значение относительно предыдущего замера.
enum TrendDirection { up, down, flat }

/// Что этот сдвиг означает для качества воды.
///
/// Отделено от [TrendDirection] намеренно: «выросло» и «стало лучше» — разные вещи.
/// Рост pH с 6.0 до 7.0 — улучшение, с 8.0 до 9.0 — ухудшение, и стрелка в обоих
/// случаях смотрит вверх.
enum TrendImpact {
  /// Значение перешло в зону лучшей категории.
  improved,

  /// Значение перешло в зону худшей категории.
  worsened,

  /// Категория зоны не изменилась — либо сдвиг мал, либо он внутри одной зоны.
  neutral,
}

/// Изменение одного параметра относительно предыдущего замера.
///
/// Считается только против замера **в том же месте**: без этого кран (pH 7.2),
/// бассейн (7.6) и аквариум (6.8) сравнивались бы между собой, и каждый замер
/// показывал бы фиктивный скачок. Ровно та же причина, по которой в 1.2.0
/// появился фильтр графика по месту.
class ParameterTrend {
  /// Разница «стало минус было», со знаком, в единицах параметра.
  final double delta;

  final TrendDirection direction;
  final TrendImpact impact;

  const ParameterTrend({required this.delta, required this.direction, required this.impact});

  /// Сдвиг меньше погрешности прибора — считаем, что значение не изменилось.
  bool get isFlat => direction == TrendDirection.flat;

  /// Сравнивает текущее значение с предыдущим по нормам [parameter].
  ///
  /// Обе точки судятся по одному и тому же профилю норм — тому, с которым
  /// сделан текущий замер. Иначе смена профиля между замерами сама по себе
  /// «улучшала» или «ухудшала» воду, хотя в стакане ничего не поменялось.
  static ParameterTrend between({
    required WaterParameter parameter,
    required double previous,
    required double current,
  }) {
    final delta = current - previous;

    // Порог — это заявление о том, какую разницу прибор вообще способен различить.
    // Ниже него ни стрелка, ни смена зоны не считаются: pH 7.19 → 7.21 формально
    // пересекает границу «норма → оптимум», но приписывать этому улучшение —
    // выдавать шум электрода за результат.
    if (delta.abs() < parameter.noiseThreshold) {
      return ParameterTrend(
        delta: delta,
        direction: TrendDirection.flat,
        impact: TrendImpact.neutral,
      );
    }

    final before = parameter.zoneFor(previous).category.rank;
    final after = parameter.zoneFor(current).category.rank;

    return ParameterTrend(
      delta: delta,
      direction: delta > 0 ? TrendDirection.up : TrendDirection.down,
      impact: after > before
          ? TrendImpact.improved
          : after < before
          ? TrendImpact.worsened
          : TrendImpact.neutral,
    );
  }
}
