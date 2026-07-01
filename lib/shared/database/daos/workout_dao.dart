import 'package:drift/drift.dart';
import 'package:count_to_three/shared/database/app_database.dart';

part 'workout_dao.g.dart';

@DriftAccessor(tables: [WorkoutSessions, SetRecords])
class WorkoutDao extends DatabaseAccessor<AppDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(super.db);

  Future<void> insertSession(WorkoutSessionsCompanion session) =>
      into(workoutSessions).insert(session);

  Future<void> finishSession(String sessionId, int endedAtMs) =>
      (update(workoutSessions)..where((s) => s.id.equals(sessionId)))
          .write(WorkoutSessionsCompanion(endedAt: Value(endedAtMs)));

  /// Close any session left open (endedAt IS NULL) — abandoned sessions that
  /// were never finished, so history isn't polluted with perpetually-open rows.
  Future<void> closeOpenSessions(int endedAtMs) =>
      (update(workoutSessions)..where((s) => s.endedAt.isNull()))
          .write(WorkoutSessionsCompanion(endedAt: Value(endedAtMs)));

  /// Persist one completed rest (the two taps + measured duration = dogfood data).
  Future<void> insertSetRecord(SetRecordsCompanion record) =>
      into(setRecords).insert(record);

  Future<List<SetRecordRow>> recordsForSession(String sessionId) =>
      (select(setRecords)
            ..where((r) => r.sessionId.equals(sessionId))
            ..orderBy([(r) => OrderingTerm.asc(r.setIndex)]))
          .get();

  Stream<List<WorkoutSessionRow>> watchSessions() =>
      (select(workoutSessions)
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
          .watch();
}
