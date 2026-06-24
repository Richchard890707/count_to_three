import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:count_to_three/features/alarm_engine/domain/models/notification_request.dart';
import 'package:count_to_three/features/alarm_engine/domain/notification_scheduler.dart';
import 'package:count_to_three/core/constants/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationImpl implements NotificationScheduler {
  LocalNotificationImpl()
      : _fln = FlutterLocalNotificationsPlugin(),
        _iosChannel = const MethodChannel(AppConstants.alarmMethodChannel);

  final FlutterLocalNotificationsPlugin _fln;
  final MethodChannel _iosChannel;
  final _tapController = StreamController<NotificationTapEvent>.broadcast();

  static const _channelId = 'reminders';
  static const _channelName = '提醒通知';

  static const _notifDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          'complete',
          '✓ 完成',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze',
          '延後 5 分',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    ),
  );

  @override
  Stream<NotificationTapEvent> get tapEvents =>
      Platform.isIOS ? const Stream.empty() : _tapController.stream;

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
    await _fln.initialize(
      settings,
      onDidReceiveNotificationResponse: Platform.isAndroid ? _onNotifTap : null,
    );

    if (Platform.isAndroid) {
      final android = _fln.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      // POST_NOTIFICATIONS permission — required on Android 13+ (API 33+).
      await android?.requestNotificationsPermission();
      // Register notification channel for NOTIFICATION-grade reminders.
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: '行事曆事件與待辦的提醒通知',
          importance: Importance.high,
        ),
      );
    }
  }

  void _onNotifTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final reminderId = map['reminderId'] as String;
      final scheduledAtMs = (map['scheduledAtMs'] as num).toInt();
      _tapController.add(NotificationTapEvent(
        reminderId: reminderId,
        scheduledAtMs: scheduledAtMs,
        isSnooze: response.actionId == 'snooze',
      ));
    } catch (_) {}
  }

  @override
  Future<void> scheduleNotification(NotificationRequest request) async {
    if (Platform.isIOS) {
      await _iosChannel.invokeMethod('scheduleNotification', {
        'id': request.id,
        'reminderId': request.reminderId,
        'title': request.title,
        'body': request.body,
        'triggerAtMs': request.triggerAt.millisecondsSinceEpoch,
      });
      return;
    }
    await _fln.zonedSchedule(
      request.id,
      request.title,
      request.body,
      tz.TZDateTime.from(request.triggerAt, tz.local),
      _notifDetails,
      payload: jsonEncode({
        'reminderId': request.reminderId,
        'scheduledAtMs': request.triggerAt.millisecondsSinceEpoch,
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    if (Platform.isIOS) {
      await _iosChannel.invokeMethod('cancelNotification', id);
      return;
    }
    await _fln.cancel(id);
  }
}
