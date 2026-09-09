import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_analyzer/providers/app_settings.dart';

/// Тесты запоминания последнего прибора — это то, на чём держится кнопка быстрого
/// переподключения на главном экране.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppSettingsNotifier> createNotifier([Map<String, Object> initialValues = const {}]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    return AppSettingsNotifier(await SharedPreferences.getInstance());
  }

  group('AppSettingsNotifier.rememberDevice', () {
    test('сохраняет id и имя прибора', () async {
      final notifier = await createNotifier();

      await notifier.rememberDevice('AA:BB:CC:DD:EE:FF', deviceName: 'BLE-C600');

      expect(notifier.state.lastDeviceId, 'AA:BB:CC:DD:EE:FF');
      expect(notifier.state.lastDeviceName, 'BLE-C600');
    });

    test('пустое имя не сохраняется — UI покажет MAC вместо пустой строки', () async {
      final notifier = await createNotifier();

      await notifier.rememberDevice('AA:BB', deviceName: '');

      expect(notifier.state.lastDeviceId, 'AA:BB');
      expect(notifier.state.lastDeviceName, isNull);
    });

    test('имя из одних пробелов тоже отбрасывается', () async {
      final notifier = await createNotifier();

      await notifier.rememberDevice('AA:BB', deviceName: '   ');

      expect(notifier.state.lastDeviceName, isNull);
    });

    test('имя обрезается по краям', () async {
      final notifier = await createNotifier();

      await notifier.rememberDevice('AA:BB', deviceName: '  BLE-C600  ');

      expect(notifier.state.lastDeviceName, 'BLE-C600');
    });

    test('подключение к безымянному прибору стирает имя предыдущего', () async {
      final notifier = await createNotifier();
      await notifier.rememberDevice('AA:BB', deviceName: 'BLE-C600');

      await notifier.rememberDevice('CC:DD');

      expect(notifier.state.lastDeviceId, 'CC:DD');
      expect(
        notifier.state.lastDeviceName,
        isNull,
        reason: 'иначе кнопка предложила бы подключиться к CC:DD под именем BLE-C600',
      );
    });

    test('значения переживают пересоздание notifier (persist в prefs)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await AppSettingsNotifier(prefs).rememberDevice('AA:BB', deviceName: 'BLE-C600');

      final restored = AppSettingsNotifier(prefs);

      expect(restored.state.lastDeviceId, 'AA:BB');
      expect(restored.state.lastDeviceName, 'BLE-C600');
    });
  });

  group('AppSettingsNotifier.forgetDevice', () {
    test('чистит и id, и имя', () async {
      final notifier = await createNotifier();
      await notifier.rememberDevice('AA:BB', deviceName: 'BLE-C600');

      await notifier.forgetDevice();

      expect(notifier.state.lastDeviceId, isNull);
      expect(notifier.state.lastDeviceName, isNull);
    });

    test('забытый прибор не возвращается после пересоздания notifier', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = AppSettingsNotifier(prefs);
      await notifier.rememberDevice('AA:BB', deviceName: 'BLE-C600');
      await notifier.forgetDevice();

      final restored = AppSettingsNotifier(prefs);

      expect(restored.state.lastDeviceId, isNull);
      expect(restored.state.lastDeviceName, isNull);
    });
  });

  test('настройки, сохранённые до появления lastDeviceName, читаются без имени', () async {
    // Обратная совместимость: у пользователя с версии 1.1.x в prefs есть только id.
    final notifier = await createNotifier({'settings.lastDeviceId': 'AA:BB'});

    expect(notifier.state.lastDeviceId, 'AA:BB');
    expect(notifier.state.lastDeviceName, isNull);
  });

  group('AppSettingsNotifier.setLocale', () {
    test('по умолчанию язык не выбран — значит, определяется по системе', () async {
      final notifier = await createNotifier();

      expect(notifier.state.locale, isNull);
    });

    test('выбранный язык переживает перезапуск', () async {
      final notifier = await createNotifier();

      await notifier.setLocale(const Locale('en'));

      expect(notifier.state.locale, const Locale('en'));
      final restarted = await createNotifier({'settings.locale': 'en'});
      expect(restarted.state.locale, const Locale('en'));
    });

    test('возврат к автоопределению стирает выбор, а не подставляет язык', () async {
      // `null` из-за `??` в copyWith откатился бы к прежнему языку, и «По системе»
      // нельзя было бы выбрать обратно.
      SharedPreferences.setMockInitialValues({'settings.locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = AppSettingsNotifier(prefs);

      await notifier.setLocale(null);

      expect(notifier.state.locale, isNull);
      expect(
        prefs.getString('settings.locale'),
        isNull,
        reason: 'иначе выбор вернётся при запуске',
      );
    });

    test('язык, который приложение больше не поддерживает, читается как автоопределение', () async {
      // Показывать интерфейс на первом попавшемся языке хуже, чем на системном.
      final notifier = await createNotifier({'settings.locale': 'de'});

      expect(notifier.state.locale, isNull);
    });

    test('смена языка не задевает остальные настройки', () async {
      final notifier = await createNotifier({
        'settings.lastDeviceId': 'AA:BB',
        'settings.notificationsEnabled': true,
      });

      await notifier.setLocale(const Locale('ru'));

      expect(notifier.state.lastDeviceId, 'AA:BB');
      expect(notifier.state.notificationsEnabled, isTrue);
    });
  });
}
