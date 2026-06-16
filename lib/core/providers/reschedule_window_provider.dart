import 'package:count_to_three/core/providers/alarm_scheduler_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:count_to_three/core/providers/rule_engine_provider.dart';
import 'package:count_to_three/features/reminder/domain/usecases/reschedule_window_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reschedule_window_provider.g.dart';

@Riverpod(keepAlive: true)
RescheduleWindowUseCase rescheduleWindow(RescheduleWindowRef ref) =>
    RescheduleWindowUseCase(
      reminderDao: ref.watch(appDatabaseProvider).reminderDao,
      occurrenceDao: ref.watch(appDatabaseProvider).occurrenceDao,
      recurrenceRuleDao: ref.watch(appDatabaseProvider).recurrenceRuleDao,
      scheduler: ref.watch(alarmSchedulerProvider),
      ruleEngine: ref.watch(ruleEngineProvider),
      notificationScheduler: ref.watch(notificationSchedulerProvider),
    );
