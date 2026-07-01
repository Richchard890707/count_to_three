import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:count_to_three/core/constants/app_constants.dart';

import 'tables/users_table.dart';
import 'tables/reminders_table.dart';
import 'tables/recurrence_rules_table.dart';
import 'tables/alarm_configs_table.dart';
import 'tables/occurrences_table.dart';
import 'tables/workout_tables.dart';
import 'daos/alarm_config_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/occurrence_dao.dart';
import 'daos/recurrence_rule_dao.dart';
import 'daos/workout_dao.dart';

export 'tables/users_table.dart';
export 'tables/reminders_table.dart';
export 'tables/recurrence_rules_table.dart';
export 'tables/alarm_configs_table.dart';
export 'tables/occurrences_table.dart';
export 'tables/workout_tables.dart';
export 'daos/alarm_config_dao.dart';
export 'daos/recurrence_rule_dao.dart';
export 'daos/workout_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Reminders,
    RecurrenceRules,
    AlarmConfigs,
    Occurrences,
    WorkoutSessions,
    SetRecords,
  ],
  daos: [
    ReminderDao,
    OccurrenceDao,
    RecurrenceRuleDao,
    AlarmConfigDao,
    WorkoutDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(reminders, reminders.alertLevel);
      }
      if (from < 3) {
        await m.addColumn(occurrences, occurrences.syncStatus);
        await m.addColumn(occurrences, occurrences.userId);
        await m.addColumn(occurrences, occurrences.updatedAt);
        // Queue any existing completed/missed occurrences for their first cloud push.
        await customStatement(
          "UPDATE occurrences SET sync_status = 'pending', "
          "updated_at = ${DateTime.now().millisecondsSinceEpoch} "
          "WHERE state IN ('completed', 'missed')",
        );
      }
      if (from < 4) {
        await m.addColumn(alarmConfigs, alarmConfigs.preNotifyMinutes);
      }
      if (from < 5) {
        await m.addColumn(reminders, reminders.color);
      }
      if (from < 6) {
        // scenario_timer: additive only, existing tables untouched.
        await m.createTable(workoutSessions);
        await m.createTable(setRecords);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
