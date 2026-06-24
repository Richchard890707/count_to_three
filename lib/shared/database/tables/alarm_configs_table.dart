import 'package:drift/drift.dart';

class AlarmConfigs extends Table {
  TextColumn get reminderId => text()(); // PK + FK → reminders.id
  TextColumn get ringtoneUri => text().nullable()();
  BoolColumn get vibrate => boolean().withDefault(const Constant(true))();
  BoolColumn get volumeRamp => boolean().withDefault(const Constant(false))();
  IntColumn get snoozeMinutes => integer().withDefault(const Constant(5))();
  IntColumn get snoozeMaxCount => integer().withDefault(const Constant(3))();
  IntColumn get preNotifyMinutes => integer().nullable()();
  TextColumn get shiftPatternJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {reminderId};
}
