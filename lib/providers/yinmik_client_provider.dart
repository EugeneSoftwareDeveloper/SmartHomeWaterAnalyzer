import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../yinmik/client.dart';

/// Singleton-провайдер для [YinmikBleClient]. Создаётся один раз на жизнь приложения,
/// шарится между всеми экранами.
final yinmikBleClientProvider = Provider<YinmikBleClient>((ref) => YinmikBleClient());
