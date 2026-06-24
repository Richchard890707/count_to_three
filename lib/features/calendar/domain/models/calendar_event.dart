import 'package:count_to_three/shared/database/app_database.dart';

/// A flattened (reminder, occurrence-time) pair for calendar rendering.
/// One-time reminders produce a single CalendarEvent; recurring reminders
/// produce one per expanded occurrence in the visible range.
/// Occurrence state values: 'pending' | 'completed' | 'missed' | null (no DB row).
class CalendarEvent {
  const CalendarEvent({
    required this.reminder,
    required this.occurrenceTime,
    this.occurrenceState,
  });

  final Reminder reminder;
  final DateTime occurrenceTime;

  /// null → no occurrence row in DB yet (future, not yet scheduled to OS).
  final String? occurrenceState;

  bool get isPast => occurrenceTime.isBefore(DateTime.now());
  bool get isCompleted => occurrenceState == 'completed';
  bool get isMissed => occurrenceState == 'missed';
}
