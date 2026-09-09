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
  AppL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru')];

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

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In ru, this message translates to:
  /// **'По системе'**
  String get settingsLanguageSystem;

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

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get commonDone;

  /// No description provided for @commonUndo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get commonUndo;

  /// No description provided for @commonRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get commonRename;

  /// No description provided for @commonName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get commonName;

  /// No description provided for @commonGotIt.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get commonGotIt;

  /// No description provided for @helpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Справка по параметрам'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подробное описание pH, ORP, EC и других значений'**
  String get helpSubtitle;

  /// No description provided for @trendUnchanged.
  ///
  /// In ru, this message translates to:
  /// **'без изменений'**
  String get trendUnchanged;

  /// No description provided for @locationCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Где сделан замер'**
  String get locationCardTitle;

  /// No description provided for @locationCardAccuracy.
  ///
  /// In ru, this message translates to:
  /// **'Точность {accuracy}'**
  String locationCardAccuracy(String accuracy);

  /// No description provided for @locationCardCopy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get locationCardCopy;

  /// No description provided for @locationCardOpenMap.
  ///
  /// In ru, this message translates to:
  /// **'На карте'**
  String get locationCardOpenMap;

  /// No description provided for @locationCardCopied.
  ///
  /// In ru, this message translates to:
  /// **'Координаты скопированы'**
  String get locationCardCopied;

  /// No description provided for @locationCardNoMapApp.
  ///
  /// In ru, this message translates to:
  /// **'Не нашлось приложения для карт'**
  String get locationCardNoMapApp;

  /// No description provided for @placeFieldLabel.
  ///
  /// In ru, this message translates to:
  /// **'Где мерим'**
  String get placeFieldLabel;

  /// No description provided for @placeNotSelected.
  ///
  /// In ru, this message translates to:
  /// **'Не выбрано'**
  String get placeNotSelected;

  /// No description provided for @placeConfigure.
  ///
  /// In ru, this message translates to:
  /// **'Настроить'**
  String get placeConfigure;

  /// No description provided for @placeNoAddress.
  ///
  /// In ru, this message translates to:
  /// **'Без адреса'**
  String get placeNoAddress;

  /// No description provided for @placeNoAddressSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Замер сохранится без места и источника'**
  String get placeNoAddressSubtitle;

  /// No description provided for @placeBoundToCoordinates.
  ///
  /// In ru, this message translates to:
  /// **'Место привязано к координатам'**
  String get placeBoundToCoordinates;

  /// No description provided for @settingsPlaces.
  ///
  /// In ru, this message translates to:
  /// **'Места замеров'**
  String get settingsPlaces;

  /// No description provided for @settingsPlacesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Дома, комнаты и источники воды'**
  String get settingsPlacesSubtitle;

  /// No description provided for @settingsSaveLocation.
  ///
  /// In ru, this message translates to:
  /// **'Координаты замеров'**
  String get settingsSaveLocation;

  /// No description provided for @settingsSaveLocationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сохранять, где сделан замер — чтобы позже открыть точку на карте'**
  String get settingsSaveLocationSubtitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'SmartHomeWaterAnalyzer • для YINMIK BLE-C600'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAboutLegalese.
  ///
  /// In ru, this message translates to:
  /// **'Личный проект, лицензия будет определена позже.'**
  String get settingsAboutLegalese;

  /// No description provided for @historyDeleteFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить: {error}'**
  String historyDeleteFailed(String error);

  /// No description provided for @historyMeasurementDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Замер удалён'**
  String get historyMeasurementDeleted;

  /// No description provided for @historyChartTitle.
  ///
  /// In ru, this message translates to:
  /// **'{parameter} во времени'**
  String historyChartTitle(String parameter);

  /// No description provided for @historyAllPlaces.
  ///
  /// In ru, this message translates to:
  /// **'Все места'**
  String get historyAllPlaces;

  /// No description provided for @historyChartNeedsMore.
  ///
  /// In ru, this message translates to:
  /// **'Нужно минимум 2 измерения для построения графика'**
  String get historyChartNeedsMore;

  /// No description provided for @readingDebugCommands.
  ///
  /// In ru, this message translates to:
  /// **'Отладка команд'**
  String get readingDebugCommands;

  /// No description provided for @readingSaveMeasurement.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить замер'**
  String get readingSaveMeasurement;

  /// No description provided for @readingSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get readingSaved;

  /// No description provided for @readingAlreadySaved.
  ///
  /// In ru, this message translates to:
  /// **'Этот замер уже сохранён'**
  String get readingAlreadySaved;

  /// No description provided for @readingSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить: {error}'**
  String readingSaveFailed(String error);

  /// No description provided for @readingMeasurementSaved.
  ///
  /// In ru, this message translates to:
  /// **'Замер сохранён'**
  String get readingMeasurementSaved;

  /// No description provided for @readingAutoPlaceHint.
  ///
  /// In ru, this message translates to:
  /// **'определено по координатам, {distance} м'**
  String readingAutoPlaceHint(int distance);

  /// No description provided for @readingFirstHere.
  ///
  /// In ru, this message translates to:
  /// **'Первый замер в этом месте — сравнивать не с чем'**
  String get readingFirstHere;

  /// No description provided for @readingComparedWith.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение с замером {moment}'**
  String readingComparedWith(String moment);

  /// No description provided for @controlBacklightOn.
  ///
  /// In ru, this message translates to:
  /// **'Подсветка ON'**
  String get controlBacklightOn;

  /// No description provided for @controlBacklightOff.
  ///
  /// In ru, this message translates to:
  /// **'Подсветка OFF'**
  String get controlBacklightOff;

  /// No description provided for @controlNotImplemented.
  ///
  /// In ru, this message translates to:
  /// **'Команда пока не реализована'**
  String get controlNotImplemented;

  /// No description provided for @controlNotImplementedBody.
  ///
  /// In ru, this message translates to:
  /// **'Точные байты команды «{command}» BLE-C600 не задокументированы производителем и пока не подтверждены реверс-инжинирингом.'**
  String controlNotImplementedBody(String command);

  /// No description provided for @controlNotImplementedWhat.
  ///
  /// In ru, this message translates to:
  /// **'Что делать:'**
  String get controlNotImplementedWhat;

  /// No description provided for @controlNotImplementedSteps.
  ///
  /// In ru, this message translates to:
  /// **'1. На Android: «Параметры разработчика» → включить «Bluetooth HCI snoop log».\n2. Запустить официальное приложение YINMIK, подключиться к прибору.\n3. Переключить параметр (например, подсветку) ON и OFF.\n4. Извлечь /sdcard/btsnoop_hci.log через adb или bug report.\n5. Открыть в Wireshark, отфильтровать btatt, найти write в FF15.\n6. Записать байты в lib/yinmik/commands.dart и пересобрать.'**
  String get controlNotImplementedSteps;

  /// No description provided for @detailTitle.
  ///
  /// In ru, this message translates to:
  /// **'Замер'**
  String get detailTitle;

  /// No description provided for @detailChangePlace.
  ///
  /// In ru, this message translates to:
  /// **'Изменить адрес'**
  String get detailChangePlace;

  /// No description provided for @detailDeleteMeasurement.
  ///
  /// In ru, this message translates to:
  /// **'Удалить замер'**
  String get detailDeleteMeasurement;

  /// No description provided for @detailPlaceChangeFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сменить адрес: {error}'**
  String detailPlaceChangeFailed(String error);

  /// No description provided for @detailPlaceCleared.
  ///
  /// In ru, this message translates to:
  /// **'Адрес убран'**
  String get detailPlaceCleared;

  /// No description provided for @detailDeleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить замер?'**
  String get detailDeleteConfirmTitle;

  /// No description provided for @detailDeleteConfirmBody.
  ///
  /// In ru, this message translates to:
  /// **'Замер от {moment} будет удалён. Действие можно отменить в течение 5 секунд.'**
  String detailDeleteConfirmBody(String moment);

  /// No description provided for @detailPlaceChanged.
  ///
  /// In ru, this message translates to:
  /// **'Адрес изменён на «{place}»'**
  String detailPlaceChanged(String place);

  /// No description provided for @scanShowAllDevices.
  ///
  /// In ru, this message translates to:
  /// **'Показать все устройства'**
  String get scanShowAllDevices;

  /// No description provided for @scanShowAllHint.
  ///
  /// In ru, this message translates to:
  /// **'Если прибор называется не «BLE-C600», выбери его вручную.'**
  String get scanShowAllHint;

  /// No description provided for @scanAllDevicesHint.
  ///
  /// In ru, this message translates to:
  /// **'Все видимые BLE-устройства. Если прибор здесь — нажми, чтобы подключиться (минуя фильтр по имени).'**
  String get scanAllDevicesHint;

  /// No description provided for @scanConnectTo.
  ///
  /// In ru, this message translates to:
  /// **'Подключиться к {device}'**
  String scanConnectTo(String device);

  /// No description provided for @scanLastDevice.
  ///
  /// In ru, this message translates to:
  /// **'Последний прибор — без сканирования'**
  String get scanLastDevice;

  /// No description provided for @scanLastDeviceSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{deviceId} • без сканирования'**
  String scanLastDeviceSubtitle(String deviceId);

  /// No description provided for @scanForgetDevice.
  ///
  /// In ru, this message translates to:
  /// **'Забыть прибор'**
  String get scanForgetDevice;

  /// No description provided for @scanHelp.
  ///
  /// In ru, this message translates to:
  /// **'Справка'**
  String get scanHelp;

  /// No description provided for @bluetoothTurnOn.
  ///
  /// In ru, this message translates to:
  /// **'Включить Bluetooth'**
  String get bluetoothTurnOn;

  /// No description provided for @scanNoTargetFound.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Сканер нашёл {count} устройство, но среди них нет BLE-C600.} few{Сканер нашёл {count} устройства, но среди них нет BLE-C600.} other{Сканер нашёл {count} устройств, но среди них нет BLE-C600.}}'**
  String scanNoTargetFound(int count);

  /// No description provided for @placesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Места замеров'**
  String get placesTitle;

  /// No description provided for @placesAddSite.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get placesAddSite;

  /// No description provided for @placesNewSite.
  ///
  /// In ru, this message translates to:
  /// **'Новое место'**
  String get placesNewSite;

  /// No description provided for @placesRenameSite.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать место'**
  String get placesRenameSite;

  /// No description provided for @placesAddRoom.
  ///
  /// In ru, this message translates to:
  /// **'Добавить комнату'**
  String get placesAddRoom;

  /// No description provided for @placesAddSource.
  ///
  /// In ru, this message translates to:
  /// **'Добавить источник'**
  String get placesAddSource;

  /// No description provided for @placesNewRoom.
  ///
  /// In ru, this message translates to:
  /// **'Новая комната'**
  String get placesNewRoom;

  /// No description provided for @placesNewSource.
  ///
  /// In ru, this message translates to:
  /// **'Новый источник'**
  String get placesNewSource;

  /// No description provided for @placesRenameRoom.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать комнату'**
  String get placesRenameRoom;

  /// No description provided for @placesRenameSource.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать источник'**
  String get placesRenameSource;

  /// No description provided for @placesSourceInRoom.
  ///
  /// In ru, this message translates to:
  /// **'Источник в «{room}»'**
  String placesSourceInRoom(String room);

  /// No description provided for @placesBindHere.
  ///
  /// In ru, this message translates to:
  /// **'Привязать здесь'**
  String get placesBindHere;

  /// No description provided for @placesUnbind.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить привязку'**
  String get placesUnbind;

  /// No description provided for @placesDeleteSite.
  ///
  /// In ru, this message translates to:
  /// **'Удалить место'**
  String get placesDeleteSite;

  /// No description provided for @placesDeleteRoom.
  ///
  /// In ru, this message translates to:
  /// **'Удалить комнату'**
  String get placesDeleteRoom;

  /// No description provided for @placesDeleteSource.
  ///
  /// In ru, this message translates to:
  /// **'Удалить источник'**
  String get placesDeleteSource;

  /// No description provided for @placesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет ни одного места.\nДобавьте дом или дачу — источники живут внутри них.'**
  String get placesEmpty;

  /// No description provided for @placesNoSources.
  ///
  /// In ru, this message translates to:
  /// **'Источников пока нет'**
  String get placesNoSources;

  /// No description provided for @placesUnbound.
  ///
  /// In ru, this message translates to:
  /// **'без привязки — не подставляется автоматически'**
  String get placesUnbound;

  /// No description provided for @placesBoundToSamples.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{привязано по {count} замеру} few{привязано по {count} замерам} other{привязано по {count} замерам}}'**
  String placesBoundToSamples(int count);

  /// No description provided for @placesCoordinatesUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Координаты недоступны'**
  String get placesCoordinatesUnavailable;

  /// No description provided for @placesBound.
  ///
  /// In ru, this message translates to:
  /// **'Место привязано к этой точке'**
  String get placesBound;

  /// No description provided for @placesConfirmDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{name}»?'**
  String placesConfirmDeleteTitle(String name);

  /// No description provided for @placesConfirmDeleteSite.
  ///
  /// In ru, this message translates to:
  /// **'Вместе с ним исчезнут его комнаты и источники. Замеры останутся в истории со своими названиями.'**
  String get placesConfirmDeleteSite;

  /// No description provided for @placesConfirmDeleteRoom.
  ///
  /// In ru, this message translates to:
  /// **'Источники этой комнаты тоже исчезнут. История не меняется.'**
  String get placesConfirmDeleteRoom;

  /// No description provided for @placesConfirmDeleteSource.
  ///
  /// In ru, this message translates to:
  /// **'Замеры этого источника останутся в истории со своим названием.'**
  String get placesConfirmDeleteSource;

  /// No description provided for @placesCityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Город (необязательно)'**
  String get placesCityLabel;

  /// No description provided for @placesCityHint.
  ///
  /// In ru, this message translates to:
  /// **'Тверь'**
  String get placesCityHint;

  /// No description provided for @placesNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Дача'**
  String get placesNameHint;

  /// No description provided for @debugClearLog.
  ///
  /// In ru, this message translates to:
  /// **'Очистить лог'**
  String get debugClearLog;

  /// No description provided for @debugIntro.
  ///
  /// In ru, this message translates to:
  /// **'Эта страница пробует разные байты команды и проверяет, изменился ли бит статуса 0x08 (подсветка) или 0x10 (HOLD) в кадре FF02 после записи. Если какой-то пресет сработает, в логе появится «бит изменился».'**
  String get debugIntro;

  /// No description provided for @debugTargetCharacteristic.
  ///
  /// In ru, this message translates to:
  /// **'Целевая характеристика'**
  String get debugTargetCharacteristic;

  /// No description provided for @debugFf15Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Канонический кандидат для команд'**
  String get debugFf15Subtitle;

  /// No description provided for @debugFf02Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'У некоторых вариантов поддерживает write'**
  String get debugFf02Subtitle;

  /// No description provided for @debugVerifyBit.
  ///
  /// In ru, this message translates to:
  /// **'Проверять бит'**
  String get debugVerifyBit;

  /// No description provided for @debugBacklightBit.
  ///
  /// In ru, this message translates to:
  /// **'Подсветка (0x08)'**
  String get debugBacklightBit;

  /// No description provided for @debugPresets.
  ///
  /// In ru, this message translates to:
  /// **'Готовые пресеты'**
  String get debugPresets;

  /// No description provided for @debugManualInput.
  ///
  /// In ru, this message translates to:
  /// **'Ручной ввод (hex, через пробел)'**
  String get debugManualInput;

  /// No description provided for @debugManualHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 01 08'**
  String get debugManualHint;

  /// No description provided for @debugSendManual.
  ///
  /// In ru, this message translates to:
  /// **'Отправить введённые байты'**
  String get debugSendManual;

  /// No description provided for @debugManualLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ручной: {bytes}'**
  String debugManualLabel(String bytes);

  /// No description provided for @debugLogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лог попыток (новые сверху)'**
  String get debugLogTitle;

  /// No description provided for @debugLogEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока ничего не отправлено'**
  String get debugLogEmpty;

  /// No description provided for @debugInvalidHex.
  ///
  /// In ru, this message translates to:
  /// **'Неверный hex: {error}'**
  String debugInvalidHex(String error);

  /// No description provided for @debugError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String debugError(String error);

  /// No description provided for @debugBitChanged.
  ///
  /// In ru, this message translates to:
  /// **'Бит {bit} изменился: {before} → {after}'**
  String debugBitChanged(String bit, String before, String after);

  /// No description provided for @debugBitUnchanged.
  ///
  /// In ru, this message translates to:
  /// **'Без изменений (status {before} → {after})'**
  String debugBitUnchanged(String before, String after);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

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
