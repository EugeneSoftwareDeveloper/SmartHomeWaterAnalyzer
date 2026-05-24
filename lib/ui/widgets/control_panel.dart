import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../yinmik/client.dart';
import '../../yinmik/commands.dart';
import '../../yinmik/reading.dart';

/// Секция «Управление прибором» на экране показаний.
///
/// Сейчас доступно: переключатели подсветки и HOLD. Состояние читается из последнего
/// кадра ([YinmikReading.backlightOn] / [holdReadingOn]). При попытке переключения
/// клиент вызывает [YinmikBleClient.sendCommandAndRead]; если байты команды ещё неизвестны
/// (см. [YinmikCommands.areCommandsKnown]) — открывается диалог-инструкция вместо записи.
///
/// После успешной команды коллбек [onReadingUpdated] получает свежий кадр, чтобы родительский
/// экран синхронизировал переключатели с реальным состоянием прибора.
class ControlPanel extends StatefulWidget {
  final BluetoothDevice device;
  final YinmikBleClient client;
  final YinmikReading reading;
  final ValueChanged<YinmikReading> onReadingUpdated;

  const ControlPanel({
    super.key,
    required this.device,
    required this.client,
    required this.reading,
    required this.onReadingUpdated,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Row(
              children: [
                Text(
                  'Управление прибором',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 8),
                if (!YinmikCommands.areCommandsKnown)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'BETA',
                      style: TextStyle(
                        color: Color(0xFFB26A00),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                _ControlTile(
                  icon: Icons.lightbulb_outline,
                  activeIcon: Icons.lightbulb,
                  title: 'Подсветка',
                  subtitle: 'Включить экран прибора',
                  value: widget.reading.backlightOn,
                  enabled: !_sending,
                  onChanged: (on) => _toggleBacklight(on),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant,
                  indent: 56,
                ),
                _ControlTile(
                  icon: Icons.lock_open,
                  activeIcon: Icons.lock,
                  title: 'Удержание показаний (HOLD)',
                  subtitle: 'Зафиксировать текущие значения на экране',
                  value: widget.reading.holdReadingOn,
                  enabled: !_sending,
                  onChanged: (on) => _toggleHold(on),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBacklight(bool on) async {
    await _runCommand(
      commandName: on ? 'Подсветка ON' : 'Подсветка OFF',
      command: YinmikCommands.backlightCommand(on: on),
    );
  }

  Future<void> _toggleHold(bool on) async {
    await _runCommand(
      commandName: on ? 'HOLD ON' : 'HOLD OFF',
      command: YinmikCommands.holdCommand(on: on),
    );
  }

  Future<void> _runCommand({
    required String commandName,
    required dynamic command,
  }) async {
    if (_sending) return;
    setState(() => _sending = true);

    try {
      final reading =
          await widget.client.sendCommandAndRead(widget.device, command, commandName: commandName);
      if (mounted) widget.onReadingUpdated(reading);
    } on UnknownCommandException {
      if (mounted) await _showCommandsUnknownDialog(commandName);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось отправить команду: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _showCommandsUnknownDialog(String commandName) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          icon: const Icon(Icons.science_outlined),
          title: const Text('Команда пока не реализована'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Точные байты команды «$commandName» BLE-C600 не задокументированы '
                'производителем и пока не подтверждены реверс-инжинирингом.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Что делать:',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '1. На Android: «Параметры разработчика» → включить «Bluetooth HCI snoop log».\n'
                '2. Запустить официальное приложение YINMIK, подключиться к прибору.\n'
                '3. Переключить параметр (например, подсветку) ON и OFF.\n'
                '4. Извлечь /sdcard/btsnoop_hci.log через adb или bug report.\n'
                '5. Открыть в Wireshark, отфильтровать btatt, найти write в FF15.\n'
                '6. Записать байты в lib/yinmik/commands.dart и пересобрать.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }
}

class _ControlTile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  // ignore: unused_element_parameter
  const _ControlTile({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        value ? activeIcon : icon,
        color: value ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled ? () => onChanged(!value) : null,
    );
  }
}
