import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'providers/preferences_provider.dart';

void main() {
  bootstrap(() async {
    final prefs = await SharedPreferences.getInstance();

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const WaterAnalyzerApp(),
    );
  });
}
