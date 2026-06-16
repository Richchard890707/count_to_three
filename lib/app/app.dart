import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:count_to_three/core/providers/auth_provider.dart';
import 'package:count_to_three/core/providers/connectivity_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/core/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:count_to_three/app/router.dart';
import 'package:count_to_three/app/theme/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

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
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
