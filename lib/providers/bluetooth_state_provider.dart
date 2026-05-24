import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Стрим состояния Bluetooth-адаптера на устройстве. UI подписывается, чтобы реагировать
/// на выключение Bluetooth прямо в приложении (не «зависать» в сканировании).
final bluetoothAdapterStateProvider = StreamProvider<BluetoothAdapterState>(
  (ref) => FlutterBluePlus.adapterState,
);
