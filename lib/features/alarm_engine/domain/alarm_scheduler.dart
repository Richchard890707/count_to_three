import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_request.dart';

abstract interface class AlarmScheduler {
  Future<void> scheduleAlarm(AlarmRequest request);
  Future<void> cancelAlarm(int alarmId);
  Stream<AlarmEngineEvent> get events;
}
