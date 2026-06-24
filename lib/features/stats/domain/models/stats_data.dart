class DayStats {
  const DayStats({required this.date, required this.completed, required this.missed});
  final DateTime date;
  final int completed;
  final int missed;
  int get total => completed + missed;
  double? get rate => total == 0 ? null : completed / total;
}

class StatsData {
  const StatsData({
    required this.todayCompleted,
    required this.todayMissed,
    required this.todayPending,
    required this.weekCompleted,
    required this.weekMissed,
    required this.allTimeCompleted,
    required this.allTimeMissed,
    required this.currentStreak,
    required this.last7Days,
  });

  final int todayCompleted;
  final int todayMissed;
  final int todayPending;
  final int weekCompleted;
  final int weekMissed;
  final int allTimeCompleted;
  final int allTimeMissed;
  final int currentStreak;
  final List<DayStats> last7Days;

  /// Completion rate in last 7 days (0.0–1.0). Null if no data.
  double? get weekCompletionRate {
    final total = weekCompleted + weekMissed;
    if (total == 0) return null;
    return weekCompleted / total;
  }

  int get todayTotal => todayCompleted + todayMissed + todayPending;
}
