import 'package:drift/drift.dart';

// type      : alarm | timer | event | todo | shift
// alertLevel: ALARM | NOTIFICATION | SILENT
// syncStatus: synced | pending | conflict
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()(); // FK → users.id (auth: M7)
  TextColumn get type => text()();
  TextColumn get title => text().withLength(max: 200)();
  TextColumn get note => text().nullable()();
  IntColumn get startAt => integer()(); // epoch ms, local-time anchor
  TextColumn get timezone =>
      text().withDefault(const Constant('Asia/Taipei'))();
  TextColumn get recurrenceRuleId => text().nullable()(); // FK → recurrence_rules.id
  // ALARM: native AlarmScheduler, full-screen, bypasses DND
  // NOTIFICATION: flutter_local_notifications heads-up (M5)
  // SILENT: calendar mark only, no notification
  TextColumn get alertLevel =>
      text().withDefault(const Constant('NOTIFICATION'))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
