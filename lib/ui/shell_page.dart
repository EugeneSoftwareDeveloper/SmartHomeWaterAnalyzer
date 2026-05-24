import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../l10n/generated/app_localizations.dart';
import 'history_page.dart';
import 'reading_page.dart';
import 'settings_page.dart';

/// Главный экран с подключённым устройством — три вкладки: показания, история, настройки.
class ShellPage extends StatefulWidget {
  final BluetoothDevice device;
  final int initialTab;

  const ShellPage({super.key, required this.device, this.initialTab = 0});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late int _index = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final pages = [
      ReadingPage(device: widget.device),
      const HistoryPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.water_drop_outlined),
            selectedIcon: const Icon(Icons.water_drop),
            label: l10n.tabReading,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
