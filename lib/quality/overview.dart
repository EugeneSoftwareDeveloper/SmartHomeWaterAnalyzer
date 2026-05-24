import 'catalog.dart';
import 'parameter.dart';
import 'zone.dart';

/// Сводная оценка качества воды по всем параметрам сразу.
///
/// Стратегия: берём худшую категорию среди всех параметров — если хоть один в зоне
/// `danger`, общая оценка `danger`. Это сознательное упрощение: для питьевой воды лучше
/// перестраховаться, чем усреднять «опасный pH компенсируется хорошим ORP».
class WaterQualityOverview {
  final QualityCategory worstCategory;
  final List<WaterParameter> problematicParameters;
  final int totalParameters;

  const WaterQualityOverview({
    required this.worstCategory,
    required this.problematicParameters,
    required this.totalParameters,
  });

  /// Все параметры в норме (excellent/good)?
  bool get isAllGood =>
      worstCategory == QualityCategory.excellent || worstCategory == QualityCategory.good;

  /// Краткий заголовок для hero-карточки.
  String get headline {
    return switch (worstCategory) {
      QualityCategory.excellent => 'Отличное качество воды',
      QualityCategory.good => 'Хорошее качество воды',
      QualityCategory.acceptable => 'Приемлемое качество воды',
      QualityCategory.caution => 'Требует внимания',
      QualityCategory.danger => 'Опасное качество воды',
    };
  }

  /// Текст-подсказка под заголовком.
  String get description {
    if (isAllGood) {
      return 'Все измеренные параметры в пределах нормы.';
    }
    if (problematicParameters.isEmpty) {
      return 'Все параметры измерены.';
    }
    final names = problematicParameters.map((item) => item.label).join(', ');
    return 'Вне нормы: $names';
  }

  /// Считает оценку по [values] (map по [WaterParameter.key]). Параметры, для которых
  /// нет значения, в расчёт не идут.
  static WaterQualityOverview compute(Map<String, double> values) {
    var worst = QualityCategory.excellent;
    final problematic = <WaterParameter>[];
    var total = 0;

    for (final parameter in WaterParameterCatalog.all) {
      final value = values[parameter.key];
      if (value == null) continue;
      total++;
      final category = parameter.zoneFor(value).category;
      if (category.index < worst.index) {
        worst = category;
      }
      if (category == QualityCategory.danger || category == QualityCategory.caution) {
        problematic.add(parameter);
      }
    }

    return WaterQualityOverview(
      worstCategory: worst,
      problematicParameters: problematic,
      totalParameters: total,
    );
  }
}
