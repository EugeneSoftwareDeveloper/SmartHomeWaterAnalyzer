import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Async-провайдер для глобального доступа к [SharedPreferences]. Инициализируется один раз
/// при старте приложения через `bootstrap`-фазу или через `ProviderScope` override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider должен быть override-нут в ProviderScope при запуске',
  ),
);
