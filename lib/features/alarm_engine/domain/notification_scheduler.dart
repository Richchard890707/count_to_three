import 'package:count_to_three/features/alarm_engine/domain/models/notification_request.dart';

class NotificationTapEvent {
  const NotificationTapEvent({
    required this.reminderId,
    required this.scheduledAtMs,
    this.isSnooze = false,
  });
  final String reminderId;
  final int scheduledAtMs;
  final bool isSnooze;
}

abstract interface class NotificationScheduler {
  Future<void> initialize();
  Future<void> scheduleNotification(NotificationRequest request);
  Future<void> cancelNotification(int id);
  Stream<NotificationTapEvent> get tapEvents;
}
