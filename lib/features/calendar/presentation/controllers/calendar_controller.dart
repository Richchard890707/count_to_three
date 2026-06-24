import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/rule_engine_provider.dart';
import 'package:count_to_three/features/calendar/domain/models/calendar_event.dart';
import 'package:count_to_three/features/calendar/domain/usecases/get_events_for_range_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_controller.g.dart';

enum CalViewMode { month, week, day }

@riverpod
class CalendarFocusedDay extends _$CalendarFocusedDay {
  @override
  DateTime build() => _today();
  void set(DateTime d) => state = d;
}

@riverpod
class CalendarSelectedDay extends _$CalendarSelectedDay {
  @override
  DateTime build() => _today();
  void set(DateTime d) => state = d;
}

@riverpod
class CalendarViewMode extends _$CalendarViewMode {
  @override
  CalViewMode build() => CalViewMode.month;
  void set(CalViewMode m) => state = m;
}

@riverpod
Future<Map<DateTime, List<CalendarEvent>>> calendarController(
  CalendarControllerRef ref,
) async {
  final focused = ref.watch(calendarFocusedDayProvider);
  final mode = ref.watch(calendarViewModeProvider);
  final range = _visibleRange(focused, mode);
  final db = ref.watch(appDatabaseProvider);

  return GetEventsForRangeUseCase(
    reminderDao: db.reminderDao,
    recurrenceRuleDao: db.recurrenceRuleDao,
    occurrenceDao: db.occurrenceDao,
    ruleEngine: ref.watch(ruleEngineProvider),
  ).call(range.$1, range.$2);
}

(DateTime, DateTime) _visibleRange(DateTime focused, CalViewMode mode) =>
    switch (mode) {
      // Month: include overflow days from adjacent months visible in the grid
      CalViewMode.month => (
          DateTime(focused.year, focused.month, 1)
              .subtract(const Duration(days: 7)),
          DateTime(focused.year, focused.month + 1, 0)
              .add(const Duration(days: 7)),
        ),
      // Week: include ±1 week so swiping feels instant
      CalViewMode.week => (
          focused.subtract(const Duration(days: 7)),
          focused.add(const Duration(days: 7)),
        ),
      CalViewMode.day => (
          DateTime(focused.year, focused.month, focused.day),
          DateTime(focused.year, focused.month, focused.day, 23, 59, 59),
        ),
    };

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
