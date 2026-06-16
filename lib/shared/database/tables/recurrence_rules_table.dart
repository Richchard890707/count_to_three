import 'package:drift/drift.dart';

// rruleString is the authoritative RFC 5545 RRULE string.
// Other columns are parsed helpers for efficient queries.
class RecurrenceRules extends Table {
  TextColumn get id => text()();
  TextColumn get rruleString => text()(); // e.g. "FREQ=WEEKLY;BYDAY=MO,WE,FR"
  TextColumn get freq =>
      text().withDefault(const Constant('NONE'))(); // NONE|DAILY|WEEKLY|MONTHLY|YEARLY
  IntColumn get interval => integer().withDefault(const Constant(1))();
  TextColumn get byWeekday => text().nullable()(); // "MO,TU,WE"
  TextColumn get byMonthday => text().nullable()(); // "1,15,-1"
  TextColumn get byMonth => text().nullable()(); // "1,3,12"
  TextColumn get timesOfDay => text().nullable()(); // "08:00,12:00,18:00"
  IntColumn get count => integer().nullable()();
  IntColumn get until => integer().nullable()(); // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}
