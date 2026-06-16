import 'package:count_to_three/shared/database/app_database.dart';

/// A flattened (reminder, occurrence-time) pair for calendar rendering.
/// One-time reminders produce a single CalendarEvent; recurring reminders
/// produce one per expanded occurrence in the visible range.
class CalendarEvent {
  const CalendarEvent({required this.reminder, required this.occurrenceTime});

  final Reminder reminder;
  final DateTime occurrenceTime;
}
