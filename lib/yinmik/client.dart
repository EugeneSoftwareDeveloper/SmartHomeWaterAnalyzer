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
/// Прибор держит только одно BLE-подключение одновременно: официальное приложение YINMIK
/// и эта программа взаимоисключающи. Перед использованием убедись, что официальное приложение
/// отключено от прибора.
class YinmikBleClient {
  /// Основной сервис данных BLE-C600 (семейство BLE-YC01).
  static final Guid serviceUuid = Guid('0000ff01-0000-1000-8000-00805f9b34fb');

  /// Характеристика чтения кадра измерений.
  static final Guid measurementCharacteristicUuid = Guid('0000ff02-0000-1000-8000-00805f9b34fb');

  /// Подписи имён, по которым обычно рекламируется BLE-C600 и совместимые white-label.
  static const List<String> knownNamePrefixes = ['BLE-C600', 'BLE-YC', 'YINMIK'];

  /// Запрашивает у пользователя разрешения, без которых сканирование не сработает на Android 12+.
  /// Возвращает `true`, если все необходимые разрешения выданы.
  Future<bool> ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((status) => status.isGranted || status.isLimited);
  }

  /// Сканирует эфир в течение [timeout] и возвращает только устройства, похожие на BLE-C600.
  /// Фильтр — по имени (`knownNamePrefixes`); по UUID сервиса BLE-C600 в advertisement часто
  /// не виден, так что имя надёжнее.
  Stream<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 10)}) async* {
    if (await FlutterBluePlus.isScanning.first) {
      await FlutterBluePlus.stopScan();
    }

    final subscription = FlutterBluePlus.scanResults.listen((_) {});
    try {
      await FlutterBluePlus.startScan(timeout: timeout);

      await for (final results in FlutterBluePlus.scanResults) {
        yield results.where(_looksLikeYinmik).toList(growable: false);
      }
    } finally {
      await subscription.cancel();
      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
      }
    }
  }

  /// Один сеанс чтения: connect → read FF02 → decode → disconnect. Возвращает декодированный
  /// набор показаний. Любые BLE/GATT-сбои пробрасываются вверх.
  Future<YinmikReading> readOnce(BluetoothDevice device,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final completer = Completer<YinmikReading>();
    var disposed = false;

    Future<void> safeDisconnect() async {
      if (disposed) return;
      disposed = true;
      try {
        await device.disconnect();
      } catch (_) {
        // Disconnect-сбой не интересен — соединение всё равно закрывается на стороне ОС.
      }
    }

    Timer? timeoutTimer;
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException(
            'YINMIK BLE read timed out after $timeout', timeout));
      }
      safeDisconnect();
    });

    try {
      await device.connect(timeout: timeout, autoConnect: false);

      final services = await device.discoverServices();
      final service = services.firstWhere(
        (item) => item.uuid == serviceUuid,
        orElse: () => throw StateError('Service $serviceUuid not found on ${device.remoteId}'),
      );
      final characteristic = service.characteristics.firstWhere(
        (item) => item.uuid == measurementCharacteristicUuid,
        orElse: () => throw StateError(
            'Characteristic $measurementCharacteristicUuid not found on ${device.remoteId}'),
      );

      final raw = await characteristic.read();
      final reading = YinmikDecoder.decodeRawFrame(Uint8List.fromList(raw));

      if (!completer.isCompleted) {
        completer.complete(reading);
      }
    } catch (error, stackTrace) {
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    } finally {
      timeoutTimer.cancel();
      await safeDisconnect();
    }

    return completer.future;
  }

  /// Прочитать кадр + отправить команду управления в одной сессии.
  ///
  /// Если байты [command] нулевой длины или совпадают с плейсхолдером
  /// ([YinmikCommands.areCommandsKnown] = false) — бросаем [UnknownCommandException],
  /// не открывая соединение: на неизвестном байте лучше остановиться, чем рисковать
  /// зависанием прибора (по протоколу-доку он иногда требует извлечения батарей при некорректных
  /// командах).
  ///
  /// При успехе: подключение → write в [YinmikCommands.commandCharacteristicUuid] →
  /// перечитывание кадра FF02 → disconnect. Возвращаем свежий [YinmikReading], чтобы UI
  /// сразу увидел применённое изменение.
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

    final completer = Completer<YinmikReading>();
    var disposed = false;

    Future<void> safeDisconnect() async {
      if (disposed) return;
      disposed = true;
      try {
        await device.disconnect();
      } catch (_) {
        // ignore
      }
    }

    Timer? timeoutTimer;
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
            TimeoutException('YINMIK BLE command timed out after $timeout', timeout));
      }
      safeDisconnect();
    });

    try {
      await device.connect(timeout: timeout, autoConnect: false);
      final services = await device.discoverServices();

      final service = services.firstWhere(
        (item) => item.uuid == serviceUuid,
        orElse: () => throw StateError('Service $serviceUuid not found on ${device.remoteId}'),
      );

      // Запись команды.
      final commandCharacteristic = service.characteristics.firstWhere(
        (item) => item.uuid == YinmikCommands.commandCharacteristicUuid,
        orElse: () => throw StateError(
            'Command characteristic ${YinmikCommands.commandCharacteristicUuid} not found on ${device.remoteId}'),
      );
      await commandCharacteristic.write(command, withoutResponse: false);

      // Подтверждающее перечитывание состояния.
      final measurement = service.characteristics.firstWhere(
        (item) => item.uuid == measurementCharacteristicUuid,
        orElse: () => throw StateError(
            'Characteristic $measurementCharacteristicUuid not found on ${device.remoteId}'),
      );
      final raw = await measurement.read();
      final reading = YinmikDecoder.decodeRawFrame(Uint8List.fromList(raw));

      if (!completer.isCompleted) completer.complete(reading);
    } catch (error, stackTrace) {
      if (!completer.isCompleted) completer.completeError(error, stackTrace);
    } finally {
      timeoutTimer.cancel();
      await safeDisconnect();
    }

    return completer.future;
  }

  static bool _looksLikeYinmik(ScanResult result) {
    final name = result.device.platformName.toUpperCase();
    if (name.isEmpty) return false;
    return knownNamePrefixes.any(name.startsWith);
  }
}
