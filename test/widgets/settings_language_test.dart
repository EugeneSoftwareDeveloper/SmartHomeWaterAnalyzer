import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_analyzer/l10n/generated/app_localizations.dart';
import 'package:water_analyzer/l10n/language_names.dart';
import 'package:water_analyzer/providers/app_settings.dart';
import 'package:water_analyzer/providers/app_version_provider.dart';
import 'package:water_analyzer/providers/preferences_provider.dart';
import 'package:water_analyzer/ui/settings_page.dart';

/// Выбор языка в настройках и автоопределение.
///
/// Проверяется не список как таковой, а два обещания: язык интерфейса
/// действительно меняется без перезапуска, и к автоопределению можно вернуться.
/// Название языка при этом остаётся на нём самом — иначе человек, случайно
/// включивший незнакомый язык, будет искать дорогу назад наугад.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  /// Собран как настоящий `WaterAnalyzerApp`: тот же `locale` из настроек и тот
  /// же список поддерживаемых языков. Иначе тест проверял бы не приложение.
  Widget app({Locale? systemLocale}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appVersionProvider.overrideWith((ref) async => '1.4.0 (12)'),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(appSettingsProvider);
          return MaterialApp(
            locale: settings.locale ?? systemLocale,
            localizationsDelegates: const [
              AppL10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppL10n.supportedLocales,
            home: const SettingsPage(),
          );
        },
      ),
    );
  }

  /// Подпись выбранного языка. Ищется внутри своей строки: «По системе» стоит
  /// и у темы, и у языка — по одному тексту их не различить.
  Finder languageSubtitle(String text) => find.descendant(
    of: find.widgetWithIcon(ListTile, Icons.translate),
    matching: find.text(text),
  );

  Future<void> pickLanguage(WidgetTester tester, String title) async {
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(RadioListTile<Locale?>), matching: find.text(title)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('без выбора язык определяется по системе', (tester) async {
    await tester.pumpWidget(app(systemLocale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(languageSubtitle('System'), findsOneWidget);
  });

  testWidgets('система на русском — интерфейс на русском', (tester) async {
    await tester.pumpWidget(app(systemLocale: const Locale('ru')));
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    expect(languageSubtitle('По системе'), findsOneWidget);
  });

  testWidgets('неподдерживаемый язык системы откатывается на английский', (tester) async {
    // Немецкого нет; показать вместо него русский было бы хуже — английский
    // стоит первым в supportedLocales именно поэтому.
    await tester.pumpWidget(app(systemLocale: const Locale('de')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('выбранный язык перебивает системный без перезапуска', (tester) async {
    await tester.pumpWidget(app(systemLocale: const Locale('ru')));
    await tester.pumpAndSettle();

    await pickLanguage(tester, 'English');

    expect(find.text('Settings'), findsOneWidget);
    expect(languageSubtitle('English'), findsOneWidget);
    expect(prefs.getString('settings.locale'), 'en');
  });

  testWidgets('к автоопределению можно вернуться', (tester) async {
    await prefs.setString('settings.locale', 'en');

    await tester.pumpWidget(app(systemLocale: const Locale('ru')));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await pickLanguage(tester, 'System');

    expect(find.text('Настройки'), findsOneWidget);
    expect(prefs.getString('settings.locale'), isNull);
  });

  testWidgets('названия языков не переводятся', (tester) async {
    await tester.pumpWidget(app(systemLocale: const Locale('en')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();

    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  test('язык без своей подписи не превращается в пустую строку', () {
    expect(languageName(const Locale('ru')), 'Русский');
    expect(languageName(const Locale('en')), 'English');
    expect(languageName(const Locale('de')), 'DE');
  });
}
