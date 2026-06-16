import 'package:count_to_three/features/alarm_engine/domain/models/recurrence_input.dart';
import 'package:count_to_three/features/alarm_engine/domain/rule_engine.dart';
import 'package:rrule/rrule.dart';

class RruleEngineImpl implements RuleEngine {
  const RruleEngineImpl();

  // MARK: - compile

  @override
  CompiledRule? compile(RecurrenceInput input) {
    if (input.freq == RecurrenceFreq.none) return null;

    final rule = RecurrenceRule(
      frequency: _freq(input.freq),
      interval: input.interval > 1 ? input.interval : null,
      byWeekDays: _weekDays(input.byWeekday),
      until: input.until?.toUtc(),
      count: input.count,
    );

    // Strip leading "RRULE:" if the package adds it
    final raw = rule.toString();
    final rruleString = raw.startsWith('RRULE:') ? raw.substring(6) : raw;

    return (
      rruleString: rruleString,
      freq: input.freq.name.toUpperCase(),
      interval: input.interval,
    );
  }

  // MARK: - nextOccurrences

  @override
  List<DateTime> nextOccurrences(
    String rruleString, {
    required DateTime dtStart,
    required DateTime from,
    int limit = 50,
  }) {
    try {
      final clean = _strip(rruleString);
      final rule = RecurrenceRule.fromString(clean);
      return rule
          .getInstances(start: dtStart)
          .where((dt) => dt.isAfter(from))
          .take(limit)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // MARK: - occurrencesBetween

  @override
  List<DateTime> occurrencesBetween(
    String rruleString, {
    required DateTime dtStart,
    required DateTime start,
    required DateTime end,
  }) {
    try {
      final clean = _strip(rruleString);
      final rule = RecurrenceRule.fromString(clean);
      return rule
          .getInstances(start: dtStart)
          .where((dt) => !dt.isBefore(start) && !dt.isAfter(end))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // MARK: - Helpers

  String _strip(String s) => s.startsWith('RRULE:') ? s.substring(6) : s;

  Frequency _freq(RecurrenceFreq f) => switch (f) {
        RecurrenceFreq.daily => Frequency.daily,
        RecurrenceFreq.weekly => Frequency.weekly,
        RecurrenceFreq.monthly => Frequency.monthly,
        RecurrenceFreq.yearly => Frequency.yearly,
        RecurrenceFreq.none => Frequency.daily, // unreachable
      };

  List<ByWeekDayEntry> _weekDays(List<String>? days) {
    if (days == null || days.isEmpty) return const [];
    const map = {
      'MO': DateTime.monday,
      'TU': DateTime.tuesday,
      'WE': DateTime.wednesday,
      'TH': DateTime.thursday,
      'FR': DateTime.friday,
      'SA': DateTime.saturday,
      'SU': DateTime.sunday,
    };
    return days.map((d) => map[d]).whereType<int>().map(ByWeekDayEntry.new).toList();
  }
}
