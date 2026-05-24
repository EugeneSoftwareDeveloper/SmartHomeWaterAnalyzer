// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Water Analyzer';

  @override
  String get scanButton => 'Scan';

  @override
  String get scanStopButton => 'Stop scanning';

  @override
  String get scanRetryButton => 'Retry';

  @override
  String get scanSearching => 'Looking for BLE-C600...';

  @override
  String get scanHint =>
      'Turn the device on with a long ON/OFF press and make sure the official YINMIK app is disconnected.';

  @override
  String get scanNoDeviceName => '(no name)';

  @override
  String get permissionBluetoothDisabled =>
      'Bluetooth is disabled. Enable it in phone settings.';

  @override
  String get permissionOpenSettings => 'Open app settings';

  @override
  String get readingRefresh => 'Refresh';

  @override
  String get readingFailed => 'Failed to read measurements';

  @override
  String get readingRetry => 'Retry';

  @override
  String get summaryAllGood => 'All measured parameters are within range.';

  @override
  String summaryProblematic(String names) {
    return 'Out of range: $names';
  }

  @override
  String get qualityExcellent => 'Excellent water quality';

  @override
  String get qualityGood => 'Good water quality';

  @override
  String get qualityAcceptable => 'Acceptable water quality';

  @override
  String get qualityCaution => 'Needs attention';

  @override
  String get qualityDanger => 'Dangerous water quality';

  @override
  String get controlSectionTitle => 'Device controls';

  @override
  String get controlBacklight => 'Backlight';

  @override
  String get controlBacklightSubtitle => 'Turn on device screen';

  @override
  String get controlHold => 'Hold reading';

  @override
  String get controlHoldSubtitle => 'Freeze current values on the screen';

  @override
  String controlCommandFailed(String error) {
    return 'Failed to send command: $error';
  }

  @override
  String get historyTitle => 'Measurement history';

  @override
  String get historyEmpty =>
      'No saved measurements yet. Make a few readings on the main screen.';

  @override
  String get historyExport => 'Export CSV';

  @override
  String get historyDeleteAll => 'Clear history';

  @override
  String get historyDeleteConfirm =>
      'Delete all saved measurements? Cannot be undone.';

  @override
  String get historyDeleted => 'History cleared';

  @override
  String historyExported(String path) {
    return 'File saved: $path';
  }

  @override
  String get profilesTitle => 'Norms profile';

  @override
  String get profileDrinking => 'Drinking water';

  @override
  String get profilePool => 'Swimming pool';

  @override
  String get profileAquariumFresh => 'Aquarium (fresh)';

  @override
  String get profileHydroponics => 'Hydroponics';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsProfile => 'Norms profile';

  @override
  String get settingsNotifications => 'Notify on out-of-range';

  @override
  String get settingsAbout => 'About';

  @override
  String get tabReading => 'Reading';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get bluetoothOffTitle => 'Bluetooth is off';

  @override
  String get bluetoothOffSubtitle => 'Turn on Bluetooth to start scanning';
}
