import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;

import '../l10n/generated/app_localizations.dart';
import '../providers/app_settings.dart';
import '../providers/bluetooth_state_provider.dart';
import '../providers/yinmik_client_provider.dart';
import '../yinmik/client.dart' show ScanState;

/// Главный экран: проверка состояния Bluetooth, сканирование и список найденных
/// устройств. На стартовом экране слева — пустота, потом по итогам сканирования
/// либо список устройств, либо сообщение об ошибке/отсутствии.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  StreamSubscription<ScanState>? _scanSubscription;
  List<ScanResult> _devices = const [];
  int _totalScanned = 0;
  bool _scanning = false;
  String? _error;
  bool _showSettingsButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    unawaited(FlutterBluePlus.stopScan());
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _devices = const [];
      _totalScanned = 0;
      _error = null;
      _showSettingsButton = false;
      _scanning = true;
    });

    final client = ref.read(yinmikBleClientProvider);
    final permission = await client.ensurePermissions();
    if (!permission.isGranted) {
      setState(() {
        _error = permission.message;
        _showSettingsButton = true;
        _scanning = false;
      });
      return;
    }

    await _scanSubscription?.cancel();
    _scanSubscription = client.scan(timeout: const Duration(seconds: 10)).listen(
          (state) => setState(() {
            _devices = state.matching;
            _totalScanned = state.totalScanned;
          }),
          onError: (Object error) => setState(() {
            _error = '$error';
            _scanning = false;
          }),
          onDone: () {
            if (mounted) setState(() => _scanning = false);
          },
        );
  }

  /// Диагностический режим: показать ВСЕ BLE-устройства, которые увидел сканер, без
  /// фильтра по имени. Полезно, если прибор называется не «BLE-C600», а как-то иначе.
  Future<void> _showAllDevices() async {
    final results = await FlutterBluePlus.scanResults.first;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Все видимые BLE-устройства. Если прибор здесь — нажми, '
                      'чтобы подключиться (минуя фильтр по имени).',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = results[index];
                        final name = result.device.platformName.isEmpty
                            ? '(без имени)'
                            : result.device.platformName;
                        return ListTile(
                          leading: const Icon(Icons.bluetooth),
                          title: Text(name),
                          subtitle: Text(
                            '${result.device.remoteId.str} • RSSI ${result.rssi}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _openReading(result.device);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openReading(BluetoothDevice device) async {
    await HapticFeedback.selectionClick();
    await FlutterBluePlus.stopScan();
    if (!mounted) return;
    setState(() => _scanning = false);

    await ref.read(appSettingsProvider.notifier).rememberDevice(device.remoteId.str);
    if (!mounted) return;

    await context.push('/device', extra: device);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final adapterState = ref.watch(bluetoothAdapterStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.historyTitle,
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Справка',
            onPressed: () => context.push('/help'),
          ),
          IconButton(
            icon: Icon(_scanning ? Icons.stop : Icons.refresh),
            tooltip: _scanning ? l10n.scanStopButton : l10n.scanButton,
            onPressed: () async {
              if (_scanning) {
                await FlutterBluePlus.stopScan();
                if (mounted) setState(() => _scanning = false);
              } else {
                await _startScan();
              }
            },
          ),
        ],
      ),
      body: adapterState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(message: '$error', onRetry: _startScan),
        data: (state) {
          if (state != BluetoothAdapterState.on) {
            return _BluetoothOffBody(l10n: l10n);
          }
          return _buildScanBody(l10n);
        },
      ),
    );
  }

  Widget _buildScanBody(AppL10n l10n) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _startScan, child: Text(l10n.scanRetryButton)),
            if (_showSettingsButton) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings),
                label: Text(l10n.permissionOpenSettings),
              ),
            ],
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_scanning) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.scanSearching),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.scanHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'BLE-устройств в эфире: $_totalScanned',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.bluetooth_searching),
                label: Text(l10n.scanButton),
              ),
              if (_totalScanned > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Сканер нашёл $_totalScanned устройств(а), но среди них нет BLE-C600.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _showAllDevices,
                  child: const Text('Показать все устройства'),
                ),
              ],
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _devices.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = _devices[index];
        final name = result.device.platformName.isEmpty
            ? l10n.scanNoDeviceName
            : result.device.platformName;
        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(name),
          subtitle: Text('${result.device.remoteId.str}  •  RSSI ${result.rssi}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openReading(result.device),
        );
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(l10n.scanRetryButton)),
        ],
      ),
    );
  }
}

class _BluetoothOffBody extends StatelessWidget {
  final AppL10n l10n;

  const _BluetoothOffBody({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_disabled, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(l10n.bluetoothOffTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.bluetoothOffSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          // Android: попытка программно включить Bluetooth (требует BLUETOOTH_CONNECT в манифесте).
          // На iOS метод бросает исключение — поэтому try/catch.
          FilledButton.icon(
            icon: const Icon(Icons.bluetooth),
            label: const Text('Включить Bluetooth'),
            onPressed: () async {
              try {
                await FlutterBluePlus.turnOn();
              } on Object catch (_) {
                // Тихо игнорируем — пользователь сам зайдёт в настройки.
              }
            },
          ),
        ],
      ),
    );
  }
}
