import 'package:count_to_three/features/alarm_engine/data/local_notification_impl.dart';
import 'package:count_to_three/features/alarm_engine/domain/notification_scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_scheduler_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(NotificationSchedulerRef ref) =>
    LocalNotificationImpl();

@Riverpod(keepAlive: true)
Stream<NotificationTapEvent> notificationTapEvents(NotificationTapEventsRef ref) =>
    ref.watch(notificationSchedulerProvider).tapEvents;
