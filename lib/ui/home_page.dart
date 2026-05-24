import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../yinmik/client.dart';
import 'reading_page.dart';

/// Главный экран: сканирование BLE и список найденных YINMIK-устройств. По тапу — подключение
/// и переход на [ReadingPage]. Стартует scan при открытии и предлагает повторить вручную.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final YinmikBleClient _client = YinmikBleClient();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  List<ScanResult> _devices = const [];
  bool _scanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _devices = const [];
      _error = null;
      _scanning = true;
    });

    final granted = await _client.ensurePermissions();
    if (!granted) {
      setState(() {
        _error =
            'Нужны разрешения на Bluetooth и геолокацию (для сканирования BLE на Android).';
        _scanning = false;
      });
      return;
    }

    _scanSubscription?.cancel();
    _scanSubscription = _client.scan(timeout: const Duration(seconds: 10)).listen(
          (results) => setState(() => _devices = results),
          onError: (error) => setState(() {
            _error = '$error';
            _scanning = false;
          }),
          onDone: () => setState(() => _scanning = false),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Analyzer'),
        actions: [
          IconButton(
            icon: Icon(_scanning ? Icons.stop : Icons.refresh),
            tooltip: _scanning ? 'Остановить сканирование' : 'Сканировать заново',
            onPressed: _scanning
                ? () async {
                    await FlutterBluePlus.stopScan();
                    if (mounted) setState(() => _scanning = false);
                  }
                : _startScan,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
            FilledButton(onPressed: _startScan, child: const Text('Повторить')),
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
              const Text('Поиск BLE-C600...'),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Включи прибор длинным нажатием ON/OFF и убедись, что официальное приложение YINMIK не подключено к нему.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ] else
              FilledButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.bluetooth_searching),
                label: const Text('Сканировать'),
              ),
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
            ? '(no name)'
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

  Future<void> _openReading(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    if (!mounted) return;
    setState(() => _scanning = false);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadingPage(device: device, client: _client),
      ),
    );
  }
}
