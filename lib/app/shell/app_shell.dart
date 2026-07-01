import 'package:count_to_three/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    (
      path: '/alarms',
      icon: Icons.alarm_outlined,
      selectedIcon: Icons.alarm,
      label: '鬧鐘',
    ),
    (
      path: '/calendar',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: '行事曆',
    ),
    (
      path: '/stats',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: '統計',
    ),
  ];

  int _selectedIndex(String location) {
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(location);
    final isCalendar = selectedIndex == 1;
    final isStats = selectedIndex == 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[selectedIndex].label),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            tooltip: '組間計時器',
            onPressed: () => context.push('/timer'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '設定',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: child,
      floatingActionButton: isStats
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (isCalendar) {
                  final selectedDay = ref.read(calendarSelectedDayProvider);
                  final dateStr =
                      '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';
                  context.push('/alarm/edit?date=$dateStr');
                } else {
                  context.push('/alarm/edit');
                }
              },
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(_destinations[i].path),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
