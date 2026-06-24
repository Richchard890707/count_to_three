import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/features/stats/domain/models/stats_data.dart';
import 'package:count_to_three/features/stats/domain/usecases/get_stats_usecase.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_controller.g.dart';

@riverpod
Future<StatsData> statsController(StatsControllerRef ref) async {
  final db = ref.watch(appDatabaseProvider);
  return GetStatsUseCase(occurrenceDao: db.occurrenceDao).call();
}

/// Stream of all occurrences for today, ordered chronologically.
@riverpod
Stream<List<Occurrence>> todayOccurrences(TodayOccurrencesRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final startMs = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  final endMs = startMs + 86400000 - 1;
  return db.occurrenceDao.watchByRange(startMs, endMs);
}

/// Map of reminderId → reminder title for all reminders.
@riverpod
Stream<Map<String, String>> reminderTitleMap(ReminderTitleMapRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.reminderDao.watchAll().map(
        (list) => {for (final r in list) r.id: r.title},
      );
}
