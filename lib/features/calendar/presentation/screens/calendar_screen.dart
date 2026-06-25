import 'package:count_to_three/features/calendar/domain/models/calendar_event.dart';
import 'package:count_to_three/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:count_to_three/features/calendar/presentation/widgets/day_event_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(calendarViewModeProvider);
    final focusedDay = ref.watch(calendarFocusedDayProvider);
    final selectedDay = ref.watch(calendarSelectedDayProvider);
    // valueOrNull keeps showing previous data while reloading (no flicker)
    final eventsMap =
        ref.watch(calendarControllerProvider).valueOrNull ?? const {};

    List<CalendarEvent> eventLoader(DateTime day) {
      final key = DateTime.utc(day.year, day.month, day.day);
      return eventsMap[key] ?? const [];
    }

    return Column(
      children: [
        // ── View mode switcher ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<CalViewMode>(
            segments: const [
              ButtonSegment(value: CalViewMode.month, label: Text('月')),
              ButtonSegment(value: CalViewMode.week, label: Text('週')),
              ButtonSegment(value: CalViewMode.day, label: Text('日')),
            ],
            selected: {viewMode},
            onSelectionChanged: (s) =>
                ref.read(calendarViewModeProvider.notifier).set(s.first),
          ),
        ),

        // ── Calendar grid (month / week) ───────────────────────────
        if (viewMode != CalViewMode.day)
          TableCalendar<CalendarEvent>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, selectedDay),
            calendarFormat: viewMode == CalViewMode.month
                ? CalendarFormat.month
                : CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: eventLoader,
            onDaySelected: (selected, focused) {
              ref.read(calendarSelectedDayProvider.notifier).set(selected);
              ref.read(calendarFocusedDayProvider.notifier).set(focused);
            },
            onPageChanged: (focused) {
              ref.read(calendarFocusedDayProvider.notifier).set(focused);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) =>
                  events.isEmpty ? null : _EventDots(events: events),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(51),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        const Divider(height: 1),

        // ── Selected-day event list ────────────────────────────────
        Expanded(
          child: DayEventList(
            day: selectedDay,
            events: eventLoader(selectedDay),
          ),
        ),
      ],
    );
  }
}

// ── Event dots rendered below calendar cells ──────────────────────────────────

class _EventDots extends StatelessWidget {
  const _EventDots({required this.events});
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(3).map((e) => _dot(e)).toList(),
      ),
    );
  }

  Widget _dot(CalendarEvent e) {
    final Color color;
    if (e.isCompleted) {
      color = Colors.green;
    } else if (e.isMissed) {
      color = Colors.orange;
    } else if (e.reminder.color != null) {
      color = Color(int.parse('FF${e.reminder.color!.substring(1)}', radix: 16));
    } else {
      color = switch (e.reminder.alertLevel) {
        'ALARM' => Colors.red,
        'NOTIFICATION' => Colors.blue,
        _ => Colors.grey,
      };
    }
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
