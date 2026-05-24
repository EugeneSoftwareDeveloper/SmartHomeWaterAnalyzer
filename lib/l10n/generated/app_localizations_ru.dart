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
  String get permissionBluetoothDisabled =>
      'Bluetooth выключен. Включи его в настройках телефона.';

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
  String get historyDeleteConfirm =>
      'Удалить все сохранённые измерения? Действие необратимо.';

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
  String get bluetoothOffSubtitle =>
      'Включи Bluetooth, чтобы начать сканирование';
}
