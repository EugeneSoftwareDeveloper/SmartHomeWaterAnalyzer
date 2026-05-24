// ignore_for_file: deprecated_member_use
// Radio.groupValue/onChanged deprecated после Flutter 3.32; используем пока — рабочее в нашей версии.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/app_settings.dart';
import '../quality/profile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: Text(l10n.settingsProfile),
            subtitle: Text(_profileLabel(l10n, settings.normsProfile)),
            onTap: () => _showProfilePicker(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.settingsTheme),
            subtitle: Text(_themeLabel(l10n, settings.themeMode)),
            onTap: () => _showThemePicker(context, ref),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.settingsNotifications),
            value: settings.notificationsEnabled,
            onChanged: notifier.setNotificationsEnabled,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Справка по параметрам'),
            subtitle: const Text('Подробное описание pH, ORP, EC и других значений'),
            onTap: () => context.push('/help'),
          ),
          const Divider(),
          const _AboutSection(),
        ],
      ),
    );
  }

  String _profileLabel(AppL10n l10n, NormsProfile profile) => switch (profile) {
        NormsProfile.drinking => l10n.profileDrinking,
        NormsProfile.pool => l10n.profilePool,
        NormsProfile.aquariumFresh => l10n.profileAquariumFresh,
        NormsProfile.hydroponics => l10n.profileHydroponics,
      };

  String _themeLabel(AppL10n l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.system => l10n.settingsThemeSystem,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.dark => l10n.settingsThemeDark,
      };

  void _showProfilePicker(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final current = ref.read(appSettingsProvider).normsProfile;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final profile in NormsProfile.values)
              RadioListTile<NormsProfile>(
                value: profile,
                groupValue: current,
                title: Text(_profileLabel(l10n, profile)),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(appSettingsProvider.notifier).setNormsProfile(value);
                  }
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final current = ref.read(appSettingsProvider).themeMode;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: current,
                title: Text(_themeLabel(l10n, mode)),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(appSettingsProvider.notifier).setThemeMode(value);
                  }
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.settingsAbout),
      subtitle: const Text('SmartHomeWaterAnalyzer • для YINMIK BLE-C600'),
      onTap: () => showAboutDialog(
        context: context,
        applicationName: l10n.appTitle,
        applicationVersion: '1.0.0',
        applicationLegalese: 'Личный проект, лицензия будет определена позже.',
      ),
    );
  }
}
