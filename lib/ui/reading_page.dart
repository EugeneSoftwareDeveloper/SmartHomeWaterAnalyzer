import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../quality/catalog.dart';
import '../quality/overview.dart';
import '../yinmik/client.dart';
import '../yinmik/reading.dart';
import 'widgets/control_panel.dart';
import 'widgets/parameter_card.dart';
import 'widgets/summary_header.dart';

/// Экран показаний подключенного BLE-C600. При открытии — одно чтение. По кнопке
/// «Обновить» или pull-to-refresh — повторное чтение. Управление подсветкой/HOLD
/// доступно в нижней секции (см. ControlPanel).
class ReadingPage extends StatefulWidget {
  final BluetoothDevice device;
  final YinmikBleClient client;

  const ReadingPage({super.key, required this.device, required this.client});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  YinmikReading? _reading;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final reading = await widget.client.readOnce(widget.device);
      if (mounted) {
        setState(() {
          _reading = reading;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = '$error';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceName = widget.device.platformName.isEmpty
        ? widget.device.remoteId.str
        : widget.device.platformName;

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _reading == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _reading == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Не удалось прочитать показания',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _refresh, child: const Text('Повторить')),
          ],
        ),
      );
    }

    final reading = _reading;
    if (reading == null) return const SizedBox.shrink();

    final values = _extractValues(reading);
    final overview = WaterQualityOverview.compute(values);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SummaryHeader(overview: overview, reading: reading),
          ...WaterParameterCatalog.all.map((parameter) {
            final value = values[parameter.key];
            if (value == null) return const SizedBox.shrink();
            return ParameterCard(parameter: parameter, value: value);
          }),
          const SizedBox(height: 8),
          ControlPanel(
            device: widget.device,
            client: widget.client,
            reading: reading,
            onReadingUpdated: (updated) => setState(() => _reading = updated),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Map<String, double> _extractValues(YinmikReading reading) {
    return {
      WaterParameterCatalog.ph.key: reading.ph,
      WaterParameterCatalog.orp.key: reading.oxidationReductionPotentialMillivolts.toDouble(),
      WaterParameterCatalog.electricalConductivity.key:
          reading.electricalConductivityUsCm.toDouble(),
      WaterParameterCatalog.totalDissolvedSolids.key:
          reading.totalDissolvedSolidsPpm.toDouble(),
      WaterParameterCatalog.salinity.key: reading.salinityPpm.toDouble(),
      WaterParameterCatalog.temperature.key: reading.temperatureCelsius,
      WaterParameterCatalog.specificGravity.key: reading.specificGravity,
    };
  }
}
