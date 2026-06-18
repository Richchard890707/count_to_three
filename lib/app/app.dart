import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:count_to_three/core/providers/alarm_scheduler_provider.dart';
import 'package:count_to_three/core/providers/auth_provider.dart';
import 'package:count_to_three/core/providers/connectivity_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/core/providers/sync_provider.dart';
import 'package:count_to_three/core/providers/widget_provider.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/reminder/presentation/controllers/alarm_list_controller.dart';
import 'package:flutter/material.dart';
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
    ref.listen(homeWidgetSyncProvider, (_, __) {});

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationSchedulerProvider).initialize();
      await ref.read(rescheduleWindowProvider).call();

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
            ref
                .read(appDatabaseProvider)
                .reminderDao
                .promoteLocalOnlyToPending()
                .then((_) => ref.read(syncServiceProvider).startSync(user.uid));
          } else if (prevUser != null) {
            ref.read(syncServiceProvider).stopSync();
          }
        },
      );
    });

    // Alarm fired → show full-screen ring screen
    ref.listenManual(alarmEventsProvider, (_, next) {
      next.whenData((event) {
        if (event.type == AlarmEventType.fired) {
          _router.push('/alarm/ring', extra: {
            'alarmId': event.alarmId,
            'reminderId': event.reminderId,
            'title': event.title ?? '鬧鐘',
          });
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Count to Three',
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
