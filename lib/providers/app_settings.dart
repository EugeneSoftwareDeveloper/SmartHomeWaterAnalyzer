import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
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

  /// Выбранный источник — ссылка на строку каталога, а не имя.
  ///
  /// Здесь ссылка уместна, в отличие от сохранённого замера: это «что выбрано
  /// прямо сейчас», а не исторический факт. Если источник удалят, выбор должен
  /// сброситься, а не остаться указывать на несуществующее имя.
  final int? currentSourceId;

  /// Плоское имя места, выбранное в версиях до 1.4.0.
  ///
  /// Настройки грузятся синхронно и без доступа к БД, поэтому превратить имя в
  /// ссылку прямо при загрузке нельзя. Значение доживает до первого открытия
  /// экрана показаний, там резолвится по `legacyLabel` источника и стирается.
  final String? legacySelectedLabel;

  /// Прикреплять ли координаты к сохраняемым замерам. Включено по умолчанию:
  /// геометка — заявленная функция приложения, а разрешение всё равно
  /// запрашивается системой при первом сохранении. Отказ в разрешении не ломает
  /// сохранение — замер просто останется без координат.
  final bool saveLocationEnabled;

  /// Выбранный язык интерфейса. `null` — определять по системе.
  ///
  /// Отдельное значение вместо «языка по умолчанию» нужно, чтобы отличить
  /// «пользователь не выбирал» от «пользователь выбрал ровно тот язык, который
  /// сейчас в системе»: в первом случае смена языка телефона должна менять и
  /// язык приложения, во втором — нет.
  final Locale? locale;

  const AppSettings({
    required this.themeMode,
    required this.normsProfile,
    required this.lastDeviceId,
    required this.lastDeviceName,
    required this.notificationsEnabled,
    required this.currentSourceId,
    required this.legacySelectedLabel,
    required this.saveLocationEnabled,
    required this.locale,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    NormsProfile? normsProfile,
    String? lastDeviceId,
    String? lastDeviceName,
    bool? notificationsEnabled,
    int? currentSourceId,
    String? legacySelectedLabel,
    bool? saveLocationEnabled,
    Locale? locale,
    bool clearLastDevice = false,
    // Отдельный флаг для имени: подключение к безымянному прибору должно стирать имя
    // предыдущего, а `lastDeviceName: null` из-за `??` ниже откатился бы к старому
    // значению — и кнопка показала бы чужое имя рядом с новым MAC.
    bool clearLastDeviceName = false,
    bool clearSource = false,
    bool clearLegacySelection = false,
    // Тот же приём, что и с прибором: `locale: null` из-за `??` откатился бы к
    // прежнему языку, и «По системе» нельзя было бы выбрать обратно.
    bool clearLocale = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      normsProfile: normsProfile ?? this.normsProfile,
      lastDeviceId: clearLastDevice ? null : (lastDeviceId ?? this.lastDeviceId),
      lastDeviceName: (clearLastDevice || clearLastDeviceName)
          ? null
          : (lastDeviceName ?? this.lastDeviceName),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currentSourceId: clearSource ? null : (currentSourceId ?? this.currentSourceId),
      legacySelectedLabel: clearLegacySelection
          ? null
          : (legacySelectedLabel ?? this.legacySelectedLabel),
      saveLocationEnabled: saveLocationEnabled ?? this.saveLocationEnabled,
      locale: clearLocale ? null : (locale ?? this.locale),
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
  static const _kCurrentSource = 'settings.currentSourceId';

  /// Ключ версий до 1.4.0. Читается один раз ради переноса выбора и удаляется.
  static const _kLegacyCurrentLabel = 'settings.currentLabel';
  static const _kSaveLocation = 'settings.saveLocationEnabled';
  static const _kLocale = 'settings.locale';

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
      currentSourceId: prefs.getInt(_kCurrentSource),
      legacySelectedLabel: prefs.getString(_kLegacyCurrentLabel),
      saveLocationEnabled: prefs.getBool(_kSaveLocation) ?? true,
      locale: _readLocale(prefs.getString(_kLocale)),
    );
  }

  /// Превращает сохранённый код языка в поддерживаемую локаль.
  ///
  /// Неизвестный код — это язык, который приложение когда-то поддерживало, а
  /// теперь нет. Такой выбор молча становится автоопределением: показывать
  /// интерфейс на первом попавшемся языке хуже, чем на системном.
  static Locale? _readLocale(String? code) {
    if (code == null) return null;
    for (final locale in AppL10n.supportedLocales) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }

  /// Задаёт язык интерфейса. `null` возвращает автоопределение по системе.
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      state = state.copyWith(clearLocale: true);
      await _prefs.remove(_kLocale);
    } else {
      state = state.copyWith(locale: locale);
      await _prefs.setString(_kLocale, locale.languageCode);
    }
  }

  Future<void> setSaveLocationEnabled(bool enabled) async {
    state = state.copyWith(saveLocationEnabled: enabled);
    await _prefs.setBool(_kSaveLocation, enabled);
  }

  Future<void> setCurrentSource(int? sourceId) async {
    if (sourceId == null) {
      state = state.copyWith(clearSource: true);
      await _prefs.remove(_kCurrentSource);
    } else {
      state = state.copyWith(currentSourceId: sourceId);
      await _prefs.setInt(_kCurrentSource, sourceId);
    }
  }

  /// Забывает плоский выбор версий до 1.4.0 — после того, как он превращён в
  /// ссылку на источник или оказался ссылкой в никуда.
  Future<void> clearLegacySelection() async {
    if (state.legacySelectedLabel == null) return;
    state = state.copyWith(clearLegacySelection: true);
    await _prefs.remove(_kLegacyCurrentLabel);
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
    final name = (deviceName == null || deviceName.trim().isEmpty) ? null : deviceName.trim();

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
