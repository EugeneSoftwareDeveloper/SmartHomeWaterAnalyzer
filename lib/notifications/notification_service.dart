import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../l10n/generated/app_localizations.dart';
import '../quality/overview.dart';

/// Сервис локальных уведомлений: вызывается, когда измерение показывает параметры вне нормы.
///
/// Реальная отправка обёрнута в try/catch — если разрешения не выданы или платформа не
/// поддерживает уведомления, ошибка глотается, чтобы не валить основной флоу чтения.
class NotificationService {
  static const _channelId = 'water_quality_alerts';

  /// Имя и описание канала задаются один раз при создании и в системных
  /// настройках Android остаются такими навсегда: переименование канала
  /// требует его пересоздания, а это сбрасывает выбор пользователя. Поэтому
  /// они не переводятся — в отличие от текста самих уведомлений.
  static const _channelName = 'Water quality';
  static const _channelDescription = 'Alerts when a parameter goes out of range';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Создание канала уведомлений (Android 8+).
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
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
  ///
  /// [l10n] передаётся вызывающим: сервис живёт вне дерева виджетов, а язык
  /// выбран в настройках приложения, и угадать его отсюда нечем.
  Future<void> notifyIfOutOfRange(WaterQualityOverview overview, AppL10n l10n) async {
    if (!_initialized) return;
    if (overview.isAllGood) return;
    if (overview.problematicParameters.isEmpty) return;

    final names = overview.problematicParameters.map((item) => item.label).join(', ');

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        overview.headline(l10n),
        l10n.summaryProblematic(names),
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
