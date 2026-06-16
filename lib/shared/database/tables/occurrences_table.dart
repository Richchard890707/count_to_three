import 'package:drift/drift.dart';

// state: pending | fired | snoozed | dismissed | missed
class Occurrences extends Table {
  TextColumn get id => text()();
  TextColumn get reminderId => text()(); // FK → reminders.id
  IntColumn get scheduledAt => integer()(); // epoch ms
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  IntColumn get firedAt => integer().nullable()(); // epoch ms
  BoolColumn get osScheduled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
