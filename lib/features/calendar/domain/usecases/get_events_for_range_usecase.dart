import 'package:count_to_three/features/alarm_engine/domain/rule_engine.dart';
import 'package:count_to_three/features/calendar/domain/models/calendar_event.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';

class GetEventsForRangeUseCase {
  const GetEventsForRangeUseCase({
    required this.reminderDao,
    required this.recurrenceRuleDao,
    required this.ruleEngine,
  });

  final ReminderDao reminderDao;
  final RecurrenceRuleDao recurrenceRuleDao;
  final RuleEngine ruleEngine;

  /// Returns a map keyed by midnight DateTime → sorted list of [CalendarEvent].
  Future<Map<DateTime, List<CalendarEvent>>> call(
    DateTime rangeStart,
    DateTime rangeEnd,
  ) async {
    final reminders = await reminderDao.getAll();
    final result = <DateTime, List<CalendarEvent>>{};

    for (final reminder in reminders) {
      final dtStart = DateTime.fromMillisecondsSinceEpoch(reminder.startAt);
      List<DateTime> times;

      if (reminder.recurrenceRuleId == null) {
        // One-time: include only if startAt falls within range
        times = (!dtStart.isBefore(rangeStart) && !dtStart.isAfter(rangeEnd))
            ? [dtStart]
            : const [];
      } else {
        final rule = await recurrenceRuleDao.findById(reminder.recurrenceRuleId!);
        if (rule == null) continue;
        times = ruleEngine.occurrencesBetween(
          rule.rruleString,
          dtStart: dtStart,
          start: rangeStart,
          end: rangeEnd,
        );
      }

      for (final t in times) {
        final key = DateTime(t.year, t.month, t.day); // midnight key
        (result[key] ??= []).add(CalendarEvent(reminder: reminder, occurrenceTime: t));
      }
    }

    // Sort each day's events chronologically
    for (final list in result.values) {
      list.sort((a, b) => a.occurrenceTime.compareTo(b.occurrenceTime));
    }
    return result;
  }
}
