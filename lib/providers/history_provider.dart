import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../history/database.dart';
import '../history/repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(appDatabaseProvider)),
);

final recentMeasurementsProvider = StreamProvider<List<Measurement>>(
  (ref) => ref.watch(historyRepositoryProvider).watchRecent(),
);
