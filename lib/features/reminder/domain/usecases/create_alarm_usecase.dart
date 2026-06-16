import 'package:count_to_three/features/alarm_engine/domain/alarm_scheduler.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_request.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/shared/database/daos/occurrence_dao.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';
import 'package:drift/drift.dart';

class CreateAlarmUseCase {
  const CreateAlarmUseCase(this._reminderDao, this._occurrenceDao, this._scheduler);

  final ReminderDao _reminderDao;
  final OccurrenceDao _occurrenceDao;
  final AlarmScheduler _scheduler;

  Future<void> call({required String title, required DateTime triggerAt}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Use epoch-seconds as a stable int ID; unique enough for single-alarm M2
    final reminderId = '${triggerAt.millisecondsSinceEpoch}-${now % 100000}';
    final occurrenceId = '$reminderId-occ';
    final alarmId = triggerAt.millisecondsSinceEpoch ~/ 1000 % 1000000;

    await _reminderDao.upsert(RemindersCompanion.insert(
      id: reminderId,
      type: 'alarm',
      title: title,
      startAt: triggerAt.millisecondsSinceEpoch,
      createdAt: now,
      updatedAt: now,
      alertLevel: const Value('ALARM'),
    ));

    await _occurrenceDao.upsert(OccurrencesCompanion.insert(
      id: occurrenceId,
      reminderId: reminderId,
      scheduledAt: triggerAt.millisecondsSinceEpoch,
    ));

    await _scheduler.scheduleAlarm(AlarmRequest(
      alarmId: alarmId,
      reminderId: reminderId,
      title: title,
      triggerAt: triggerAt,
    ));

    // Mark os-scheduled
    await _occurrenceDao.upsert(OccurrencesCompanion(
      id: Value(occurrenceId),
      reminderId: Value(reminderId),
      scheduledAt: Value(triggerAt.millisecondsSinceEpoch),
      osScheduled: const Value(true),
    ));
  }
}
