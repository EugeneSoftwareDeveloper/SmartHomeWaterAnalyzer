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
  String get permissionBluetoothDisabled => 'Bluetooth is disabled. Enable it in phone settings.';

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
  String get historyEmpty => 'No saved measurements yet. Make a few readings on the main screen.';

  @override
  String get historyExport => 'Export CSV';

  @override
  String get historyDeleteAll => 'Clear history';

  @override
  String get historyDeleteConfirm => 'Delete all saved measurements? Cannot be undone.';

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
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

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

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonRename => 'Rename';

  @override
  String get commonName => 'Name';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get helpTitle => 'Parameter reference';

  @override
  String get helpSubtitle => 'Detailed description of pH, ORP, EC and other values';

  @override
  String get trendUnchanged => 'unchanged';

  @override
  String get locationCardTitle => 'Measured at';

  @override
  String locationCardAccuracy(String accuracy) {
    return 'Accuracy $accuracy';
  }

  @override
  String get locationCardCopy => 'Copy';

  @override
  String get locationCardOpenMap => 'Open map';

  @override
  String get locationCardCopied => 'Coordinates copied';

  @override
  String get locationCardNoMapApp => 'No maps app found';

  @override
  String get placeFieldLabel => 'Where';

  @override
  String get placeNotSelected => 'Not selected';

  @override
  String get placeConfigure => 'Manage';

  @override
  String get placeNoAddress => 'No address';

  @override
  String get placeNoAddressSubtitle => 'The measurement will be saved without a site or source';

  @override
  String get placeBoundToCoordinates => 'Site is bound to coordinates';

  @override
  String get settingsPlaces => 'Measurement places';

  @override
  String get settingsPlacesSubtitle => 'Homes, rooms and water sources';

  @override
  String get settingsSaveLocation => 'Measurement coordinates';

  @override
  String get settingsSaveLocationSubtitle =>
      'Save where a measurement was taken, so the spot can be opened on a map later';

  @override
  String get settingsAboutSubtitle => 'SmartHomeWaterAnalyzer • for YINMIK BLE-C600';

  @override
  String get settingsAboutLegalese => 'Personal project, license to be decided later.';

  @override
  String historyDeleteFailed(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get historyMeasurementDeleted => 'Measurement deleted';

  @override
  String historyChartTitle(String parameter) {
    return '$parameter over time';
  }

  @override
  String get historyAllPlaces => 'All places';

  @override
  String get historyChartNeedsMore => 'At least 2 measurements are needed to draw a chart';

  @override
  String get readingDebugCommands => 'Command debugger';

  @override
  String get readingSaveMeasurement => 'Save measurement';

  @override
  String get readingSaved => 'Saved';

  @override
  String get readingAlreadySaved => 'This measurement is already saved';

  @override
  String readingSaveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get readingMeasurementSaved => 'Measurement saved';

  @override
  String readingAutoPlaceHint(int distance) {
    return 'detected by coordinates, $distance m';
  }

  @override
  String get readingFirstHere => 'First measurement here — nothing to compare with';

  @override
  String readingComparedWith(String moment) {
    return 'Compared with the measurement from $moment';
  }

  @override
  String get controlBacklightOn => 'Backlight ON';

  @override
  String get controlBacklightOff => 'Backlight OFF';

  @override
  String get controlNotImplemented => 'Command not implemented yet';

  @override
  String controlNotImplementedBody(String command) {
    return 'The exact bytes of the “$command” command are not documented by the BLE-C600 manufacturer and have not been confirmed by reverse engineering yet.';
  }

  @override
  String get controlNotImplementedWhat => 'What to do:';

  @override
  String get controlNotImplementedSteps =>
      '1. On Android: Developer options → enable Bluetooth HCI snoop log.\n2. Launch the official YINMIK app and connect to the device.\n3. Toggle the setting (the backlight, for example) ON and OFF.\n4. Pull /sdcard/btsnoop_hci.log with adb or from a bug report.\n5. Open it in Wireshark, filter by btatt, find the write to FF15.\n6. Put the bytes into lib/yinmik/commands.dart and rebuild.';

  @override
  String get detailTitle => 'Measurement';

  @override
  String get detailChangePlace => 'Change address';

  @override
  String get detailDeleteMeasurement => 'Delete measurement';

  @override
  String detailPlaceChangeFailed(String error) {
    return 'Could not change the address: $error';
  }

  @override
  String get detailPlaceCleared => 'Address removed';

  @override
  String get detailDeleteConfirmTitle => 'Delete the measurement?';

  @override
  String detailDeleteConfirmBody(String moment) {
    return 'The measurement from $moment will be deleted. This can be undone within 5 seconds.';
  }

  @override
  String detailPlaceChanged(String place) {
    return 'Address changed to “$place”';
  }

  @override
  String get scanShowAllDevices => 'Show all devices';

  @override
  String get scanShowAllHint => 'If the device is not called “BLE-C600”, pick it manually.';

  @override
  String get scanAllDevicesHint =>
      'Every visible BLE device. If yours is here, tap it to connect, bypassing the name filter.';

  @override
  String scanConnectTo(String device) {
    return 'Connect to $device';
  }

  @override
  String get scanLastDevice => 'Last device — no scanning';

  @override
  String scanLastDeviceSubtitle(String deviceId) {
    return '$deviceId • no scanning';
  }

  @override
  String get scanForgetDevice => 'Forget device';

  @override
  String get scanHelp => 'Help';

  @override
  String get bluetoothTurnOn => 'Turn on Bluetooth';

  @override
  String scanNoTargetFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The scanner found $count devices, but none of them is a BLE-C600.',
      one: 'The scanner found $count device, but none of them is a BLE-C600.',
    );
    return '$_temp0';
  }

  @override
  String get placesTitle => 'Measurement places';

  @override
  String get placesAddSite => 'Place';

  @override
  String get placesNewSite => 'New place';

  @override
  String get placesRenameSite => 'Rename place';

  @override
  String get placesAddRoom => 'Add room';

  @override
  String get placesAddSource => 'Add source';

  @override
  String get placesNewRoom => 'New room';

  @override
  String get placesNewSource => 'New source';

  @override
  String get placesRenameRoom => 'Rename room';

  @override
  String get placesRenameSource => 'Rename source';

  @override
  String placesSourceInRoom(String room) {
    return 'Source in “$room”';
  }

  @override
  String get placesBindHere => 'Bind to this spot';

  @override
  String get placesUnbind => 'Clear binding';

  @override
  String get placesDeleteSite => 'Delete place';

  @override
  String get placesDeleteRoom => 'Delete room';

  @override
  String get placesDeleteSource => 'Delete source';

  @override
  String get placesEmpty => 'No places yet.\nAdd a home or a cottage — sources live inside them.';

  @override
  String get placesNoSources => 'No sources yet';

  @override
  String get placesUnbound => 'not bound — will not be selected automatically';

  @override
  String placesBoundToSamples(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bound from $count measurements',
      one: 'bound from $count measurement',
    );
    return '$_temp0';
  }

  @override
  String get placesCoordinatesUnavailable => 'Coordinates unavailable';

  @override
  String get placesBound => 'The place is bound to this spot';

  @override
  String placesConfirmDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get placesConfirmDeleteSite =>
      'Its rooms and sources will go with it. Measurements stay in history under their own names.';

  @override
  String get placesConfirmDeleteRoom =>
      'The sources of this room will go too. History does not change.';

  @override
  String get placesConfirmDeleteSource =>
      'Measurements of this source stay in history under their own name.';

  @override
  String get placesCityLabel => 'City (optional)';

  @override
  String get placesCityHint => 'Cambridge';

  @override
  String get placesNameHint => 'Cottage';

  @override
  String get debugClearLog => 'Clear log';

  @override
  String get debugIntro =>
      'This page tries different command bytes and checks whether status bit 0x08 (backlight) or 0x10 (HOLD) changed in the FF02 frame after the write. If a preset works, the log will say the bit changed.';

  @override
  String get debugTargetCharacteristic => 'Target characteristic';

  @override
  String get debugFf15Subtitle => 'The canonical candidate for commands';

  @override
  String get debugFf02Subtitle => 'Writable on some variants';

  @override
  String get debugVerifyBit => 'Bit to verify';

  @override
  String get debugBacklightBit => 'Backlight (0x08)';

  @override
  String get debugPresets => 'Presets';

  @override
  String get debugManualInput => 'Manual input (hex, space separated)';

  @override
  String get debugManualHint => 'For example: 01 08';

  @override
  String get debugSendManual => 'Send the entered bytes';

  @override
  String debugManualLabel(String bytes) {
    return 'Manual: $bytes';
  }

  @override
  String get debugLogTitle => 'Attempt log (newest first)';

  @override
  String get debugLogEmpty => 'Nothing sent yet';

  @override
  String debugInvalidHex(String error) {
    return 'Invalid hex: $error';
  }

  @override
  String debugError(String error) {
    return 'Error: $error';
  }

  @override
  String debugBitChanged(String bit, String before, String after) {
    return 'Bit $bit changed: $before → $after';
  }

  @override
  String debugBitUnchanged(String before, String after) {
    return 'No change (status $before → $after)';
  }

  @override
  String get categoryDanger => 'Dangerous';

  @override
  String get categoryCaution => 'Attention';

  @override
  String get categoryAcceptable => 'Acceptable';

  @override
  String get categoryGood => 'Good';

  @override
  String get categoryExcellent => 'Excellent';

  @override
  String get paramPh => 'Acidity';

  @override
  String get paramOrp => 'Redox potential';

  @override
  String get paramEc => 'Conductivity';

  @override
  String get paramTds => 'Dissolved solids';

  @override
  String get paramSalinity => 'Salinity';

  @override
  String get paramSalinityShort => 'Salt';

  @override
  String get paramTemperature => 'Temperature';

  @override
  String get paramSg => 'Water density';

  @override
  String get unitMillivolt => 'mV';

  @override
  String get unitMicrosiemens => 'µS/cm';

  @override
  String get paramPhDescriptionDrinking =>
      'Acidity and alkalinity. Drinking water is normally 6.5–8.5.';

  @override
  String get paramPhDescriptionPool =>
      'Pool acidity. 7.2–7.6 is optimal for effective disinfection.';

  @override
  String get paramPhDescriptionAquarium =>
      'Aquarium acidity. Most freshwater fish want 6.5–7.5; check your species.';

  @override
  String get paramPhDescriptionHydroponics =>
      'Solution acidity. 5.8–6.5 is optimal for uptake of most nutrients.';

  @override
  String get paramOrpDescription =>
      'Oxidation-reduction potential. Drinking water is usually 200–600 mV.';

  @override
  String get paramOrpDescriptionPool =>
      'Pool oxidation potential. The WHO recommends ≥650 mV for safety.';

  @override
  String get paramEcDescription => 'Electrical conductivity. Up to 1500 µS/cm for drinking water.';

  @override
  String get paramEcDescriptionHydroponics => 'Solution strength. Most crops want 1200–2000 µS/cm.';

  @override
  String get paramTdsDescriptionDrinking =>
      'Total dissolved solids. Up to 1000 ppm for drinking water.';

  @override
  String get paramTdsDescriptionPool => 'Dissolved solids in the pool.';

  @override
  String get paramTdsDescriptionAquarium =>
      'Dissolved solids. Most freshwater fish want 80–300 ppm.';

  @override
  String get paramTdsDescriptionHydroponics => 'Dissolved solids in the solution.';

  @override
  String get paramSalinityDescription => 'Salinity in ppm. Close to zero for fresh water.';

  @override
  String get paramSalinityDescriptionPool =>
      'Pool salinity. Salt systems want 2700–3400 ppm (off this scale).';

  @override
  String get paramTemperatureDescription => 'Water temperature.';

  @override
  String get paramSgDescription => 'Specific gravity. Close to 1.000 for fresh water.';

  @override
  String get zonePhStronglyAcidic => 'Strongly acidic';

  @override
  String get zonePhAcidic => 'Acidic';

  @override
  String get zonePhLow => 'Low';

  @override
  String get zonePhNormal => 'Normal';

  @override
  String get zonePhOptimum => 'Optimum';

  @override
  String get zonePhHigh => 'High';

  @override
  String get zonePhAlkaline => 'Alkaline';

  @override
  String get zonePhStronglyAlkaline => 'Strongly alkaline';

  @override
  String get zoneOrpLow => 'Low';

  @override
  String get zoneOrpSlightlyLow => 'A bit low';

  @override
  String get zoneOrpOptimum => 'Optimum';

  @override
  String get zoneOrpHigh => 'High';

  @override
  String get zoneOrpVeryHigh => 'Very high';

  @override
  String get zoneOrpReducing => 'Reducing';

  @override
  String get zoneOrpNeutral => 'Neutral';

  @override
  String get zoneOrpOxidizing => 'Oxidizing';

  @override
  String get zoneOrpStronglyOxidizing => 'Strongly oxid.';

  @override
  String get zoneEcPurified => 'Purified';

  @override
  String get zoneEcOptimum => 'Optimum';

  @override
  String get zoneEcNormal => 'Normal';

  @override
  String get zoneEcAcceptable => 'Acceptable';

  @override
  String get zoneEcHigh => 'High';

  @override
  String get zoneEcVeryHigh => 'Very high';

  @override
  String get zoneEcWeakSolution => 'Weak solution';

  @override
  String get zoneEcConcentrated => 'Concentrated';

  @override
  String get zoneEcTooStrong => 'Too strong';

  @override
  String get zoneTdsPurified => 'Purified';

  @override
  String get zoneTdsNormal => 'Normal';

  @override
  String get zoneTdsAcceptable => 'Acceptable';

  @override
  String get zoneTdsHard => 'Hard';

  @override
  String get zoneTdsNotDrinkable => 'Not drinkable';

  @override
  String get zoneSalinityFresh => 'Fresh';

  @override
  String get zoneSalinityLow => 'Low';

  @override
  String get zoneSalinityBrackish => 'Brackish';

  @override
  String get zoneSalinityHigh => 'High';

  @override
  String get zoneTempVeryCold => 'Very cold';

  @override
  String get zoneTempCold => 'Cold';

  @override
  String get zoneTempCool => 'Cool';

  @override
  String get zoneTempRoom => 'Room';

  @override
  String get zoneTempWarm => 'Warm';

  @override
  String get zoneTempHot => 'Hot';

  @override
  String get zoneTempComfort => 'Comfort';

  @override
  String get zoneTempOverheated => 'Overheated';

  @override
  String get zoneTempAquaCold => 'Cold';

  @override
  String get zoneTempAquaCool => 'Cool';

  @override
  String get zoneTempAquaNormal => 'Normal';

  @override
  String get zoneTempAquaWarm => 'Warm';

  @override
  String get zoneTempAquaOverheat => 'Overheated';

  @override
  String get zoneSgLow => 'Low';

  @override
  String get zoneSgNormal => 'Normal';

  @override
  String get zoneSgMineralized => 'Mineralized';

  @override
  String get zoneSgVeryDense => 'Very dense';

  @override
  String get summaryAllMeasured => 'All parameters measured.';
}
