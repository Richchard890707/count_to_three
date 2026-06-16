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

  Future<int> updateState(String id, String state) =>
      (update(occurrences)..where((o) => o.id.equals(id))).write(
        OccurrencesCompanion(state: Value(state)),
      );

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

  Future<int> getMissedCount() =>
      (select(occurrences)..where((o) => o.state.equals('missed')))
          .get()
          .then((list) => list.length);

  /// Marks all pending occurrences scheduled before [beforeMs] as 'missed'.
  Future<void> markMissedBefore(int beforeMs) =>
      (update(occurrences)
            ..where(
              (o) =>
                  o.state.equals('pending') &
                  o.scheduledAt.isSmallerThanValue(beforeMs),
            ))
          .write(const OccurrencesCompanion(state: Value('missed')));
}
