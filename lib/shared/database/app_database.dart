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
import 'daos/reminder_dao.dart';
import 'daos/occurrence_dao.dart';
import 'daos/recurrence_rule_dao.dart';

export 'tables/users_table.dart';
export 'tables/reminders_table.dart';
export 'tables/recurrence_rules_table.dart';
export 'tables/alarm_configs_table.dart';
export 'tables/occurrences_table.dart';
export 'daos/recurrence_rule_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Users, Reminders, RecurrenceRules, AlarmConfigs, Occurrences],
  daos: [ReminderDao, OccurrenceDao, RecurrenceRuleDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // M2 → add alert_level: ALARM | NOTIFICATION | SILENT
        await m.addColumn(reminders, reminders.alertLevel);
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
