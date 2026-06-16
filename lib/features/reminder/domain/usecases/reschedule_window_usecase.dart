import 'dart:io';

import 'package:count_to_three/features/alarm_engine/domain/alarm_scheduler.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_request.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/notification_request.dart';
import 'package:count_to_three/features/alarm_engine/domain/notification_scheduler.dart';
import 'package:count_to_three/features/alarm_engine/domain/rule_engine.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/shared/database/daos/occurrence_dao.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';
import 'package:drift/drift.dart';

class RescheduleWindowUseCase {
  const RescheduleWindowUseCase({
    required this.reminderDao,
    required this.occurrenceDao,
    required this.recurrenceRuleDao,
    required this.scheduler,
    required this.ruleEngine,
    required this.notificationScheduler,
  });

  final ReminderDao reminderDao;
  final OccurrenceDao occurrenceDao;
  final RecurrenceRuleDao recurrenceRuleDao;
  final AlarmScheduler scheduler;
  final RuleEngine ruleEngine;
  final NotificationScheduler notificationScheduler;

  // Android allows ≤100 exact alarms; iOS AlarmKit ≤50
  int get _windowSize => Platform.isIOS ? 50 : 100;

  /// Full reschedule: mark missed occurrences then refill window for every
  /// active reminder. Called on app boot (App.initState) and after time changes.
  Future<void> call() async {
    final now = DateTime.now();
    await occurrenceDao.markMissedBefore(now.millisecondsSinceEpoch);
    final reminders = await reminderDao.getAll();
    for (final reminder in reminders) {
      await _fillWindow(reminder, now);
    }
  }

  /// Refill scheduling window for a single reminder.
  /// Called after an alarm fires/snoozes/dismisses so the next occurrence gets
  /// scheduled without waiting for the next boot reschedule.
  Future<void> fillForReminder(String reminderId) async {
    final reminder = await reminderDao.findById(reminderId);
    if (reminder == null) return;
    await _fillWindow(reminder, DateTime.now());
  }

  Future<void> _fillWindow(Reminder reminder, DateTime now) async {
    final nowMs = now.millisecondsSinceEpoch;
    final pending = await occurrenceDao.getFuturePendingByReminder(
      reminder.id,
      nowMs,
    );

    final needed = _windowSize - pending.length;
    if (needed <= 0) return;

    final dtStart = DateTime.fromMillisecondsSinceEpoch(reminder.startAt);
    List<DateTime> newTimes;

    if (reminder.recurrenceRuleId == null) {
      newTimes =
          (pending.isEmpty && dtStart.isAfter(now)) ? [dtStart] : const [];
    } else {
      final rule = await recurrenceRuleDao.findById(reminder.recurrenceRuleId!);
      if (rule == null) return;

      final expandFrom = pending.isEmpty
          ? now
          : DateTime.fromMillisecondsSinceEpoch(pending.last.scheduledAt);

      newTimes = ruleEngine.nextOccurrences(
        rule.rruleString,
        dtStart: dtStart,
        from: expandFrom,
        limit: needed,
      );
    }

    for (final time in newTimes) {
      final scheduledMs = time.millisecondsSinceEpoch;
      final occurrenceId = '${reminder.id}_$scheduledMs';
      final notifId = scheduledMs ~/ 1000 % 1000000;

      await occurrenceDao.upsert(OccurrencesCompanion(
        id: Value(occurrenceId),
        reminderId: Value(reminder.id),
        scheduledAt: Value(scheduledMs),
        osScheduled: const Value(true),
      ));

      switch (reminder.alertLevel) {
        case 'ALARM':
          await scheduler.scheduleAlarm(AlarmRequest(
            alarmId: notifId,
            reminderId: reminder.id,
            title: reminder.title,
            triggerAt: time,
          ));
        case 'NOTIFICATION':
          await notificationScheduler.scheduleNotification(NotificationRequest(
            id: notifId,
            reminderId: reminder.id,
            title: reminder.title,
            triggerAt: time,
          ));
        case 'SILENT':
          // Occurrence row recorded; no OS scheduling needed
          break;
      }
    }
  }
}
