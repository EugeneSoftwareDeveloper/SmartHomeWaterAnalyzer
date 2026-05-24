import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Запускает [appBuilder] под защитой `runZonedGuarded` + глобальные обработчики ошибок Flutter
/// и платформы. Любое необработанное исключение логируется (в debug — печатается в консоль,
/// в release — гарантированно не валит UI-поток без сообщения).
///
/// В production-режиме сюда легко подключается Sentry/Crashlytics — добавь
/// `FlutterError.onError = (details) => Sentry.captureException(details.exception)`
/// и `PlatformDispatcher.instance.onError = (error, stack) { Sentry.captureException...; return true; }`
Future<void> bootstrap(FutureOr<Widget> Function() appBuilder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    // ignore: avoid_print
    if (kDebugMode) print('FlutterError: ${details.exception}\n${details.stack}');
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // ignore: avoid_print
    if (kDebugMode) print('PlatformDispatcher error: $error\n$stack');
    return true;
  };

  await runZonedGuarded(
    () async {
      final app = await appBuilder();
      runApp(app);
    },
    (error, stack) {
      // ignore: avoid_print
      if (kDebugMode) print('Zone error: $error\n$stack');
    },
  );
}
