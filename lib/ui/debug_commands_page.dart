import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../yinmik/decoder.dart';
import '../yinmik/reading.dart';

/// Страница отладки команд: пресеты байтов + ручной ввод hex для подбора правильной
/// команды управления подсветкой и удержанием. Делает «send и verify»: после записи
/// перечитывает кадр и показывает, изменился ли соответствующий бит статуса.
class DebugCommandsPage extends ConsumerStatefulWidget {
  final BluetoothDevice device;

  const DebugCommandsPage({super.key, required this.device});

  @override
  ConsumerState<DebugCommandsPage> createState() => _DebugCommandsPageState();
}

class _DebugCommandsPageState extends ConsumerState<DebugCommandsPage> {
  /// Выбранная характеристика для записи.
  late Guid _targetUuid = _ff15;

  /// Ручной ввод hex-строки («08» или «01 08»).
  final _hexController = TextEditingController(text: '08');

  /// Какой бит сравнивать после записи: 0x08 = подсветка, 0x10 = HOLD.
  int _verifyBit = 0x08;

  /// Лог последних попыток: что отправили, что получили.
  final List<_AttemptLog> _log = [];

  bool _busy = false;

  static final Guid _ff15 = Guid('0000ff15-0000-1000-8000-00805f9b34fb');
  static final Guid _ff02 = Guid('0000ff02-0000-1000-8000-00805f9b34fb');

  /// Готовые пресеты для перебора. Назначение в комментариях — какую гипотезу проверяем.
  static const List<_Preset> _presets = [
    _Preset(label: 'Подсветка: бит статуса', bytes: [0x08], verifyBit: 0x08),
    _Preset(label: 'Подсветка OFF', bytes: [0x00], verifyBit: 0x08),
    _Preset(label: 'HOLD: бит статуса', bytes: [0x10], verifyBit: 0x10),
    _Preset(label: 'HOLD OFF', bytes: [0x00], verifyBit: 0x10),
    _Preset(label: 'Opcode 01 + 01', bytes: [0x01, 0x01], verifyBit: 0x08),
    _Preset(label: 'Opcode 01 + 00', bytes: [0x01, 0x00], verifyBit: 0x08),
    _Preset(label: 'Opcode 02 + 01', bytes: [0x02, 0x01], verifyBit: 0x10),
    _Preset(label: 'Opcode 02 + 00', bytes: [0x02, 0x00], verifyBit: 0x10),
    _Preset(label: 'Префикс A5 + 08', bytes: [0xA5, 0x08], verifyBit: 0x08),
    _Preset(label: 'Префикс A5 + 10', bytes: [0xA5, 0x10], verifyBit: 0x10),
    _Preset(label: 'Префикс A5 + 00', bytes: [0xA5, 0x00], verifyBit: 0x08),
    _Preset(label: 'Toggle byte AA', bytes: [0xAA], verifyBit: 0x08),
    _Preset(label: 'Toggle byte 55', bytes: [0x55], verifyBit: 0x08),
    _Preset(label: 'Status mask 18', bytes: [0x18], verifyBit: 0x08),
  ];

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Отладка команд')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Эта страница пробует разные байты команды и проверяет, изменился ли бит '
                    'статуса 0x08 (подсветка) или 0x10 (HOLD) в кадре FF02 после записи. '
                    'Если какой-то пресет сработает — увидишь «✓ бит изменился» в логе.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Целевая характеристика'),
          RadioListTile<Guid>(
            value: _ff15,
            // ignore: deprecated_member_use
            groupValue: _targetUuid,
            title: const Text('FF15 (сервисная)'),
            subtitle: const Text('Канонический кандидат для команд'),
            // ignore: deprecated_member_use
            onChanged: (value) => setState(() => _targetUuid = value!),
          ),
          RadioListTile<Guid>(
            value: _ff02,
            // ignore: deprecated_member_use
            groupValue: _targetUuid,
            title: const Text('FF02 (характеристика данных)'),
            subtitle: const Text('У некоторых вариантов поддерживает write'),
            // ignore: deprecated_member_use
            onChanged: (value) => setState(() => _targetUuid = value!),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Проверять бит'),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0x08, label: Text('Подсветка (0x08)')),
              ButtonSegment(value: 0x10, label: Text('HOLD (0x10)')),
            ],
            selected: {_verifyBit},
            onSelectionChanged: (set) => setState(() => _verifyBit = set.first),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Готовые пресеты'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _presets)
                ActionChip(
                  label: Text(preset.label),
                  avatar: const Icon(Icons.send, size: 16),
                  onPressed: _busy
                      ? null
                      : () => _tryPattern(preset.bytes, label: preset.label, verifyBit: preset.verifyBit),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Ручной ввод (hex, через пробел)'),
          TextField(
            controller: _hexController,
            decoration: const InputDecoration(
              hintText: 'Например: 01 08',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Отправить введённые байты'),
            onPressed: _busy ? null : _sendManual,
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 24),
          _sectionTitle('Лог попыток (новые сверху)'),
          if (_log.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Пока ничего не отправлено',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final attempt in _log.reversed) _LogEntry(attempt: attempt),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Future<void> _sendManual() async {
    final tokens = _hexController.text
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = [for (final t in tokens) int.parse(t, radix: 16)];
      await _tryPattern(bytes, label: 'Ручной: ${tokens.join(' ')}', verifyBit: _verifyBit);
    } on FormatException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Неверный hex: $error')));
    }
  }

  Future<void> _tryPattern(
    List<int> bytes, {
    required String label,
    required int verifyBit,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    await HapticFeedback.selectionClick();

    final attempt = _AttemptLog(
      label: label,
      bytes: Uint8List.fromList(bytes),
      characteristic: _targetUuid,
      verifyBit: verifyBit,
    );

    try {
      // Подключаемся
      await widget.device.connect();
      try {
        await widget.device.requestMtu(247);
      } on Object catch (_) {}

      final services = await widget.device.discoverServices();
      final mainServiceUuid = Guid('0000ff01-0000-1000-8000-00805f9b34fb');
      final mainService = services.firstWhere(
        (s) => s.uuid == mainServiceUuid,
        orElse: () => throw StateError('Сервис FF01 не найден'),
      );

      // 1) Читаем «до»
      final readUuid = Guid('0000ff02-0000-1000-8000-00805f9b34fb');
      final readChar = mainService.characteristics.firstWhere(
        (c) => c.uuid == readUuid,
        orElse: () => throw StateError('Характеристика FF02 не найдена'),
      );
      final rawBefore = await readChar.read();
      attempt.statusBefore = _safeDecode(rawBefore)?.statusFlags;

      // 2) Пишем команду
      final writeChar = _findWritable(services, _targetUuid);
      if (writeChar == null) {
        attempt.error = 'Характеристика не writable';
      } else {
        await writeChar.write(bytes);
        attempt.writeSuccess = true;
      }

      // 3) Читаем «после»
      final rawAfter = await readChar.read();
      attempt.statusAfter = _safeDecode(rawAfter)?.statusFlags;
    } on Object catch (error) {
      attempt.error = '$error';
    } finally {
      try {
        await widget.device.disconnect();
      } on Object catch (_) {}
      if (mounted) {
        setState(() {
          _log.add(attempt);
          _busy = false;
        });
        if (attempt.bitChanged) {
          await HapticFeedback.lightImpact();
        }
      }
    }
  }

  BluetoothCharacteristic? _findWritable(List<BluetoothService> services, Guid uuid) {
    for (final service in services) {
      for (final ch in service.characteristics) {
        if (ch.uuid == uuid && (ch.properties.write || ch.properties.writeWithoutResponse)) {
          return ch;
        }
      }
    }
    return null;
  }

  YinmikReading? _safeDecode(List<int> raw) {
    try {
      return YinmikDecoder.decodeRawFrame(Uint8List.fromList(raw));
    } on Object catch (_) {
      return null;
    }
  }
}

class _AttemptLog {
  final String label;
  final Uint8List bytes;
  final Guid characteristic;
  final int verifyBit;
  int? statusBefore;
  int? statusAfter;
  bool writeSuccess = false;
  String? error;

  _AttemptLog({
    required this.label,
    required this.bytes,
    required this.characteristic,
    required this.verifyBit,
  });

  bool get bitChanged {
    if (statusBefore == null || statusAfter == null) return false;
    final before = (statusBefore! & verifyBit) != 0;
    final after = (statusAfter! & verifyBit) != 0;
    return before != after;
  }

  String get bytesHex => bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
}

class _Preset {
  final String label;
  final List<int> bytes;
  final int verifyBit;

  const _Preset({required this.label, required this.bytes, required this.verifyBit});
}

class _LogEntry extends StatelessWidget {
  final _AttemptLog attempt;

  const _LogEntry({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = attempt.error != null;
    final success = attempt.bitChanged;

    Color color;
    IconData icon;
    String status;
    if (hasError) {
      color = theme.colorScheme.error;
      icon = Icons.error_outline;
      status = 'Ошибка: ${attempt.error}';
    } else if (success) {
      color = const Color(0xFF388E3C);
      icon = Icons.check_circle;
      status = 'Бит ${attempt.verifyBit.toRadixString(16)} изменился: '
          '${(attempt.statusBefore! & attempt.verifyBit) != 0 ? "ON" : "OFF"} → '
          '${(attempt.statusAfter! & attempt.verifyBit) != 0 ? "ON" : "OFF"}';
    } else {
      color = theme.colorScheme.outline;
      icon = Icons.remove_circle_outline;
      status = 'Без изменений (status ${attempt.statusBefore?.toRadixString(16) ?? "?"} → '
          '${attempt.statusAfter?.toRadixString(16) ?? "?"})';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(attempt.label),
        subtitle: Text('${attempt.bytesHex}  →  $status'),
      ),
    );
  }
}
