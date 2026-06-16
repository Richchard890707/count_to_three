import 'dart:io';

import 'package:count_to_three/features/alarm_engine/domain/models/notification_request.dart';
import 'package:count_to_three/features/alarm_engine/domain/notification_scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationImpl implements NotificationScheduler {
  LocalNotificationImpl() : _fln = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _fln;

  static const _channelId = 'reminders';
  static const _channelName = '提醒通知';

  static const _notifDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    ),
  );

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _fln.initialize(settings);

    // Register Android notification channel for NOTIFICATION-grade reminders
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: '行事曆事件與待辦的提醒通知',
            importance: Importance.high,
          ),
        );
  }

  @override
  Future<void> scheduleNotification(NotificationRequest request) async {
    if (Platform.isIOS) {
      // TODO(M8): iOS NOTIFICATION-grade requires a unified
      // UNUserNotificationCenter delegate coordinator to avoid conflict with
      // AlarmKit fallback (M3). Deferred until Xcode testing is available.
      return;
    }
    await _fln.zonedSchedule(
      request.id,
      request.title,
      request.body,
      tz.TZDateTime.from(request.triggerAt, tz.local),
      _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelNotification(int id) => _fln.cancel(id);
}
