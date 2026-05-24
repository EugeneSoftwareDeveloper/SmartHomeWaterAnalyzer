import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

import 'history/database.dart';
import 'ui/debug_commands_page.dart';
import 'ui/help_page.dart';
import 'ui/history_detail_page.dart';
import 'ui/history_page.dart';
import 'ui/home_page.dart';
import 'ui/shell_page.dart';

/// Маршруты приложения.
/// - `/` — главный экран сканирования.
/// - `/device` — подключённое устройство (ShellPage с тремя вкладками).
/// - `/history` — история, доступная без подключения.
/// - `/history/detail` — детальный просмотр одного замера со свайпом.
/// - `/help` — справка по параметрам, опциональный `extra` — ключ параметра для фокуса.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/device',
      builder: (context, state) {
        final device = state.extra! as BluetoothDevice;
        return ShellPage(device: device);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(standalone: true),
    ),
    GoRoute(
      path: '/history/detail',
      builder: (context, state) {
        final args = state.extra! as HistoryDetailArgs;
        return HistoryDetailPage(measurements: args.measurements, initialIndex: args.index);
      },
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) {
        final focusedKey = state.extra as String?;
        return HelpPage(focusedKey: focusedKey);
      },
    ),
    GoRoute(
      path: '/debug-commands',
      builder: (context, state) {
        final device = state.extra! as BluetoothDevice;
        return DebugCommandsPage(device: device);
      },
    ),
  ],
);

/// Аргументы для перехода в детальный просмотр истории.
class HistoryDetailArgs {
  final List<Measurement> measurements;
  final int index;

  const HistoryDetailArgs({required this.measurements, required this.index});
}
