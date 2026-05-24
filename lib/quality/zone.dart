import 'package:flutter/material.dart';

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

/// Категории качества: цвет + текстовая метка. Используется для подсветки текущего
/// значения, бейджа статуса и пояснения «что это значит».
enum QualityCategory {
  danger(Color(0xFFD32F2F), 'Опасно'),
  caution(Color(0xFFF57C00), 'Внимание'),
  acceptable(Color(0xFFFBC02D), 'Приемлемо'),
  good(Color(0xFF388E3C), 'Хорошо'),
  excellent(Color(0xFF1976D2), 'Отлично');

  const QualityCategory(this.color, this.label);

  final Color color;
  final String label;
}
