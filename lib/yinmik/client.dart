import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'commands.dart';
import 'decoder.dart';
import 'reading.dart';

/// Клиент YINMIK BLE-C600 поверх `flutter_blue_plus`. Реализует жизненный цикл:
/// проверить разрешения, отсканировать эфир, подключиться, прочитать кадр FF02, отсоединиться.
///
/// Прибор держит только одно BLE-подключение одновременно — официальное приложение YINMIK
/// и эта программа взаимоисключающи.
class YinmikBleClient {
  static final Guid serviceUuid = Guid('0000ff01-0000-1000-8000-00805f9b34fb');
  static final Guid measurementCharacteristicUuid =
      Guid('0000ff02-0000-1000-8000-00805f9b34fb');

  /// Подстроки, по которым прибор узнаётся в advertisement. Сравнение через `contains`
  /// (не `startsWith`!) — некоторые партии добавляют префикс производителя/SKU перед
  /// именем, например `BT-BLE-C600` или `Yinmik-C600-XXXX`. Сравнение нечувствительно
  /// к регистру и принимает оба разделителя `-` и `_` (часть прошивок использует
  /// подчеркивание).
  static const List<String> knownNameKeywords = <String>[
    'BLE-C600', 'BLE_C600', 'BLE C600',
    'BLE-YC', 'BLE_YC',
    'YINMIK',
    'YC01',
    'C600',
  ];

  /// Параметры устойчивости — те же дефолты, что в SmartHomeService LYWSD03MMC reader:
  /// 3 попытки с 2-секундной паузой и переподключением на каждой.
  static const int defaultMaxAttempts = 3;
  static const Duration defaultRetryDelay = Duration(seconds: 2);

  Future<PermissionResult> ensurePermissions() async {
    final scan = await Permission.bluetoothScan.request();
    final connect = await Permission.bluetoothConnect.request();

    final isOldAndroid = scan == PermissionStatus.permanentlyDenied &&
        connect == PermissionStatus.permanentlyDenied;

    if (isOldAndroid) {
      final location = await Permission.locationWhenInUse.request();
      if (!_isGrantedOrLimited(location)) return PermissionResult.locationDenied;
      return PermissionResult.granted;
    }

    if (!_isGrantedOrLimited(scan)) return PermissionResult.bluetoothScanDenied;
    if (!_isGrantedOrLimited(connect)) return PermissionResult.bluetoothConnectDenied;

    return PermissionResult.granted;
  }

  static bool _isGrantedOrLimited(PermissionStatus status) =>
      status.isGranted || status.isLimited;

  /// Сканирование с фильтром **по имени на клиенте**.
  ///
  /// Платформенный фильтр `withServices: [serviceUuid]` НЕ работает с BLE-C600: прибор
  /// (как и большинство дешёвых BLE-устройств семейства BLE-YC01) не объявляет сервис
  /// FF01 в advertisement-пакете — Android видит только имя `BLE-C600` и manufacturer data.
  ///
  /// Возвращает [ScanState] на каждое обновление: список найденных YINMIK-устройств +
  /// общее число BLE-устройств в эфире (для диагностики, чтобы понять «сканер не работает»
  /// vs «вокруг нет нужного прибора»).
  ///
  /// Подписка на `FlutterBluePlus.scanResults` через явный `listen((_) {})` обязательна:
  /// без неё поток не «прогревается» и `await for` ниже может не получать обновлений.
  Stream<ScanState> scan({Duration timeout = const Duration(seconds: 10)}) async* {
    // Если предыдущий скан ещё активен — остановить и подождать обработки stop
    // платформой. Без задержки `startScan` ниже может тихо проигнорироваться
    // (особенно после нажатия Stop в UI с быстрым повторным запуском), и поток
    // `scanResults` останется заморожен на пустом списке до перезапуска приложения.
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    final keepAlive = FlutterBluePlus.scanResults.listen((_) {});
    try {
      await FlutterBluePlus.startScan(timeout: timeout);

      await for (final results in FlutterBluePlus.scanResults) {
        final matching = results.where(_looksLikeYinmik).toList(growable: false);
        yield ScanState(matching: matching, totalScanned: results.length);
      }
    } finally {
      await keepAlive.cancel();
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    }
  }

  /// Чтение с retry: connect → MTU → read FF02 → decode → disconnect. На транзиентном
  /// сбое (InvalidOperationException / TimeoutException / FlutterBluePlusException)
  /// открывает новую сессию и пробует снова, до [maxAttempts] раз.
  Future<YinmikReading> readOnce(
    BluetoothDevice device, {
    Duration timeout = const Duration(seconds: 20),
    int maxAttempts = defaultMaxAttempts,
    Duration retryDelay = defaultRetryDelay,
  }) async {
    final effectiveAttempts = maxAttempts < 1 ? 1 : maxAttempts;

    for (var attempt = 1;; attempt++) {
      try {
        return await _readOnceInternal(device, timeout);
      } on Object catch (error) {
        if (attempt >= effectiveAttempts || !_isTransient(error)) rethrow;
        await Future<void>.delayed(retryDelay);
      }
    }
  }

  Future<YinmikReading> _readOnceInternal(BluetoothDevice device, Duration timeout) async {
    try {
      await device.connect(timeout: timeout);
      // MTU negotiation — best-effort, многие BLE-устройства поддерживают, но не все.
      try {
        await device.requestMtu(247);
      } on Object catch (_) {
        // Игнорируем — fallback на дефолтный MTU 23 байта, нашему 24-байтному кадру хватает.
      }

      final services = await device.discoverServices();
      final service = services.firstWhere(
        (item) => item.uuid == serviceUuid,
        orElse: () => throw StateError('Service $serviceUuid not found on ${device.remoteId}'),
      );
      final characteristic = service.characteristics.firstWhere(
        (item) => item.uuid == measurementCharacteristicUuid,
        orElse: () => throw StateError(
          'Characteristic $measurementCharacteristicUuid not found on ${device.remoteId}',
        ),
      );

      final raw = await characteristic.read();
      return YinmikDecoder.decodeRawFrame(Uint8List.fromList(raw));
    } finally {
      await _safeDisconnect(device);
    }
  }

  /// Запись команды + перечитывание кадра в одной сессии. Возвращает свежий `YinmikReading`
  /// (UI сразу видит применённое изменение).
  Future<YinmikReading> sendCommandAndRead(
    BluetoothDevice device,
    Uint8List command, {
    String commandName = 'неизвестная команда',
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!YinmikCommands.areCommandsKnown) {
      throw UnknownCommandException(commandName);
    }
    if (command.isEmpty) {
      throw ArgumentError.value(command, 'command', 'Команда не может быть пустой');
    }

    try {
      await device.connect(timeout: timeout);
      try {
        await device.requestMtu(247);
      } on Object catch (_) {
        // ignore
      }
      final services = await device.discoverServices();

      final service = services.firstWhere(
        (item) => item.uuid == serviceUuid,
        orElse: () => throw StateError('Service $serviceUuid not found on ${device.remoteId}'),
      );

      final commandCharacteristic = service.characteristics.firstWhere(
        (item) => item.uuid == YinmikCommands.commandCharacteristicUuid,
        orElse: () => throw StateError(
          'Command characteristic ${YinmikCommands.commandCharacteristicUuid} not found',
        ),
      );
      await commandCharacteristic.write(command);

      final measurement = service.characteristics.firstWhere(
        (item) => item.uuid == measurementCharacteristicUuid,
        orElse: () => throw StateError(
          'Characteristic $measurementCharacteristicUuid not found on ${device.remoteId}',
        ),
      );
      final raw = await measurement.read();
      return YinmikDecoder.decodeRawFrame(Uint8List.fromList(raw));
    } finally {
      await _safeDisconnect(device);
    }
  }

  Future<void> _safeDisconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } on Object catch (_) {
      // Disconnect-сбой не интересен — соединение всё равно закрывается на стороне ОС.
    }
  }

  static bool _isTransient(Object error) {
    if (error is TimeoutException) return true;
    if (error is StateError) return false; // Permanent: «сервис не найден» и т.п.
    // Прочие BLE-сбои (FlutterBluePlusException, PlatformException, обычные исключения) —
    // транзиентные. Лучше попробовать снова, чем сразу пробросить наверх.
    return true;
  }

  static bool _looksLikeYinmik(ScanResult result) {
    // Имя устройства может прийти двумя путями: `platformName` (то, что система
    // запомнила в GAP) или `advertisementData.advName` (то, что прибор объявляет
    // прямо сейчас). На холодном скане первое часто пусто, второе — нет.
    final names = <String>{
      result.device.platformName.toUpperCase(),
      result.advertisementData.advName.toUpperCase(),
    }..removeWhere((value) => value.isEmpty);

    for (final name in names) {
      if (knownNameKeywords.any(name.contains)) return true;
    }

    // Fallback: некоторые партии BLE-C600 публикуют сервис FF01 в advertisement,
    // даже когда имя отсутствует. Если поймали такой пакет — считаем прибор нашим.
    return result.advertisementData.serviceUuids.contains(serviceUuid);
  }
}

/// Текущее состояние сканирования: список устройств, прошедших фильтр + общее число
/// видимых в эфире (для диагностики).
class ScanState {
  final List<ScanResult> matching;
  final int totalScanned;

  const ScanState({required this.matching, required this.totalScanned});
}

/// Результат проверки разрешений.
enum PermissionResult {
  granted,
  bluetoothScanDenied,
  bluetoothConnectDenied,
  locationDenied;

  bool get isGranted => this == PermissionResult.granted;

  String get message => switch (this) {
        PermissionResult.granted => 'Все разрешения получены',
        PermissionResult.bluetoothScanDenied =>
          'Не дано разрешение «Устройства поблизости» (Bluetooth-сканирование).',
        PermissionResult.bluetoothConnectDenied =>
          'Не дано разрешение на подключение по Bluetooth.',
        PermissionResult.locationDenied =>
          'На этой версии Android для BLE-сканирования нужна геолокация.',
      };
}
