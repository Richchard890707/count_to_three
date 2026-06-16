import 'package:count_to_three/core/constants/app_constants.dart';
import 'package:count_to_three/features/alarm_engine/domain/alarm_scheduler.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_request.dart';
import 'package:flutter/services.dart';

class AlarmChannelImpl implements AlarmScheduler {
  AlarmChannelImpl()
      : _method = const MethodChannel(AppConstants.alarmMethodChannel),
        _event = const EventChannel(AppConstants.alarmEventChannel);

  final MethodChannel _method;
  final EventChannel _event;

  @override
  Future<void> scheduleAlarm(AlarmRequest request) =>
      _method.invokeMethod('scheduleAlarm', request.toMap());

  @override
  Future<void> cancelAlarm(int alarmId) =>
      _method.invokeMethod('cancelAlarm', alarmId);

  @override
  Stream<AlarmEngineEvent> get events => _event
      .receiveBroadcastStream()
      .cast<Map<dynamic, dynamic>>()
      .map(AlarmEngineEvent.fromMap);
}
