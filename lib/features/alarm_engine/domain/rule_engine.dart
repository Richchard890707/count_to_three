import 'package:count_to_three/features/alarm_engine/domain/models/recurrence_input.dart';

/// Returned by [RuleEngine.compile]; carries the strings needed to persist a
/// RecurrenceRule row and the denormalised helpers.
typedef CompiledRule = ({String rruleString, String freq, int interval});

abstract interface class RuleEngine {
  /// Compile UI selection to an RRULE string + denormalised fields.
  /// Returns null when [input.freq] is [RecurrenceFreq.none].
  CompiledRule? compile(RecurrenceInput input);

  /// Expand the next [limit] occurrences strictly after [from].
  /// [dtStart] is the Reminder's startAt (recurrence anchor / DTSTART).
  ///
  /// NOTE M8: Use TZDateTime from the `timezone` package instead of plain
  /// DateTime for DST-correct expansion across timezone boundaries.
  List<DateTime> nextOccurrences(
    String rruleString, {
    required DateTime dtStart,
    required DateTime from,
    int limit = 50,
  });

  /// Expand all occurrences within [start]..[end] inclusive (calendar view).
  List<DateTime> occurrencesBetween(
    String rruleString, {
    required DateTime dtStart,
    required DateTime start,
    required DateTime end,
  });
}
