import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Версия приложения в виде «1.2.0 (5)».
///
/// Читается из метаданных сборки, а не задаётся константой в коде: зашитая
/// строка неизбежно расходится с `pubspec.yaml` после очередного релиза, и
/// «О приложении» начинает врать.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});
