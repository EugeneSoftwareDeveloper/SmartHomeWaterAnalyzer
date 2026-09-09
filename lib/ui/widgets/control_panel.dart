import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../l10n/generated/app_localizations.dart';
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
    final l10n = AppL10n.of(context);
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
                  l10n.controlSectionTitle,
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
                  title: l10n.controlBacklight,
                  subtitle: l10n.controlBacklightSubtitle,
                  value: widget.reading.backlightOn,
                  enabled: !_sending,
                  onChanged: _toggleBacklight,
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant, indent: 56),
                _ControlTile(
                  icon: Icons.lock_open,
                  activeIcon: Icons.lock,
                  title: l10n.controlHold,
                  subtitle: l10n.controlHoldSubtitle,
                  value: widget.reading.holdReadingOn,
                  enabled: !_sending,
                  onChanged: _toggleHold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBacklight(bool on) {
    final l10n = AppL10n.of(context);
    return _runCommand(
      commandName: on ? l10n.controlBacklightOn : l10n.controlBacklightOff,
      command: YinmikCommands.backlightCommand(on: on),
    );
  }

  Future<void> _toggleHold(bool on) {
    return _runCommand(
      commandName: on ? 'HOLD ON' : 'HOLD OFF',
      command: YinmikCommands.holdCommand(on: on),
    );
  }

  Future<void> _runCommand({required String commandName, required Uint8List command}) async {
    if (_sending) return;
    // До первого await: дальше `context` может указывать на закрытый экран.
    final l10n = AppL10n.of(context);
    setState(() => _sending = true);
    await HapticFeedback.selectionClick();

    try {
      final reading = await widget.client.sendCommandAndRead(
        widget.device,
        command,
        commandName: commandName,
      );
      if (mounted) widget.onReadingUpdated(reading);
    } on UnknownCommandException {
      if (mounted) await _showCommandsUnknownDialog(commandName);
    } on Object catch (error) {
      await HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.controlCommandFailed('$error'))));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _showCommandsUnknownDialog(String commandName) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final l10n = AppL10n.of(context);
        final theme = Theme.of(context);
        return AlertDialog(
          icon: const Icon(Icons.science_outlined),
          title: Text(l10n.controlNotImplemented),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.controlNotImplementedBody(commandName), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text(l10n.controlNotImplementedWhat, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(l10n.controlNotImplementedSteps, style: theme.textTheme.bodySmall),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonGotIt)),
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
  final Future<void> Function(bool) onChanged;

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
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Switch(value: value, onChanged: enabled ? (on) => unawaited(onChanged(on)) : null),
      onTap: enabled ? () => unawaited(onChanged(!value)) : null,
    );
  }
}
