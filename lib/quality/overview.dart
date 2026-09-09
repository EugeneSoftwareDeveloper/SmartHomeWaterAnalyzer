import '../l10n/generated/app_localizations.dart';
import 'catalog.dart';
import 'parameter.dart';
import 'profile.dart';
import 'zone.dart';

/// Сводная оценка качества воды по всем параметрам сразу.
///
/// Стратегия: берём худшую категорию среди всех параметров — если хоть один в зоне `danger`,
/// общая оценка `danger`. Это сознательное упрощение: лучше перестраховаться, чем усреднять
/// «опасный pH компенсируется хорошим ORP».
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

  String headline(AppL10n l10n) {
    return switch (worstCategory) {
      QualityCategory.excellent => l10n.qualityExcellent,
      QualityCategory.good => l10n.qualityGood,
      QualityCategory.acceptable => l10n.qualityAcceptable,
      QualityCategory.caution => l10n.qualityCaution,
      QualityCategory.danger => l10n.qualityDanger,
    };
  }

  String description(AppL10n l10n) {
    if (isAllGood) return l10n.summaryAllGood;
    if (problematicParameters.isEmpty) return l10n.summaryAllMeasured;
    return l10n.summaryProblematic(problematicParameters.map((item) => item.shortLabel).join(', '));
  }

  /// Считает оценку по [values] (map по [WaterParameter.key]) для конкретного [profile].
  /// Параметры, для которых нет значения, в расчёт не идут.
  static WaterQualityOverview compute(
    Map<String, double> values, {
    required AppL10n l10n,
    NormsProfile profile = NormsProfile.drinking,
  }) {
    var worst = QualityCategory.excellent;
    final problematic = <WaterParameter>[];
    var total = 0;

    for (final parameter in WaterParameterCatalog.forProfile(profile, l10n)) {
      final value = values[parameter.key];
      if (value == null) continue;
      total++;
      final category = parameter.zoneFor(value).category;
      if (category.index < worst.index) worst = category;
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
