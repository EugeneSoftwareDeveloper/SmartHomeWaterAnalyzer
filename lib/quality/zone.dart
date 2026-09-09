import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Один цветной диапазон на шкале параметра: [min, max] и категория качества.
class QualityZone {
  final double min;
  final double max;
  final QualityCategory category;
  final String label;

  const QualityZone({
    required this.min,
    required this.max,
    required this.category,
    required this.label,
  });

  bool contains(double value) => value >= min && value < max;

  Color get color => category.color;
}

/// Категории качества: цвет для подсветки значения и порядок «хуже — лучше».
///
/// Названия категорий живут в словаре, а не здесь: `enum` — это константы, а
/// перевод зависит от языка, выбранного в рантайме. Читать их следует через
/// [QualityCategoryText.label].
enum QualityCategory {
  danger(Color(0xFFD32F2F)),
  caution(Color(0xFFF57C00)),
  acceptable(Color(0xFFFBC02D)),
  good(Color(0xFF388E3C)),
  excellent(Color(0xFF1976D2));

  const QualityCategory(this.color);

  final Color color;

  /// Порядок категорий от худшей к лучшей: `danger` < `caution` < `acceptable`
  /// < `good` < `excellent`. По нему тренд решает, стало лучше или хуже.
  ///
  /// Задан явным switch, а не через `index`, потому что порядок объявления
  /// в enum однажды переставят — например, вставив категорию в середину, — и
  /// сравнение по `index` молча начнёт врать. Здесь компилятор потребует
  /// дописать новую категорию.
  int get rank => switch (this) {
    QualityCategory.danger => 0,
    QualityCategory.caution => 1,
    QualityCategory.acceptable => 2,
    QualityCategory.good => 3,
    QualityCategory.excellent => 4,
  };
}

/// Название категории на языке интерфейса.
extension QualityCategoryText on QualityCategory {
  String label(AppL10n l10n) => switch (this) {
    QualityCategory.danger => l10n.categoryDanger,
    QualityCategory.caution => l10n.categoryCaution,
    QualityCategory.acceptable => l10n.categoryAcceptable,
    QualityCategory.good => l10n.categoryGood,
    QualityCategory.excellent => l10n.categoryExcellent,
  };
}
