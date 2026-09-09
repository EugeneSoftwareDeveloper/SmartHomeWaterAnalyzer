import 'package:flutter/material.dart';

import '../quality/profile.dart';
import 'parameter_help_en.dart';
import 'parameter_help_ru.dart';

/// Подробная справка по одному параметру: что он значит, почему важен,
/// тонкая градация зон с конкретными числовыми границами, источники.
class ParameterHelp {
  final String parameterKey;
  final String title;
  final String summary;
  final List<HelpSection> sections;

  const ParameterHelp({
    required this.parameterKey,
    required this.title,
    required this.summary,
    required this.sections,
  });
}

class HelpSection {
  final String title;
  final List<HelpRange>? ranges;
  final String? text;

  const HelpSection({required this.title, this.ranges, this.text});
}

class HelpRange {
  final String label;
  final String range;
  final String note;
  final Color color;

  const HelpRange({
    required this.label,
    required this.range,
    required this.note,
    required this.color,
  });
}

/// Палитра для тонких градаций. От тёмно-красного (опасно) к тёмно-синему (отлично) через
/// промежуточные оттенки — даёт больше степеней, чем 5-цветный QualityCategory.
///
/// Публичная: цвета выбирают файлы с содержимым справки на каждом языке, и
/// одинаковая градация у них — часть контракта, который проверяет тест.
abstract final class HelpPalette {
  static const dangerDark = Color(0xFFB71C1C);
  static const danger = Color(0xFFD32F2F);
  static const caution = Color(0xFFF57C00);
  static const acceptable = Color(0xFFFBC02D);
  static const good = Color(0xFF388E3C);
  static const excellent = Color(0xFF2E7D32);
  static const ideal = Color(0xFF1565C0);
}

/// Справка по параметрам на языке интерфейса.
///
/// Диспетчер, а не хранилище: сам текст лежит в файлах с содержимым — по одному
/// на язык. Незнакомый язык получает английскую справку, как и весь остальной
/// интерфейс.
abstract final class ParameterHelpCatalog {
  static ParameterHelp byKey(String key, NormsProfile profile, Locale locale) {
    return locale.languageCode == 'ru'
        ? RussianParameterHelp.byKey(key, profile)
        : EnglishParameterHelp.byKey(key, profile);
  }

  static List<ParameterHelp> all(NormsProfile profile, Locale locale) {
    return [for (final key in parameterHelpKeys) byKey(key, profile, locale)];
  }
}

/// Параметры, по которым есть справка, в порядке показа на экране.
const List<String> parameterHelpKeys = <String>[
  'ph',
  'orp',
  'ec',
  'tds',
  'salinity',
  'temperature',
  'sg',
];
