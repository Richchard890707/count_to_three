import 'package:count_to_three/features/scenario_timer/domain/models/rest_record.dart';

/// Configuration + immutable live state for one workout rest-rhythm session.
///
/// LOCKED v1 scope: single scenario (workout), rest-only timing, no cloud,
/// no voice, no multi-scenario. See SPEC.md in this feature folder.
class WorkoutSession {
  const WorkoutSession({
    required this.targetSets,
    required this.softTarget,
    this.restRecords = const [],
    this.setsCompleted = 0,
  });

  /// How many sets the user committed to before starting.
  final int targetSets;

  /// Soft rest goal; a gentle nudge fires once rest passes this.
  final Duration softTarget;

  /// Per-set actual rest, accumulated as the session runs.
  final List<RestRecord> restRecords;

  /// Sets finished so far (incremented on each "做完這組" tap).
  final int setsCompleted;

  /// Firmer "spine" nudge threshold — soft target + 50%. Never forces a stop.
  Duration get spineThreshold => softTarget * 1.5;

  /// All committed sets are done → go to summary.
  bool get isDone => setsCompleted >= targetSets;

  /// Total real rest across the session.
  Duration get totalRest =>
      restRecords.fold(Duration.zero, (sum, r) => sum + r.actualRest);

  WorkoutSession copyWith({
    List<RestRecord>? restRecords,
    int? setsCompleted,
  }) {
    return WorkoutSession(
      targetSets: targetSets,
      softTarget: softTarget,
      restRecords: restRecords ?? this.restRecords,
      setsCompleted: setsCompleted ?? this.setsCompleted,
    );
  }
}
