import 'package:count_to_three/features/alarm_engine/data/alarm_channel_impl.dart';
import 'package:count_to_three/features/alarm_engine/domain/alarm_scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alarm_scheduler_provider.g.dart';

@Riverpod(keepAlive: true)
AlarmScheduler alarmScheduler(AlarmSchedulerRef ref) => AlarmChannelImpl();
