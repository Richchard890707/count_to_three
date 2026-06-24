import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:count_to_three/core/providers/auth_provider.dart';
import 'package:count_to_three/core/providers/connectivity_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/core/providers/sync_provider.dart';
import 'package:count_to_three/core/providers/theme_provider.dart';
import 'package:count_to_three/core/providers/widget_provider.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/notification_request.dart';
import 'package:count_to_three/features/reminder/presentation/controllers/alarm_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:count_to_three/app/router.dart' as router_module;
import 'package:count_to_three/app/theme/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key, required this.onboarded});
  final bool onboarded;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = router_module.buildRouter(widget.onboarded);

    // Keep home widget data fresh
    ref.listenManual(homeWidgetSyncProvider, (_, _) {});

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationSchedulerProvider).initialize();
      await ref.read(rescheduleWindowProvider).call();
      _refreshBadge();

      if (!mounted) return;
      final missedCount = await ref
          .read(appDatabaseProvider)
          .occurrenceDao
          .getMissedCount();
      if (missedCount > 0 && mounted) {
        _messengerKey.currentState?.showMaterialBanner(
          MaterialBanner(
            content: Text('$missedCount 個提醒在裝置關機期間漏響'),
            leading: const Icon(Icons.alarm_off_outlined),
            actions: [
              TextButton(
                onPressed: () =>
                    _messengerKey.currentState?.clearMaterialBanners(),
                child: const Text('知道了'),
              ),
            ],
          ),
        );
      }
    });

    // Auth state listener: handles both initial session restore and sign-in/out.
    ref.listenManual(authStateProvider, (prev, next) {
      final prevUser = prev?.valueOrNull;
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            final db = ref.read(appDatabaseProvider);
            Future.wait([
              db.reminderDao.promoteLocalOnlyToPending(),
              db.occurrenceDao.promoteLocalOnlyToPending(),
            ]).then((_) => ref.read(syncServiceProvider).startSync(user.uid));
          } else if (prevUser != null) {
            ref.read(syncServiceProvider).stopSync();
          }
        },
      );
    });

    // Alarm + notification events: always-alive listener at the app root.
    ref.listenManual(alarmEventsProvider, (_, next) {
      next.whenData((event) {
        if (event.type == AlarmEventType.fired) {
          _router.push('/alarm/ring', extra: {
            'alarmId': event.alarmId,
            'reminderId': event.reminderId,
            'title': event.title ?? '鬧鐘',
            'snoozeCount': event.snoozeCount ?? 0,
            'maxSnoozeCount': event.maxSnoozeCount ?? 3,
          });
        }
        // iOS NOTIFICATION-level tap: mark completed and show feedback.
        if (event.type == AlarmEventType.notifTapped) {
          final scheduledAtMs = event.scheduledAtMs;
          if (scheduledAtMs != null) {
            _markOccurrenceCompleted(event.reminderId, scheduledAtMs);
          }
          return; // no window refill for simple notifications
        }
        // Refill scheduling window after any alarm event.
        ref.read(rescheduleWindowProvider).fillForReminder(event.reminderId);
        // Mark the occurrence completed when the user acknowledges or snoozes.
        final scheduledAtMs = event.scheduledAtMs;
        if (scheduledAtMs != null &&
            (event.type == AlarmEventType.snoozed ||
                event.type == AlarmEventType.dismissed)) {
          _markOccurrenceCompleted(event.reminderId, scheduledAtMs);
        }
      });
    });

    // Android NOTIFICATION-level tap / quick-complete / snooze action.
    ref.listenManual(notificationTapEventsProvider, (_, next) {
      next.whenData((tap) {
        if (tap.isSnooze) {
          _snoozeNotification(tap.reminderId, tap.scheduledAtMs);
        } else {
          _markOccurrenceCompleted(tap.reminderId, tap.scheduledAtMs);
          ref.read(rescheduleWindowProvider).fillForReminder(tap.reminderId);
        }
      });
    });

    // Connectivity listener: push pending records when network is restored.
    ref.listenManual(connectivityProvider, (prev, next) {
      next.whenData((results) {
        final hasNet = results.any((r) => r != ConnectivityResult.none);
        if (!hasNet) return;
        final user = ref.read(currentUserProvider);
        if (user != null) {
          ref.read(syncServiceProvider).pushPending();
        }
      });
    });
  }

  void _snoozeNotification(String reminderId, int scheduledAtMs) {
    final scheduler = ref.read(notificationSchedulerProvider);
    final db = ref.read(appDatabaseProvider);
    db.reminderDao.findById(reminderId).then((reminder) {
      if (reminder == null) return;
      final snoozeAt = DateTime.now().add(const Duration(minutes: 5));
      // Re-use notification id based on original scheduled time.
      final notifId = (scheduledAtMs ~/ 1000 % 1000000) + 2000000;
      scheduler.scheduleNotification(NotificationRequest(
        id: notifId,
        reminderId: reminderId,
        title: reminder.title,
        body: '延後提醒',
        triggerAt: snoozeAt,
      ));
    });
    _messengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('已延後 5 分鐘'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markOccurrenceCompleted(String reminderId, int scheduledAtMs) {
    ref
        .read(appDatabaseProvider)
        .occurrenceDao
        .updateState('${reminderId}_$scheduledAtMs', 'completed');
    _messengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('已記錄完成'),
        duration: Duration(seconds: 2),
      ),
    );
    _refreshBadge();
  }

  static const _alarmChannel = MethodChannel('app.ontime/alarm');

  Future<void> _refreshBadge() async {
    if (!Platform.isIOS) return;
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day)
          .millisecondsSinceEpoch;
      final tomorrowStart = todayStart + 86400000;
      final count = await ref
          .read(appDatabaseProvider)
          .occurrenceDao
          .countByStateInRange('pending', todayStart, tomorrowStart);
      await _alarmChannel.invokeMethod('badge.setCount', count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Count to Three',
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
