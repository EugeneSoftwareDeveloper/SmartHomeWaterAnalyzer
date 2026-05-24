import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../quality/profile.dart';
import 'preferences_provider.dart';

/// Настройки приложения: тема, профиль норм, последнее устройство, флаг уведомлений.
/// Хранятся в [SharedPreferences].
class AppSettings {
  final ThemeMode themeMode;
  final NormsProfile normsProfile;
  final String? lastDeviceId;
  final bool notificationsEnabled;
  final String? currentLabel;

  const AppSettings({
    required this.themeMode,
    required this.normsProfile,
    required this.lastDeviceId,
    required this.notificationsEnabled,
    required this.currentLabel,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    NormsProfile? normsProfile,
    String? lastDeviceId,
    bool? notificationsEnabled,
    String? currentLabel,
    bool clearLastDevice = false,
    bool clearLabel = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      normsProfile: normsProfile ?? this.normsProfile,
      lastDeviceId: clearLastDevice ? null : (lastDeviceId ?? this.lastDeviceId),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currentLabel: clearLabel ? null : (currentLabel ?? this.currentLabel),
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static const _kThemeMode = 'settings.themeMode';
  static const _kProfile = 'settings.normsProfile';
  static const _kLastDevice = 'settings.lastDeviceId';
  static const _kNotifications = 'settings.notificationsEnabled';
  static const _kCurrentLabel = 'settings.currentLabel';

  static AppSettings _load(SharedPreferences prefs) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (item) => item.name == prefs.getString(_kThemeMode),
        orElse: () => ThemeMode.system,
      ),
      normsProfile: NormsProfile.values.firstWhere(
        (item) => item.name == prefs.getString(_kProfile),
        orElse: () => NormsProfile.drinking,
      ),
      lastDeviceId: prefs.getString(_kLastDevice),
      notificationsEnabled: prefs.getBool(_kNotifications) ?? false,
      currentLabel: prefs.getString(_kCurrentLabel),
    );
  }

  Future<void> setCurrentLabel(String? label) async {
    if (label == null || label.isEmpty) {
      state = state.copyWith(clearLabel: true);
      await _prefs.remove(_kCurrentLabel);
    } else {
      state = state.copyWith(currentLabel: label);
      await _prefs.setString(_kCurrentLabel, label);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kThemeMode, mode.name);
  }

  Future<void> setNormsProfile(NormsProfile profile) async {
    state = state.copyWith(normsProfile: profile);
    await _prefs.setString(_kProfile, profile.name);
  }

  Future<void> rememberDevice(String deviceId) async {
    state = state.copyWith(lastDeviceId: deviceId);
    await _prefs.setString(_kLastDevice, deviceId);
  }

  Future<void> forgetDevice() async {
    state = state.copyWith(clearLastDevice: true);
    await _prefs.remove(_kLastDevice);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _prefs.setBool(_kNotifications, enabled);
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(sharedPreferencesProvider)),
);
