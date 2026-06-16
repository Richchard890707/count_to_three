import 'package:count_to_three/features/alarm_engine/domain/models/notification_request.dart';

abstract interface class NotificationScheduler {
  Future<void> initialize();
  Future<void> scheduleNotification(NotificationRequest request);
  Future<void> cancelNotification(int id);
}
