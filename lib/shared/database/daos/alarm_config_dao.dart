import 'package:drift/drift.dart';
import 'package:count_to_three/shared/database/app_database.dart';

part 'alarm_config_dao.g.dart';

@DriftAccessor(tables: [AlarmConfigs])
class AlarmConfigDao extends DatabaseAccessor<AppDatabase>
    with _$AlarmConfigDaoMixin {
  AlarmConfigDao(super.db);

  Future<AlarmConfig?> findByReminder(String reminderId) =>
      (select(alarmConfigs)
            ..where((c) => c.reminderId.equals(reminderId)))
          .getSingleOrNull();

  Future<void> upsert(AlarmConfigsCompanion companion) =>
      into(alarmConfigs).insertOnConflictUpdate(companion);

  Future<void> deleteByReminder(String reminderId) =>
      (delete(alarmConfigs)..where((c) => c.reminderId.equals(reminderId))).go();
}
