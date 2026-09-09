import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/l10n/generated/app_localizations.dart';

/// Согласованность переводов.
///
/// Пропущенный ключ в одном из ARB — не ошибка сборки: `gen-l10n` подставит
/// текст языка-шаблона, и приложение молча покажет русскую фразу посреди
/// английского интерфейса. Проверять это глазами на 165 ключах бессмысленно,
/// поэтому проверяет тест.
Map<String, dynamic> _arb(String locale) {
  final file = File('lib/l10n/app_$locale.arb');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

/// Объявленные подстановки ключа, по метаданным `@key`.
///
/// Разбирать их из самого текста нельзя: у ICU-плюралов внутри фигурных скобок
/// лежат ветки с обычными словами, и `{other{The scanner...}}` дал бы
/// несуществующую подстановку `The`.
Set<String> _declaredPlaceholders(Map<String, dynamic> arb, String key) {
  final meta = arb['@$key'] as Map<String, dynamic>?;
  final placeholders = meta?['placeholders'] as Map<String, dynamic>?;
  return placeholders?.keys.toSet() ?? const <String>{};
}

void main() {
  final ru = _arb('ru');
  final en = _arb('en');

  test('наборы ключей совпадают', () {
    final onlyRu = _messageKeys(ru).difference(_messageKeys(en));
    final onlyEn = _messageKeys(en).difference(_messageKeys(ru));

    expect(onlyRu, isEmpty, reason: 'нет английского перевода');
    expect(onlyEn, isEmpty, reason: 'нет русского оригинала');
  });

  test('пустых переводов нет', () {
    for (final arb in [ru, en]) {
      for (final key in _messageKeys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: '$key в ${arb['@@locale']} пуст');
      }
    }
  });

  test('каждая подстановка доходит до текста на обоих языках', () {
    // Потерянная в переводе подстановка — фраза без числа или имени, и заметна
    // она только тому, кто читает именно этот язык.
    for (final key in _messageKeys(ru)) {
      for (final name in _declaredPlaceholders(ru, key)) {
        expect(ru[key] as String, contains('{$name'), reason: '$key, русский');
        expect(en[key] as String, contains('{$name'), reason: '$key, английский');
      }
    }
  });

  test('метаданные подстановок одинаковы в обоих файлах', () {
    // Объявление живёт в каждом ARB отдельно; разошлись — и gen-l10n соберёт
    // для языков разные сигнатуры.
    for (final key in _messageKeys(ru)) {
      expect(
        _declaredPlaceholders(en, key),
        _declaredPlaceholders(ru, key),
        reason: 'разные объявления подстановок в $key',
      );
    }
  });

  test('supportedLocales покрывает ровно те языки, для которых есть ARB', () {
    final fromFiles = Directory('lib/l10n')
        .listSync()
        .map((entry) => RegExp(r'app_(\w+)\.arb$').firstMatch(entry.path))
        .nonNulls
        .map((match) => match.group(1)!)
        .toSet();

    expect(AppL10n.supportedLocales.map((locale) => locale.languageCode).toSet(), fromFiles);
  });

  test('английский стоит первым — на него откатываются незнакомые языки', () {
    // Пользователь с немецким телефоном получит английский, а не русский:
    // Flutter берёт первую поддерживаемую локаль, когда ни одна не подошла.
    expect(AppL10n.supportedLocales.first, const Locale('en'));
  });

  test('оба языка отдают непустой текст для ключей с подстановками', () {
    // Точечная проверка сгенерированного кода: ARB может быть корректным, а
    // сборка — устаревшей, и тогда getter'а просто не будет.
    for (final locale in AppL10n.supportedLocales) {
      final l10n = lookupAppL10n(locale);

      expect(l10n.historyChartTitle('pH'), contains('pH'));
      expect(l10n.readingAutoPlaceHint(40), contains('40'));
      expect(l10n.placesConfirmDeleteTitle('Дача'), contains('Дача'));
      expect(l10n.scanNoTargetFound(1), isNotEmpty);
      expect(l10n.scanNoTargetFound(5), isNotEmpty);
      expect(l10n.placesBoundToSamples(1), isNotEmpty);
    }
  });

  test('русские множественные формы различают 1, 2 и 5', () {
    // Без формы few «привязано по 2 замерам» звучало бы как «по 2 замеров».
    final l10n = lookupAppL10n(const Locale('ru'));

    expect(l10n.placesBoundToSamples(1), contains('замеру'));
    expect(l10n.placesBoundToSamples(2), contains('замерам'));
    expect(l10n.placesBoundToSamples(5), contains('замерам'));
    expect(l10n.scanNoTargetFound(1), contains('устройство'));
    expect(l10n.scanNoTargetFound(2), contains('устройства'));
    expect(l10n.scanNoTargetFound(5), contains('устройств,'));
  });
}
