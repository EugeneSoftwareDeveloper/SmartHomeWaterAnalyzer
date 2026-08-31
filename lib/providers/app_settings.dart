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

  /// Имя последнего прибора на момент подключения. Нужно только для подписи кнопки
  /// быстрого переподключения — само подключение идёт по [lastDeviceId]. Может быть
  /// null для записей, сохранённых до появления этого поля, или если прибор
  /// подключался без имени (тогда UI показывает MAC).
  final String? lastDeviceName;
  final bool notificationsEnabled;
  final String? currentLabel;

  /// Прикреплять ли координаты к сохраняемым замерам. Включено по умолчанию:
  /// геометка — заявленная функция приложения, а разрешение всё равно
  /// запрашивается системой при первом сохранении. Отказ в разрешении не ломает
  /// сохранение — замер просто останется без координат.
  final bool saveLocationEnabled;

  const AppSettings({
    required this.themeMode,
    required this.normsProfile,
    required this.lastDeviceId,
    required this.lastDeviceName,
    required this.notificationsEnabled,
    required this.currentLabel,
    required this.saveLocationEnabled,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    NormsProfile? normsProfile,
    String? lastDeviceId,
    String? lastDeviceName,
    bool? notificationsEnabled,
    String? currentLabel,
    bool? saveLocationEnabled,
    bool clearLastDevice = false,
    // Отдельный флаг для имени: подключение к безымянному прибору должно стирать имя
    // предыдущего, а `lastDeviceName: null` из-за `??` ниже откатился бы к старому
    // значению — и кнопка показала бы чужое имя рядом с новым MAC.
    bool clearLastDeviceName = false,
    bool clearLabel = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      normsProfile: normsProfile ?? this.normsProfile,
      lastDeviceId: clearLastDevice ? null : (lastDeviceId ?? this.lastDeviceId),
      lastDeviceName: (clearLastDevice || clearLastDeviceName)
          ? null
          : (lastDeviceName ?? this.lastDeviceName),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currentLabel: clearLabel ? null : (currentLabel ?? this.currentLabel),
      saveLocationEnabled: saveLocationEnabled ?? this.saveLocationEnabled,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static const _kThemeMode = 'settings.themeMode';
  static const _kProfile = 'settings.normsProfile';
  static const _kLastDevice = 'settings.lastDeviceId';
  static const _kLastDeviceName = 'settings.lastDeviceName';
  static const _kNotifications = 'settings.notificationsEnabled';
  static const _kCurrentLabel = 'settings.currentLabel';
  static const _kSaveLocation = 'settings.saveLocationEnabled';

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
      lastDeviceName: prefs.getString(_kLastDeviceName),
      notificationsEnabled: prefs.getBool(_kNotifications) ?? false,
      currentLabel: prefs.getString(_kCurrentLabel),
      saveLocationEnabled: prefs.getBool(_kSaveLocation) ?? true,
    );
  }

  Future<void> setSaveLocationEnabled(bool enabled) async {
    state = state.copyWith(saveLocationEnabled: enabled);
    await _prefs.setBool(_kSaveLocation, enabled);
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

  /// Запоминает прибор для быстрого переподключения. [deviceName] — то, как прибор
  /// назвался при подключении; пустое имя не сохраняем, чтобы кнопка не показывала
  /// пустую строку вместо названия.
  Future<void> rememberDevice(String deviceId, {String? deviceName}) async {
    final name = (deviceName == null || deviceName.trim().isEmpty)
        ? null
        : deviceName.trim();

    state = state.copyWith(
      lastDeviceId: deviceId,
      lastDeviceName: name,
      clearLastDeviceName: name == null,
    );
    await _prefs.setString(_kLastDevice, deviceId);
    if (name == null) {
      await _prefs.remove(_kLastDeviceName);
    } else {
      await _prefs.setString(_kLastDeviceName, name);
    }
  }

  Future<void> forgetDevice() async {
    state = state.copyWith(clearLastDevice: true);
    await _prefs.remove(_kLastDevice);
    await _prefs.remove(_kLastDeviceName);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _prefs.setBool(_kNotifications, enabled);
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(sharedPreferencesProvider)),
);
