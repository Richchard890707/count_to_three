import 'package:count_to_three/features/alarm_engine/domain/alarm_scheduler.dart';
import 'package:count_to_three/features/alarm_engine/domain/notification_scheduler.dart';
import 'package:count_to_three/shared/database/daos/alarm_config_dao.dart';
import 'package:count_to_three/shared/database/daos/occurrence_dao.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';

class CompleteTodoUseCase {
  const CompleteTodoUseCase({
    required this.reminderDao,
    required this.occurrenceDao,
    required this.alarmConfigDao,
    required this.alarmScheduler,
    required this.notificationScheduler,
  });

  final ReminderDao reminderDao;
  final OccurrenceDao occurrenceDao;
  final AlarmConfigDao alarmConfigDao;
  final AlarmScheduler alarmScheduler;
  final NotificationScheduler notificationScheduler;

  Future<void> call(String reminderId) async {
    final reminder = await reminderDao.findById(reminderId);
    if (reminder == null) return;

    // Cancel all future pending occurrences
    final pending = await occurrenceDao.getFuturePendingByReminder(
      reminderId,
      0, // include everything — the reminder is done
    );

    for (final occ in pending) {
      final notifId = occ.scheduledAt ~/ 1000 % 1000000;
      switch (reminder.alertLevel) {
        case 'ALARM':
          await alarmScheduler.cancelAlarm(notifId);
          await notificationScheduler.cancelNotification(notifId + 1000000);
        case 'NOTIFICATION':
          await notificationScheduler.cancelNotification(notifId);
        case 'SILENT':
          break; // nothing scheduled, nothing to cancel
      }
    }

    // Remove all occurrence rows and alarm config — no longer needed after soft-delete
    await occurrenceDao.deleteAllByReminder(reminderId);
    await alarmConfigDao.deleteByReminder(reminderId);

    // Soft-delete with sync fields so the outbox can push isDeleted=true
    await reminderDao.softDeleteWithSync(reminderId);
  }
}
