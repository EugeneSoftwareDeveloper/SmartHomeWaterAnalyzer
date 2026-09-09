import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/help/parameter_help.dart';
import 'package:water_analyzer/l10n/generated/app_localizations.dart';
import 'package:water_analyzer/quality/profile.dart';

/// Справка на двух языках.
///
/// Текст справки лежит структурой на Dart, а не ключами в ARB: у каждой
/// градации есть числовая граница, цвет и пояснение, и разрывать их на две
/// сотни отдельных ключей значило бы сделать нечитаемыми и текст, и код. Цена
/// такого решения — отсутствие проверки «ключ есть в обоих файлах», и её
/// заменяет этот тест. Он строже: сверяет не имена ключей, а саму структуру —
/// параметры, разделы, границы диапазонов и цвета.
void main() {
  const russian = Locale('ru');
  const english = Locale('en');

  test('справка есть для каждого параметра каталога', () {
    for (final profile in NormsProfile.values) {
      for (final locale in [russian, english]) {
        final all = ParameterHelpCatalog.all(profile, locale);

        expect(all.map((help) => help.parameterKey), parameterHelpKeys);
      }
    }
  });

  test('неизвестный параметр не отдаёт пустую справку молча', () {
    expect(
      () => ParameterHelpCatalog.byKey('salinity_v2', NormsProfile.drinking, russian),
      throwsArgumentError,
    );
  });

  test('незнакомый язык получает английскую справку, а не пустую', () {
    // Тот же откат, что и у остального интерфейса: английский стоит первым в
    // supportedLocales именно для этого.
    final german = ParameterHelpCatalog.byKey('ph', NormsProfile.drinking, const Locale('de'));
    final fallback = ParameterHelpCatalog.byKey('ph', NormsProfile.drinking, english);

    expect(german.title, fallback.title);
  });

  group('языки описывают одну и ту же градацию', () {
    for (final profile in NormsProfile.values) {
      test('профиль ${profile.name}', () {
        final ru = ParameterHelpCatalog.all(profile, russian);
        final en = ParameterHelpCatalog.all(profile, english);

        expect(en, hasLength(ru.length));

        for (var i = 0; i < ru.length; i++) {
          final left = ru[i];
          final right = en[i];
          final where = '${profile.name}/${left.parameterKey}';

          expect(right.parameterKey, left.parameterKey, reason: where);
          expect(right.sections, hasLength(left.sections.length), reason: where);

          for (var s = 0; s < left.sections.length; s++) {
            final ruSection = left.sections[s];
            final enSection = right.sections[s];

            // Раздел с диапазонами и раздел с текстом — разные вещи; перепутать
            // их местами значит показать пользователю не тот экран.
            expect(enSection.ranges == null, ruSection.ranges == null, reason: '$where, раздел $s');
            expect(enSection.text == null, ruSection.text == null, reason: '$where, раздел $s');

            final ruRanges = ruSection.ranges;
            final enRanges = enSection.ranges;
            if (ruRanges == null || enRanges == null) continue;

            expect(enRanges, hasLength(ruRanges.length), reason: '$where, раздел $s');
            for (var r = 0; r < ruRanges.length; r++) {
              // Числа и цвет — данные, а не перевод: они обязаны совпасть,
              // иначе на разных языках приложение советовало бы разное.
              // Единица при этом переводится: «мВ» и «mV» — одно и то же.
              expect(
                _bounds(enRanges[r].range),
                _bounds(ruRanges[r].range),
                reason: '$where, диапазон $r',
              );
              expect(enRanges[r].color, ruRanges[r].color, reason: '$where, диапазон $r');
            }
          }
        }
      });
    }
  });

  test('в английской справке не осталось русского текста', () {
    // Самая вероятная ошибка при добавлении новой градации — дописать её только
    // в один файл и забыть про второй.
    final cyrillic = RegExp(r'[А-Яа-яЁё]');

    for (final profile in NormsProfile.values) {
      for (final help in ParameterHelpCatalog.all(profile, english)) {
        expect(help.title, isNot(matches(cyrillic)), reason: help.parameterKey);
        expect(help.summary, isNot(matches(cyrillic)), reason: help.parameterKey);

        for (final section in help.sections) {
          expect(section.title, isNot(matches(cyrillic)), reason: help.parameterKey);
          expect(section.text ?? '', isNot(matches(cyrillic)), reason: help.parameterKey);

          for (final range in section.ranges ?? const <HelpRange>[]) {
            expect(range.label, isNot(matches(cyrillic)), reason: range.range);
            expect(range.note, isNot(matches(cyrillic)), reason: range.range);
            expect(range.range, isNot(matches(cyrillic)), reason: range.range);
          }
        }
      }
    }
  });

  test('русская справка остаётся русской', () {
    // Обратная проверка: перевод не должен просочиться в оригинал.
    final latinWords = RegExp(r'[A-Za-z]{4,}');
    final help = ParameterHelpCatalog.byKey('ph', NormsProfile.drinking, russian);

    expect(help.title, contains('Кислотность'));
    expect(help.summary, isNot(matches(latinWords)));
  });

  test('supportedLocales и справка не разъезжаются', () {
    // Появится третий язык — тест напомнит, что справку тоже нужно завести.
    for (final locale in AppL10n.supportedLocales) {
      final help = ParameterHelpCatalog.byKey('ph', NormsProfile.drinking, locale);
      expect(help.sections, isNotEmpty, reason: '$locale');
    }
  });
}

/// Числовые границы диапазона без единицы измерения: «650 – 750 мВ» → «650 750».
///
/// Единицу отбрасываем сознательно: она переводится вместе с текстом, а числа —
/// нет, и сверять надо именно их.
String _bounds(String range) =>
    RegExp(r'−?\d+(?:[.,]\d+)?').allMatches(range).map((m) => m.group(0)).join(' ');
