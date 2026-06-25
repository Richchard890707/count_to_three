import 'package:count_to_three/features/stats/domain/models/stats_data.dart';
import 'package:count_to_three/shared/database/daos/occurrence_dao.dart';

class GetStatsUseCase {
  const GetStatsUseCase({required this.occurrenceDao});
  final OccurrenceDao occurrenceDao;

  Future<StatsData> call() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final weekStart = todayStart.subtract(const Duration(days: 6));
    final ninetyDaysAgo = todayStart.subtract(const Duration(days: 90));

    final results = await Future.wait([
      occurrenceDao.countByStateInRange(
        'completed',
        todayStart.millisecondsSinceEpoch,
        todayEnd.millisecondsSinceEpoch,
      ),
      occurrenceDao.countByStateInRange(
        'missed',
        todayStart.millisecondsSinceEpoch,
        todayEnd.millisecondsSinceEpoch,
      ),
      occurrenceDao.countByStateInRange(
        'pending',
        todayStart.millisecondsSinceEpoch,
        todayEnd.millisecondsSinceEpoch,
      ),
      occurrenceDao.countByStateInRange(
        'completed',
        weekStart.millisecondsSinceEpoch,
        todayEnd.millisecondsSinceEpoch,
      ),
      occurrenceDao.countByStateInRange(
        'missed',
        weekStart.millisecondsSinceEpoch,
        todayEnd.millisecondsSinceEpoch,
      ),
      occurrenceDao.countByStateInRange('completed', 0, todayEnd.millisecondsSinceEpoch),
      occurrenceDao.countByStateInRange('missed', 0, todayEnd.millisecondsSinceEpoch),
    ]);

    final streak = await _calcStreak(
      occurrenceDao,
      ninetyDaysAgo,
      todayEnd,
      todayStart,
    );

    // Per-day stats for the last 7 days (oldest → today).
    final last7Days = <DayStats>[];
    for (int i = 6; i >= 0; i--) {
      final day = todayStart.subtract(Duration(days: i));
      final dayEnd = day.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      final doneAndMissed = await Future.wait([
        occurrenceDao.countByStateInRange(
            'completed', day.millisecondsSinceEpoch, dayEnd.millisecondsSinceEpoch),
        occurrenceDao.countByStateInRange(
            'missed', day.millisecondsSinceEpoch, dayEnd.millisecondsSinceEpoch),
      ]);
      last7Days.add(DayStats(date: day, completed: doneAndMissed[0], missed: doneAndMissed[1]));
    }

    return StatsData(
      todayCompleted: results[0],
      todayMissed: results[1],
      todayPending: results[2],
      weekCompleted: results[3],
      weekMissed: results[4],
      allTimeCompleted: results[5],
      allTimeMissed: results[6],
      currentStreak: streak,
      last7Days: last7Days,
    );
  }

  static Future<int> _calcStreak(
    OccurrenceDao dao,
    DateTime from,
    DateTime to,
    DateTime todayStart,
  ) async {
    final completions = await dao.getCompletedInRange(
      from.millisecondsSinceEpoch,
      to.millisecondsSinceEpoch,
    );

    // Build set of local "yyyy-M-d" strings that have ≥1 completion.
    final completedDays = <String>{};
    for (final occ in completions) {
      final dt = DateTime.fromMillisecondsSinceEpoch(occ.scheduledAt);
      completedDays.add('${dt.year}-${dt.month}-${dt.day}');
    }

    int streak = 0;
    for (int i = 0; i <= 90; i++) {
      final day = todayStart.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      if (completedDays.contains(key)) {
        streak++;
      } else if (i == 0) {
        // Today: pending alarms may still fire — don't break.
        continue;
      } else {
        // Days with no completions: only break if there were scheduled alarms.
        // Days where no alarms were scheduled count as rest days.
        final dayEnd = day.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        final total = await dao.countInRange(
          day.millisecondsSinceEpoch,
          dayEnd.millisecondsSinceEpoch,
        );
        if (total > 0) break; // alarms existed but none completed → streak broken
        // No alarms that day → rest day, streak continues
      }
    }
    return streak;
  }
}
