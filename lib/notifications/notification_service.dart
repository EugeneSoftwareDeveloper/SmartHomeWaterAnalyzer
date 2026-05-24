import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../quality/overview.dart';

/// Сервис локальных уведомлений: вызывается, когда измерение показывает параметры вне нормы.
///
/// Реальная отправка обёрнута в try/catch — если разрешения не выданы или платформа не
/// поддерживает уведомления, ошибка глотается, чтобы не валить основной флоу чтения.
class NotificationService {
  static const _channelId = 'water_quality_alerts';
  static const _channelName = 'Качество воды';
  static const _channelDescription = 'Уведомления о выходе параметров из нормы';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Создание канала уведомлений (Android 8+).
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Шлёт уведомление, если overview показывает проблемные параметры.
  Future<void> notifyIfOutOfRange(WaterQualityOverview overview) async {
    if (!_initialized) return;
    if (overview.isAllGood) return;
    if (overview.problematicParameters.isEmpty) return;

    final names = overview.problematicParameters.map((item) => item.label).join(', ');

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        overview.headline,
        'Вне нормы: $names',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } on Object catch (_) {
      // Уведомления не критичны — глотаем ошибку.
    }
  }
}
