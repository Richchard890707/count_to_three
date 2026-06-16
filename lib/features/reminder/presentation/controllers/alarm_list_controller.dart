import 'package:count_to_three/core/providers/alarm_scheduler_provider.dart';
import 'package:count_to_three/core/providers/auth_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/core/providers/rule_engine_provider.dart';
import 'package:count_to_three/core/providers/sync_provider.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/recurrence_input.dart';
import 'package:count_to_three/features/reminder/domain/models/reminder_enums.dart';
import 'package:count_to_three/features/reminder/domain/usecases/complete_todo_usecase.dart';
import 'package:count_to_three/features/reminder/domain/usecases/create_recurring_alarm_usecase.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alarm_list_controller.g.dart';

@riverpod
Stream<AlarmEngineEvent> alarmEvents(AlarmEventsRef ref) =>
    ref.watch(alarmSchedulerProvider).events;

@riverpod
class SelectedReminderType extends _$SelectedReminderType {
  @override
  ReminderType build() => ReminderType.alarm;
  void set(ReminderType t) => state = t;
}

@riverpod
class SelectedAlertLevel extends _$SelectedAlertLevel {
  @override
  AlertLevel build() => AlertLevel.alarm;
  void set(AlertLevel a) => state = a;
}

@riverpod
class SelectedFreq extends _$SelectedFreq {
  @override
  RecurrenceFreq build() => RecurrenceFreq.none;
  void set(RecurrenceFreq freq) => state = freq;
}

@riverpod
class AlarmListController extends _$AlarmListController {
  @override
  Stream<List<Reminder>> build() {
    ref.listen(alarmEventsProvider, (_, next) {
      next.whenData((event) {
        ref.read(rescheduleWindowProvider).fillForReminder(event.reminderId);
      });
    });
    return ref.watch(appDatabaseProvider).reminderDao.watchAll();
  }

  Future<void> createReminder(
    ReminderType type,
    AlertLevel alertLevel,
    RecurrenceFreq freq, {
    String? title,
    DateTime? triggerAt,
  }) async {
    final trigger = triggerAt ?? DateTime.now().add(const Duration(seconds: 30));
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(currentUserProvider)?.uid;
    final effectiveTitle = title?.isNotEmpty == true
        ? title!
        : switch (type) {
            ReminderType.alarm => freq != RecurrenceFreq.none
                ? '重複鬧鐘（${freq.label}）'
                : '鬧鐘 ${_fmt(trigger)}',
            ReminderType.event => freq != RecurrenceFreq.none
                ? '重複事件（${freq.label}）'
                : '事件 ${_fmt(trigger)}',
            ReminderType.todo => freq != RecurrenceFreq.none
                ? '重複待辦（${freq.label}）'
                : '待辦 ${_fmt(trigger)}',
          };
    await CreateRecurringAlarmUseCase(
      reminderDao: db.reminderDao,
      recurrenceRuleDao: db.recurrenceRuleDao,
      ruleEngine: ref.read(ruleEngineProvider),
      rescheduleWindow: ref.read(rescheduleWindowProvider),
    )(
      title: effectiveTitle,
      triggerAt: trigger,
      userId: userId,
      recurrence: RecurrenceInput(freq: freq),
      alertLevel: alertLevel.value,
      type: type.value,
    );
    // Fire-and-forget outbox flush; failures keep syncStatus='pending' for retry.
    if (userId != null) ref.read(syncServiceProvider).pushPending();
  }

  String _fmt(DateTime t) =>
      '${t.month}/${t.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> deleteReminder(String reminderId) async {
    await CompleteTodoUseCase(
      reminderDao: ref.read(appDatabaseProvider).reminderDao,
      occurrenceDao: ref.read(appDatabaseProvider).occurrenceDao,
      alarmScheduler: ref.read(alarmSchedulerProvider),
      notificationScheduler: ref.read(notificationSchedulerProvider),
    )(reminderId);
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId != null) ref.read(syncServiceProvider).pushPending();
  }

  Future<void> completeTodo(String reminderId) async {
    final db = ref.read(appDatabaseProvider);
    await CompleteTodoUseCase(
      reminderDao: db.reminderDao,
      occurrenceDao: db.occurrenceDao,
      alarmScheduler: ref.read(alarmSchedulerProvider),
      notificationScheduler: ref.read(notificationSchedulerProvider),
    )(reminderId);
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId != null) ref.read(syncServiceProvider).pushPending();
  }
}
