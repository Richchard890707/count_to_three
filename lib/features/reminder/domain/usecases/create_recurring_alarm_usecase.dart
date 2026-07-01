import 'package:count_to_three/features/alarm_engine/domain/models/recurrence_input.dart';
import 'package:count_to_three/features/alarm_engine/domain/rule_engine.dart';
import 'package:count_to_three/features/reminder/domain/usecases/reschedule_window_usecase.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';
import 'package:drift/drift.dart';

class CreateRecurringAlarmUseCase {
  const CreateRecurringAlarmUseCase({
    required this.reminderDao,
    required this.recurrenceRuleDao,
    required this.ruleEngine,
    required this.rescheduleWindow,
  });

  final ReminderDao reminderDao;
  final RecurrenceRuleDao recurrenceRuleDao;
  final RuleEngine ruleEngine;
  final RescheduleWindowUseCase rescheduleWindow;

  Future<String> call({
    required String title,
    required DateTime triggerAt,
    String? userId,
    String? note,
    String? color,
    String timezone = 'Asia/Taipei',
    RecurrenceInput recurrence = RecurrenceInput.none,
    String alertLevel = 'ALARM',
    String type = 'alarm',
    String? reminderId,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final effectiveReminderId = reminderId ?? '${triggerAt.millisecondsSinceEpoch}-${nowMs % 100000}';

    // 1. Persist recurrence rule (if any) before the Reminder row so the FK
    //    exists when foreign_keys=ON is enforced.
    String? rruleId;
    if (recurrence.freq != RecurrenceFreq.none) {
      final compiled = ruleEngine.compile(recurrence)!;
      rruleId = 'rrule_$effectiveReminderId';
      await recurrenceRuleDao.upsert(RecurrenceRulesCompanion(
        id: Value(rruleId),
        rruleString: Value(compiled.rruleString),
        freq: Value(compiled.freq),
        interval: Value(compiled.interval),
        byWeekday: Value(recurrence.byWeekday?.join(',')),
        until: Value(recurrence.until?.millisecondsSinceEpoch),
        count: Value(recurrence.count),
      ));
    }

    // 2. Persist the Reminder
    await reminderDao.upsert(RemindersCompanion.insert(
      id: effectiveReminderId,
      type: type,
      title: title,
      note: Value(note),
      startAt: triggerAt.millisecondsSinceEpoch,
      timezone: Value(timezone),
      createdAt: nowMs,
      updatedAt: nowMs,
      alertLevel: Value(alertLevel),
      recurrenceRuleId: Value(rruleId),
      userId: Value(userId),
      color: Value(color),
      syncStatus: const Value('pending'),
    ));

    // 3. Expand and schedule the first window of occurrences
    await rescheduleWindow.fillForReminder(effectiveReminderId);
    return effectiveReminderId;
  }
}
