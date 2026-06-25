import 'package:drift/drift.dart';
import 'package:count_to_three/shared/database/app_database.dart';

part 'occurrence_dao.g.dart';

@DriftAccessor(tables: [Occurrences])
class OccurrenceDao extends DatabaseAccessor<AppDatabase>
    with _$OccurrenceDaoMixin {
  OccurrenceDao(super.db);

  Stream<List<Occurrence>> watchByReminder(String reminderId) =>
      (select(occurrences)
            ..where((o) => o.reminderId.equals(reminderId))
            ..orderBy([(o) => OrderingTerm.asc(o.scheduledAt)]))
          .watch();

  Future<List<Occurrence>> findPendingBefore(DateTime deadline) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.state.equals('pending') &
                  o.scheduledAt.isSmallerThanValue(
                    deadline.millisecondsSinceEpoch,
                  ),
            ))
          .get();

  Future<void> upsert(OccurrencesCompanion companion) =>
      into(occurrences).insertOnConflictUpdate(companion);

  Future<Occurrence?> findById(String id) =>
      (select(occurrences)..where((o) => o.id.equals(id))).getSingleOrNull();

  Future<int> updateState(String id, String state) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final isTerminal = state == 'completed' || state == 'missed';
    return (update(occurrences)..where((o) => o.id.equals(id))).write(
      OccurrencesCompanion(
        state: Value(state),
        syncStatus: isTerminal ? const Value('pending') : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  /// Returns pending occurrences for [reminderId] scheduled strictly after
  /// [afterMs], ordered ascending (oldest first).
  Future<List<Occurrence>> getFuturePendingByReminder(
    String reminderId,
    int afterMs,
  ) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.reminderId.equals(reminderId) &
                  o.state.equals('pending') &
                  o.scheduledAt.isBiggerThanValue(afterMs),
            )
            ..orderBy([(o) => OrderingTerm.asc(o.scheduledAt)]))
          .get();

  Future<bool> hasAnyByReminder(String reminderId) =>
      (select(occurrences)..where((o) => o.reminderId.equals(reminderId))
            ..limit(1))
          .get()
          .then((rows) => rows.isNotEmpty);

  Future<void> deleteById(String id) =>
      (delete(occurrences)..where((o) => o.id.equals(id))).go();

  Future<void> deleteAllByReminder(String reminderId) =>
      (delete(occurrences)..where((o) => o.reminderId.equals(reminderId))).go();

  Future<void> deleteFutureByReminder(String reminderId) =>
      (delete(occurrences)
            ..where(
              (o) =>
                  o.reminderId.equals(reminderId) &
                  o.state.equals('pending') &
                  o.scheduledAt.isBiggerThanValue(DateTime.now().millisecondsSinceEpoch),
            ))
          .go();

  /// Deletes ALL pending occurrences for [reminderId] (past and future).
  /// Use this when rescheduling so stale fired-but-not-dismissed rows don't
  /// appear as the "next occurrence" in the UI.
  Future<void> deleteAllPendingByReminder(String reminderId) =>
      (delete(occurrences)
            ..where(
              (o) =>
                  o.reminderId.equals(reminderId) &
                  o.state.equals('pending'),
            ))
          .go();

  Future<int> getMissedCount() =>
      (select(occurrences)..where((o) => o.state.equals('missed')))
          .get()
          .then((list) => list.length);

  /// Returns a map of reminderId → earliest pending scheduledAt for ALL reminders.
  /// Single aggregated query: SELECT reminderId, MIN(scheduledAt) … GROUP BY reminderId.
  Future<Map<String, int>> getNextPendingScheduledAtMap() async {
    final minCol = occurrences.scheduledAt.min();
    final query = selectOnly(occurrences)
      ..addColumns([occurrences.reminderId, minCol])
      ..where(occurrences.state.equals('pending'))
      ..groupBy([occurrences.reminderId]);
    final rows = await query.get();
    final result = <String, int>{};
    for (final row in rows) {
      final rid = row.read(occurrences.reminderId);
      final ms  = row.read(minCol);
      if (rid != null && ms != null) result[rid] = ms;
    }
    return result;
  }

  /// Streams the single next pending occurrence for [reminderId], or null if none.
  Stream<Occurrence?> watchNextPending(String reminderId) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.reminderId.equals(reminderId) &
                  o.state.equals('pending'),
            )
            ..orderBy([(o) => OrderingTerm.asc(o.scheduledAt)])
            ..limit(1))
          .watchSingleOrNull();

  /// Reactive stream of all occurrences whose scheduledAt falls in [fromMs, toMs].
  Stream<List<Occurrence>> watchByRange(int fromMs, int toMs) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.scheduledAt.isBiggerOrEqualValue(fromMs) &
                  o.scheduledAt.isSmallerOrEqualValue(toMs),
            )
            ..orderBy([(o) => OrderingTerm.asc(o.scheduledAt)]))
          .watch();

  /// Returns all occurrences whose scheduledAt falls in [fromMs, toMs].
  Future<List<Occurrence>> getByRange(int fromMs, int toMs) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.scheduledAt.isBiggerOrEqualValue(fromMs) &
                  o.scheduledAt.isSmallerOrEqualValue(toMs),
            ))
          .get();

  /// Returns [limit] most-recent occurrences for [reminderId], newest first.
  Future<List<Occurrence>> getRecentByReminder(
    String reminderId, {
    int limit = 20,
  }) =>
      (select(occurrences)
            ..where((o) => o.reminderId.equals(reminderId))
            ..orderBy([(o) => OrderingTerm.desc(o.scheduledAt)])
            ..limit(limit))
          .get();

  /// Count occurrences with [state] whose scheduledAt falls in [fromMs, toMs].
  Future<int> countByStateInRange(String state, int fromMs, int toMs) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.state.equals(state) &
                  o.scheduledAt.isBiggerOrEqualValue(fromMs) &
                  o.scheduledAt.isSmallerOrEqualValue(toMs),
            ))
          .get()
          .then((l) => l.length);

  /// Returns all completed occurrences in [fromMs, toMs] — used for streak calc.
  Future<List<Occurrence>> getCompletedInRange(int fromMs, int toMs) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.state.equals('completed') &
                  o.scheduledAt.isBiggerOrEqualValue(fromMs) &
                  o.scheduledAt.isSmallerOrEqualValue(toMs),
            ))
          .get();

  /// Total count of all occurrence rows in [fromMs, toMs].
  Future<int> countInRange(int fromMs, int toMs) =>
      (select(occurrences)
            ..where(
              (o) =>
                  o.scheduledAt.isBiggerOrEqualValue(fromMs) &
                  o.scheduledAt.isSmallerOrEqualValue(toMs),
            ))
          .get()
          .then((l) => l.length);

  /// Marks all pending occurrences scheduled before [beforeMs] as 'missed'.
  Future<void> markMissedBefore(int beforeMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(occurrences)
          ..where(
            (o) =>
                o.state.equals('pending') &
                o.scheduledAt.isSmallerThanValue(beforeMs),
          ))
        .write(OccurrencesCompanion(
          state: const Value('missed'),
          syncStatus: const Value('pending'),
          updatedAt: Value(now),
        ));
  }

  // ── Cloud sync helpers ──────────────────────────────────────────────────────

  Future<List<Occurrence>> getPendingSync() =>
      (select(occurrences)..where((o) => o.syncStatus.equals('pending'))).get();

  Future<void> updateSyncStatus(String id, String status) =>
      (update(occurrences)..where((o) => o.id.equals(id)))
          .write(OccurrencesCompanion(syncStatus: Value(status)));

  Future<void> resetPendingToLocalOnly() =>
      (update(occurrences)..where((o) => o.syncStatus.equals('pending')))
          .write(const OccurrencesCompanion(syncStatus: Value('local_only')));

  Future<void> promoteLocalOnlyToPending() =>
      (update(occurrences)..where((o) => o.syncStatus.equals('local_only')))
          .write(const OccurrencesCompanion(syncStatus: Value('pending')));
}
