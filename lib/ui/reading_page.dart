import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_settings.dart';
import '../providers/history_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/yinmik_client_provider.dart';
import '../quality/catalog.dart';
import '../quality/overview.dart';
import '../yinmik/reading.dart';
import '../yinmik/reading_values.dart';
import 'widgets/control_panel.dart';
import 'widgets/parameter_card.dart';
import 'widgets/summary_header.dart';

/// Экран показаний подключённого BLE-C600. Делает одно чтение при открытии и при тапе на
/// «Обновить» или pull-to-refresh. После успешного чтения автоматически сохраняет запись
/// в локальную историю с текущей меткой из настроек.
class ReadingPage extends ConsumerStatefulWidget {
  final BluetoothDevice device;

  const ReadingPage({super.key, required this.device});

  @override
  ConsumerState<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage> {
  YinmikReading? _reading;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final client = ref.read(yinmikBleClientProvider);
    final history = ref.read(historyRepositoryProvider);

    try {
      final reading = await client.readOnce(widget.device);
      if (!mounted) return;
      setState(() {
        _reading = reading;
        _loading = false;
      });

      final label = ref.read(appSettingsProvider).currentLabel;
      await history.save(
        widget.device.remoteId.str,
        reading,
        DateTime.now(),
        label: label,
      );

      // Уведомление — в _refresh, а не в build. В build setState может вызвать ребилды,
      // в которых notifier стрелял бы повторно.
      if (mounted) await _maybeNotify(reading);
    } on Object catch (error) {
      if (!mounted) return;
      await HapticFeedback.mediumImpact();
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _maybeNotify(YinmikReading reading) async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.notificationsEnabled) return;

    final overview = WaterQualityOverview.compute(
      readingValues(reading),
      profile: settings.normsProfile,
    );
    if (overview.isAllGood) return;

    await ref.read(notificationServiceProvider).notifyIfOutOfRange(overview);
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
            icon: const Icon(Icons.science_outlined),
            tooltip: 'Отладка команд',
            onPressed: () => context.push('/debug-commands', extra: widget.device),
          ),
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

    final settings = ref.watch(appSettingsProvider);
    final profile = settings.normsProfile;
    final parameters = WaterParameterCatalog.forProfile(profile);
    final values = readingValues(reading);
    final overview = WaterQualityOverview.compute(values, profile: profile);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const _LabelEditor(),
          SummaryHeader(overview: overview, reading: reading),
          for (final parameter in parameters)
            if (values[parameter.key] != null)
              ParameterCard(parameter: parameter, value: values[parameter.key]!),
          const SizedBox(height: 8),
          ControlPanel(
            device: widget.device,
            client: ref.read(yinmikBleClientProvider),
            reading: reading,
            onReadingUpdated: (updated) async {
              setState(() => _reading = updated);
              final label = ref.read(appSettingsProvider).currentLabel;
              await ref.read(historyRepositoryProvider).save(
                    widget.device.remoteId.str,
                    updated,
                    DateTime.now(),
                    label: label,
                  );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Поле ввода ярлыка замера. Значение хранится в AppSettings и используется как
/// `label` для каждой сохраняемой записи истории, пока пользователь его не сменит.
class _LabelEditor extends ConsumerStatefulWidget {
  const _LabelEditor();

  @override
  ConsumerState<_LabelEditor> createState() => _LabelEditorState();
}

class _LabelEditorState extends ConsumerState<_LabelEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(appSettingsProvider).currentLabel ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.label_outline, size: 20),
          labelText: 'Метка замера',
          hintText: 'Например: Москва, квартира',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
        style: theme.textTheme.bodyMedium,
        onChanged: (value) =>
            ref.read(appSettingsProvider.notifier).setCurrentLabel(value.trim()),
      ),
    );
  }
}
