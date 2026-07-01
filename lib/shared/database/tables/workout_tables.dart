import 'package:drift/drift.dart';

/// One workout rest-rhythm session. profile reserved for future scenarios
/// (workout / spine / custom …) so multi-scenario needs no schema change.
@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  IntColumn get startedAt => integer()(); // epoch ms
  IntColumn get endedAt => integer().nullable()();
  IntColumn get targetSets => integer()();
  IntColumn get softTargetMs => integer()();
  TextColumn get profile => text().withDefault(const Constant('workout'))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The rest that followed completing [setIndex] (1-based). The two tap
/// timestamps (restStartMs = "做完這組", restEndMs = "我好了") are the dogfood
/// data; cueConfigJson snapshots the soft/spine thresholds used at the time.
@DataClassName('SetRecordRow')
class SetRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()(); // FK → workout_sessions.id
  IntColumn get setIndex => integer()();
  IntColumn get restStartMs => integer()();
  IntColumn get restEndMs => integer()();
  IntColumn get restDurationMs => integer()(); // measured, not end-start math
  TextColumn get cueConfigJson => text()(); // e.g. "[90000,135000]"
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
