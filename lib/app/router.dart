import 'package:go_router/go_router.dart';
import 'package:count_to_three/app/shell/app_shell.dart';
import 'package:count_to_three/features/reminder/presentation/screens/alarm_list_screen.dart';
import 'package:count_to_three/features/reminder/presentation/screens/alarm_edit_screen.dart';
import 'package:count_to_three/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:count_to_three/features/stats/presentation/screens/stats_screen.dart';
import 'package:count_to_three/features/auth/presentation/screens/settings_screen.dart';
import 'package:count_to_three/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:count_to_three/features/alarm_engine/presentation/screens/alarm_ring_screen.dart';
import 'package:count_to_three/features/scenario_timer/presentation/screens/scenario_picker_screen.dart';
import 'package:count_to_three/shared/database/app_database.dart';

GoRouter buildRouter(bool onboarded) => GoRouter(
  initialLocation: onboarded ? '/alarms' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/timer',
      builder: (context, state) => const ScenarioPickerScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/alarms',
          builder: (context, state) => const AlarmListScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/alarm/edit',
      builder: (context, state) {
        // extra can be a Reminder (edit mode) or null (create mode)
        final reminder = state.extra is Reminder ? state.extra as Reminder : null;
        if (reminder != null) return AlarmEditScreen(reminder: reminder);

        final dateStr = state.uri.queryParameters['date'];
        DateTime? initialDate;
        if (dateStr != null) {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            initialDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        }
        return AlarmEditScreen(initialDate: initialDate);
      },
    ),
    GoRoute(
      path: '/alarm/ring',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AlarmRingScreen(
          alarmId: extra?['alarmId'] as int? ?? 0,
          reminderId: extra?['reminderId'] as String? ?? '',
          title: extra?['title'] as String? ?? '鬧鐘',
          snoozeCount: extra?['snoozeCount'] as int? ?? 0,
          maxSnoozeCount: extra?['maxSnoozeCount'] as int? ?? 3,
          scheduledAtMs: extra?['scheduledAtMs'] as int?,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

// Keep backward-compatible export for any code that references appRouter directly
final appRouter = buildRouter(true);
