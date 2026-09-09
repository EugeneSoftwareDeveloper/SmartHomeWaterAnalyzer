// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Water Analyzer';

  @override
  String get scanButton => 'Сканировать';

  @override
  String get scanStopButton => 'Остановить сканирование';

  @override
  String get scanRetryButton => 'Повторить';

  @override
  String get scanSearching => 'Поиск BLE-C600...';

  @override
  String get scanHint =>
      'Включи прибор длинным нажатием ON/OFF и убедись, что официальное приложение YINMIK не подключено к нему.';

  @override
  String get scanNoDeviceName => '(без имени)';

  @override
  String get permissionBluetoothDisabled => 'Bluetooth выключен. Включи его в настройках телефона.';

  @override
  String get permissionOpenSettings => 'Открыть настройки приложения';

  @override
  String get readingRefresh => 'Обновить';

  @override
  String get readingFailed => 'Не удалось прочитать показания';

  @override
  String get readingRetry => 'Повторить';

  @override
  String get summaryAllGood => 'Все измеренные параметры в пределах нормы.';

  @override
  String summaryProblematic(String names) {
    return 'Вне нормы: $names';
  }

  @override
  String get qualityExcellent => 'Отличное качество воды';

  @override
  String get qualityGood => 'Хорошее качество воды';

  @override
  String get qualityAcceptable => 'Приемлемое качество воды';

  @override
  String get qualityCaution => 'Требует внимания';

  @override
  String get qualityDanger => 'Опасное качество воды';

  @override
  String get controlSectionTitle => 'Управление прибором';

  @override
  String get controlBacklight => 'Подсветка';

  @override
  String get controlBacklightSubtitle => 'Включить экран прибора';

  @override
  String get controlHold => 'Удержание показаний (HOLD)';

  @override
  String get controlHoldSubtitle => 'Зафиксировать текущие значения на экране';

  @override
  String controlCommandFailed(String error) {
    return 'Не удалось отправить команду: $error';
  }

  @override
  String get historyTitle => 'История измерений';

  @override
  String get historyEmpty =>
      'Пока нет сохранённых измерений. Сделай несколько чтений на главном экране.';

  @override
  String get historyExport => 'Экспорт CSV';

  @override
  String get historyDeleteAll => 'Очистить историю';

  @override
  String get historyDeleteConfirm => 'Удалить все сохранённые измерения? Действие необратимо.';

  @override
  String get historyDeleted => 'История очищена';

  @override
  String historyExported(String path) {
    return 'Файл сохранён: $path';
  }

  @override
  String get profilesTitle => 'Профиль норм';

  @override
  String get profileDrinking => 'Питьевая вода';

  @override
  String get profilePool => 'Бассейн';

  @override
  String get profileAquariumFresh => 'Аквариум (пресный)';

  @override
  String get profileHydroponics => 'Гидропоника';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsThemeSystem => 'По системе';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsTheme => 'Тема оформления';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'По системе';

  @override
  String get settingsProfile => 'Профиль норм';

  @override
  String get settingsNotifications => 'Уведомления при выходе из нормы';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get tabReading => 'Показания';

  @override
  String get tabHistory => 'История';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get bluetoothOffTitle => 'Bluetooth выключен';

  @override
  String get bluetoothOffSubtitle => 'Включи Bluetooth, чтобы начать сканирование';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonUndo => 'Отменить';

  @override
  String get commonRename => 'Переименовать';

  @override
  String get commonName => 'Название';

  @override
  String get commonGotIt => 'Понятно';

  @override
  String get helpTitle => 'Справка по параметрам';

  @override
  String get helpSubtitle => 'Подробное описание pH, ORP, EC и других значений';

  @override
  String get trendUnchanged => 'без изменений';

  @override
  String get locationCardTitle => 'Где сделан замер';

  @override
  String locationCardAccuracy(String accuracy) {
    return 'Точность $accuracy';
  }

  @override
  String get locationCardCopy => 'Копировать';

  @override
  String get locationCardOpenMap => 'На карте';

  @override
  String get locationCardCopied => 'Координаты скопированы';

  @override
  String get locationCardNoMapApp => 'Не нашлось приложения для карт';

  @override
  String get placeFieldLabel => 'Где мерим';

  @override
  String get placeNotSelected => 'Не выбрано';

  @override
  String get placeConfigure => 'Настроить';

  @override
  String get placeNoAddress => 'Без адреса';

  @override
  String get placeNoAddressSubtitle => 'Замер сохранится без места и источника';

  @override
  String get placeBoundToCoordinates => 'Место привязано к координатам';

  @override
  String get settingsPlaces => 'Места замеров';

  @override
  String get settingsPlacesSubtitle => 'Дома, комнаты и источники воды';

  @override
  String get settingsSaveLocation => 'Координаты замеров';

  @override
  String get settingsSaveLocationSubtitle =>
      'Сохранять, где сделан замер — чтобы позже открыть точку на карте';

  @override
  String get settingsAboutSubtitle => 'SmartHomeWaterAnalyzer • для YINMIK BLE-C600';

  @override
  String get settingsAboutLegalese => 'Личный проект, лицензия будет определена позже.';

  @override
  String historyDeleteFailed(String error) {
    return 'Не удалось удалить: $error';
  }

  @override
  String get historyMeasurementDeleted => 'Замер удалён';

  @override
  String historyChartTitle(String parameter) {
    return '$parameter во времени';
  }

  @override
  String get historyAllPlaces => 'Все места';

  @override
  String get historyChartNeedsMore => 'Нужно минимум 2 измерения для построения графика';

  @override
  String get readingDebugCommands => 'Отладка команд';

  @override
  String get readingSaveMeasurement => 'Сохранить замер';

  @override
  String get readingSaved => 'Сохранено';

  @override
  String get readingAlreadySaved => 'Этот замер уже сохранён';

  @override
  String readingSaveFailed(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get readingMeasurementSaved => 'Замер сохранён';

  @override
  String readingAutoPlaceHint(int distance) {
    return 'определено по координатам, $distance м';
  }

  @override
  String get readingFirstHere => 'Первый замер в этом месте — сравнивать не с чем';

  @override
  String readingComparedWith(String moment) {
    return 'Сравнение с замером $moment';
  }

  @override
  String get controlBacklightOn => 'Подсветка ON';

  @override
  String get controlBacklightOff => 'Подсветка OFF';

  @override
  String get controlNotImplemented => 'Команда пока не реализована';

  @override
  String controlNotImplementedBody(String command) {
    return 'Точные байты команды «$command» BLE-C600 не задокументированы производителем и пока не подтверждены реверс-инжинирингом.';
  }

  @override
  String get controlNotImplementedWhat => 'Что делать:';

  @override
  String get controlNotImplementedSteps =>
      '1. На Android: «Параметры разработчика» → включить «Bluetooth HCI snoop log».\n2. Запустить официальное приложение YINMIK, подключиться к прибору.\n3. Переключить параметр (например, подсветку) ON и OFF.\n4. Извлечь /sdcard/btsnoop_hci.log через adb или bug report.\n5. Открыть в Wireshark, отфильтровать btatt, найти write в FF15.\n6. Записать байты в lib/yinmik/commands.dart и пересобрать.';

  @override
  String get detailTitle => 'Замер';

  @override
  String get detailChangePlace => 'Изменить адрес';

  @override
  String get detailDeleteMeasurement => 'Удалить замер';

  @override
  String detailPlaceChangeFailed(String error) {
    return 'Не удалось сменить адрес: $error';
  }

  @override
  String get detailPlaceCleared => 'Адрес убран';

  @override
  String get detailDeleteConfirmTitle => 'Удалить замер?';

  @override
  String detailDeleteConfirmBody(String moment) {
    return 'Замер от $moment будет удалён. Действие можно отменить в течение 5 секунд.';
  }

  @override
  String detailPlaceChanged(String place) {
    return 'Адрес изменён на «$place»';
  }

  @override
  String get scanShowAllDevices => 'Показать все устройства';

  @override
  String get scanShowAllHint => 'Если прибор называется не «BLE-C600», выбери его вручную.';

  @override
  String get scanAllDevicesHint =>
      'Все видимые BLE-устройства. Если прибор здесь — нажми, чтобы подключиться (минуя фильтр по имени).';

  @override
  String scanConnectTo(String device) {
    return 'Подключиться к $device';
  }

  @override
  String get scanLastDevice => 'Последний прибор — без сканирования';

  @override
  String scanLastDeviceSubtitle(String deviceId) {
    return '$deviceId • без сканирования';
  }

  @override
  String get scanForgetDevice => 'Забыть прибор';

  @override
  String get scanHelp => 'Справка';

  @override
  String get bluetoothTurnOn => 'Включить Bluetooth';

  @override
  String scanNoTargetFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сканер нашёл $count устройств, но среди них нет BLE-C600.',
      few: 'Сканер нашёл $count устройства, но среди них нет BLE-C600.',
      one: 'Сканер нашёл $count устройство, но среди них нет BLE-C600.',
    );
    return '$_temp0';
  }

  @override
  String get placesTitle => 'Места замеров';

  @override
  String get placesAddSite => 'Место';

  @override
  String get placesNewSite => 'Новое место';

  @override
  String get placesRenameSite => 'Переименовать место';

  @override
  String get placesAddRoom => 'Добавить комнату';

  @override
  String get placesAddSource => 'Добавить источник';

  @override
  String get placesNewRoom => 'Новая комната';

  @override
  String get placesNewSource => 'Новый источник';

  @override
  String get placesRenameRoom => 'Переименовать комнату';

  @override
  String get placesRenameSource => 'Переименовать источник';

  @override
  String placesSourceInRoom(String room) {
    return 'Источник в «$room»';
  }

  @override
  String get placesBindHere => 'Привязать здесь';

  @override
  String get placesUnbind => 'Сбросить привязку';

  @override
  String get placesDeleteSite => 'Удалить место';

  @override
  String get placesDeleteRoom => 'Удалить комнату';

  @override
  String get placesDeleteSource => 'Удалить источник';

  @override
  String get placesEmpty =>
      'Пока нет ни одного места.\nДобавьте дом или дачу — источники живут внутри них.';

  @override
  String get placesNoSources => 'Источников пока нет';

  @override
  String get placesUnbound => 'без привязки — не подставляется автоматически';

  @override
  String placesBoundToSamples(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'привязано по $count замерам',
      few: 'привязано по $count замерам',
      one: 'привязано по $count замеру',
    );
    return '$_temp0';
  }

  @override
  String get placesCoordinatesUnavailable => 'Координаты недоступны';

  @override
  String get placesBound => 'Место привязано к этой точке';

  @override
  String placesConfirmDeleteTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get placesConfirmDeleteSite =>
      'Вместе с ним исчезнут его комнаты и источники. Замеры останутся в истории со своими названиями.';

  @override
  String get placesConfirmDeleteRoom =>
      'Источники этой комнаты тоже исчезнут. История не меняется.';

  @override
  String get placesConfirmDeleteSource =>
      'Замеры этого источника останутся в истории со своим названием.';

  @override
  String get placesCityLabel => 'Город (необязательно)';

  @override
  String get placesCityHint => 'Тверь';

  @override
  String get placesNameHint => 'Дача';

  @override
  String get debugClearLog => 'Очистить лог';

  @override
  String get debugIntro =>
      'Эта страница пробует разные байты команды и проверяет, изменился ли бит статуса 0x08 (подсветка) или 0x10 (HOLD) в кадре FF02 после записи. Если какой-то пресет сработает, в логе появится «бит изменился».';

  @override
  String get debugTargetCharacteristic => 'Целевая характеристика';

  @override
  String get debugFf15Subtitle => 'Канонический кандидат для команд';

  @override
  String get debugFf02Subtitle => 'У некоторых вариантов поддерживает write';

  @override
  String get debugVerifyBit => 'Проверять бит';

  @override
  String get debugBacklightBit => 'Подсветка (0x08)';

  @override
  String get debugPresets => 'Готовые пресеты';

  @override
  String get debugManualInput => 'Ручной ввод (hex, через пробел)';

  @override
  String get debugManualHint => 'Например: 01 08';

  @override
  String get debugSendManual => 'Отправить введённые байты';

  @override
  String debugManualLabel(String bytes) {
    return 'Ручной: $bytes';
  }

  @override
  String get debugLogTitle => 'Лог попыток (новые сверху)';

  @override
  String get debugLogEmpty => 'Пока ничего не отправлено';

  @override
  String debugInvalidHex(String error) {
    return 'Неверный hex: $error';
  }

  @override
  String debugError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String debugBitChanged(String bit, String before, String after) {
    return 'Бит $bit изменился: $before → $after';
  }

  @override
  String debugBitUnchanged(String before, String after) {
    return 'Без изменений (status $before → $after)';
  }
}
