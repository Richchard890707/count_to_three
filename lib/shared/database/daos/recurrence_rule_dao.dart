import 'package:drift/drift.dart';
import 'package:count_to_three/shared/database/app_database.dart';

part 'recurrence_rule_dao.g.dart';

@DriftAccessor(tables: [RecurrenceRules])
class RecurrenceRuleDao extends DatabaseAccessor<AppDatabase>
    with _$RecurrenceRuleDaoMixin {
  RecurrenceRuleDao(super.db);

  Future<void> upsert(RecurrenceRulesCompanion companion) =>
      into(recurrenceRules).insertOnConflictUpdate(companion);

  Future<RecurrenceRule?> findById(String id) =>
      (select(recurrenceRules)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<void> deleteById(String id) =>
      (delete(recurrenceRules)..where((r) => r.id.equals(id))).go();
}