import 'package:go_router/go_router.dart';
import 'package:count_to_three/app/shell/app_shell.dart';
import 'package:count_to_three/features/reminder/presentation/screens/alarm_list_screen.dart';
import 'package:count_to_three/features/reminder/presentation/screens/alarm_edit_screen.dart';
import 'package:count_to_three/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:count_to_three/features/auth/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/alarms',
  routes: [
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
      ],
    ),
    GoRoute(
      path: '/alarm/edit',
      builder: (context, state) {
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
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
