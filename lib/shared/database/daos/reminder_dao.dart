import 'package:drift/drift.dart';
import 'package:count_to_three/shared/database/app_database.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Stream<List<Reminder>> watchAll() =>
      (select(reminders)
            ..where((r) => r.isDeleted.equals(false))
            ..orderBy([(r) => OrderingTerm.asc(r.startAt)]))
          .watch();

  Stream<List<Reminder>> watchFiltered({
    String query = '',
    Set<String> types = const {},
    bool onlyEnabled = false,
    String sortColumn = 'startAt',
    bool sortDesc = false,
  }) {
    final mode = sortDesc ? OrderingMode.desc : OrderingMode.asc;
    return (select(reminders)
          ..where((r) {
            var expr = r.isDeleted.equals(false);
            if (query.isNotEmpty) {
              final likeQ = '%$query%';
              expr = expr & (r.title.like(likeQ) | r.note.like(likeQ));
            }
            if (types.isNotEmpty) {
              expr = expr & r.type.isIn(types.toList());
            }
            if (onlyEnabled) {
              expr = expr & r.isEnabled.equals(true);
            }
            return expr;
          })
          ..orderBy([(r) {
                Expression sortExpr = r.startAt;
                if (sortColumn == 'title') sortExpr = r.title;
                if (sortColumn == 'type') sortExpr = r.type;
                if (sortColumn == 'createdAt') sortExpr = r.createdAt;
                return OrderingTerm(expression: sortExpr, mode: mode);
              }]))
        .watch();
  }

  Future<List<Reminder>> getAll() =>
      (select(reminders)..where((r) => r.isDeleted.equals(false))).get();

  Future<void> upsert(RemindersCompanion companion) =>
      into(reminders).insertOnConflictUpdate(companion);

  Future<Reminder?> findById(String id) =>
      (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();

  /// Soft-delete with sync fields: marks as deleted, bumps version, sets PENDING.
  Future<void> softDeleteWithSync(String id) async {
    final record = await findById(id);
    await (update(reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
        version: Value((record?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> setEnabled(String id, bool enabled) =>
      (update(reminders)..where((r) => r.id.equals(id))).write(
        RemindersCompanion(
          isEnabled: Value(enabled),
          syncStatus: const Value('pending'),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// All records with syncStatus='pending', including soft-deleted ones.
  Future<List<Reminder>> getPendingSync() =>
      (select(reminders)..where((r) => r.syncStatus.equals('pending'))).get();

  Future<void> updateSyncStatus(String id, String status) =>
      (update(reminders)..where((r) => r.id.equals(id)))
          .write(RemindersCompanion(syncStatus: Value(status)));

  /// On sign-out: preserve data but stop it from being pushed without a user.
  Future<void> resetPendingToLocalOnly() =>
      (update(reminders)..where((r) => r.syncStatus.equals('pending')))
          .write(const RemindersCompanion(syncStatus: Value('local_only')));

  /// On sign-in: re-queue offline edits so the outbox flush picks them up.
  Future<void> promoteLocalOnlyToPending() =>
      (update(reminders)..where((r) => r.syncStatus.equals('local_only')))
          .write(const RemindersCompanion(syncStatus: Value('pending')));
}
