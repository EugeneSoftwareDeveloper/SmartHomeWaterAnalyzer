import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Water Analyzer'**
  String get appTitle;

  /// No description provided for @scanButton.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать'**
  String get scanButton;

  /// No description provided for @scanStopButton.
  ///
  /// In ru, this message translates to:
  /// **'Остановить сканирование'**
  String get scanStopButton;

  /// No description provided for @scanRetryButton.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get scanRetryButton;

  /// No description provided for @scanSearching.
  ///
  /// In ru, this message translates to:
  /// **'Поиск BLE-C600...'**
  String get scanSearching;

  /// No description provided for @scanHint.
  ///
  /// In ru, this message translates to:
  /// **'Включи прибор длинным нажатием ON/OFF и убедись, что официальное приложение YINMIK не подключено к нему.'**
  String get scanHint;

  /// No description provided for @scanNoDeviceName.
  ///
  /// In ru, this message translates to:
  /// **'(без имени)'**
  String get scanNoDeviceName;

  /// No description provided for @permissionBluetoothDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Bluetooth выключен. Включи его в настройках телефона.'**
  String get permissionBluetoothDisabled;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки приложения'**
  String get permissionOpenSettings;

  /// No description provided for @readingRefresh.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get readingRefresh;

  /// No description provided for @readingFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать показания'**
  String get readingFailed;

  /// No description provided for @readingRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get readingRetry;

  /// No description provided for @summaryAllGood.
  ///
  /// In ru, this message translates to:
  /// **'Все измеренные параметры в пределах нормы.'**
  String get summaryAllGood;

  /// No description provided for @summaryProblematic.
  ///
  /// In ru, this message translates to:
  /// **'Вне нормы: {names}'**
  String summaryProblematic(String names);

  /// No description provided for @qualityExcellent.
  ///
  /// In ru, this message translates to:
  /// **'Отличное качество воды'**
  String get qualityExcellent;

  /// No description provided for @qualityGood.
  ///
  /// In ru, this message translates to:
  /// **'Хорошее качество воды'**
  String get qualityGood;

  /// No description provided for @qualityAcceptable.
  ///
  /// In ru, this message translates to:
  /// **'Приемлемое качество воды'**
  String get qualityAcceptable;

  /// No description provided for @qualityCaution.
  ///
  /// In ru, this message translates to:
  /// **'Требует внимания'**
  String get qualityCaution;

  /// No description provided for @qualityDanger.
  ///
  /// In ru, this message translates to:
  /// **'Опасное качество воды'**
  String get qualityDanger;

  /// No description provided for @controlSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Управление прибором'**
  String get controlSectionTitle;

  /// No description provided for @controlBacklight.
  ///
  /// In ru, this message translates to:
  /// **'Подсветка'**
  String get controlBacklight;

  /// No description provided for @controlBacklightSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Включить экран прибора'**
  String get controlBacklightSubtitle;

  /// No description provided for @controlHold.
  ///
  /// In ru, this message translates to:
  /// **'Удержание показаний (HOLD)'**
  String get controlHold;

  /// No description provided for @controlHoldSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Зафиксировать текущие значения на экране'**
  String get controlHoldSubtitle;

  /// No description provided for @controlCommandFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить команду: {error}'**
  String controlCommandFailed(String error);

  /// No description provided for @historyTitle.
  ///
  /// In ru, this message translates to:
  /// **'История измерений'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сохранённых измерений. Сделай несколько чтений на главном экране.'**
  String get historyEmpty;

  /// No description provided for @historyExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт CSV'**
  String get historyExport;

  /// No description provided for @historyDeleteAll.
  ///
  /// In ru, this message translates to:
  /// **'Очистить историю'**
  String get historyDeleteAll;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все сохранённые измерения? Действие необратимо.'**
  String get historyDeleteConfirm;

  /// No description provided for @historyDeleted.
  ///
  /// In ru, this message translates to:
  /// **'История очищена'**
  String get historyDeleted;

  /// No description provided for @historyExported.
  ///
  /// In ru, this message translates to:
  /// **'Файл сохранён: {path}'**
  String historyExported(String path);

  /// No description provided for @profilesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль норм'**
  String get profilesTitle;

  /// No description provided for @profileDrinking.
  ///
  /// In ru, this message translates to:
  /// **'Питьевая вода'**
  String get profileDrinking;

  /// No description provided for @profilePool.
  ///
  /// In ru, this message translates to:
  /// **'Бассейн'**
  String get profilePool;

  /// No description provided for @profileAquariumFresh.
  ///
  /// In ru, this message translates to:
  /// **'Аквариум (пресный)'**
  String get profileAquariumFresh;

  /// No description provided for @profileHydroponics.
  ///
  /// In ru, this message translates to:
  /// **'Гидропоника'**
  String get profileHydroponics;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ru, this message translates to:
  /// **'По системе'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settingsThemeDark;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get settingsTheme;

  /// No description provided for @settingsProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль норм'**
  String get settingsProfile;

  /// No description provided for @settingsNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления при выходе из нормы'**
  String get settingsNotifications;

  /// No description provided for @settingsAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAbout;

  /// No description provided for @tabReading.
  ///
  /// In ru, this message translates to:
  /// **'Показания'**
  String get tabReading;

  /// No description provided for @tabHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get tabSettings;

  /// No description provided for @bluetoothOffTitle.
  ///
  /// In ru, this message translates to:
  /// **'Bluetooth выключен'**
  String get bluetoothOffTitle;

  /// No description provided for @bluetoothOffSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Включи Bluetooth, чтобы начать сканирование'**
  String get bluetoothOffSubtitle;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
