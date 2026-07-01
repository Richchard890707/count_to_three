import 'package:count_to_three/features/scenario_timer/domain/models/workout_session.dart';

/// Which rest cue fired (soft target vs the firmer "spine" reminder).
enum RestCue { soft, spine }

/// Foreground state machine for the workout rest-rhythm timer (Model C).
///
/// Driven by ONE full-screen button; the label changes per state. Rest is
/// counted UP (elapsed comes from a monotonic Stopwatch in the controller,
/// never stored here). See SPEC.md / ADR-001.
sealed class WorkoutTimerState {
  const WorkoutTimerState();

  /// Label for the single full-screen button in this state.
  String get buttonLabel;
}

/// Configuring target sets + soft rest target, before the session starts.
class TimerSetup extends WorkoutTimerState {
  const TimerSetup({
    this.targetSets = 5,
    this.softTarget = const Duration(seconds: 90),
  });

  final int targetSets;
  final Duration softTarget;

  @override
  String get buttonLabel => '開始';

  TimerSetup copyWith({int? targetSets, Duration? softTarget}) => TimerSetup(
        targetSets: targetSets ?? this.targetSets,
        softTarget: softTarget ?? this.softTarget,
      );
}

/// Performing [currentSet] (untimed); waiting for the user to tap "做完這組".
class TimerWorking extends WorkoutTimerState {
  const TimerWorking({required this.session, required this.currentSet});

  final WorkoutSession session;

  /// 1-based index of the set being performed right now.
  final int currentSet;

  @override
  String get buttonLabel => '做完這組';
}

/// Rest is counting up after finishing [setJustDone]; waiting for "我好了".
class TimerResting extends WorkoutTimerState {
  const TimerResting({
    required this.session,
    required this.setJustDone,
    required this.restStartedAt,
    this.firedCues = const {},
  });

  final WorkoutSession session;

  /// The set we just completed; this rest precedes set [setJustDone] + 1.
  final int setJustDone;

  /// Wall-clock anchor for DB persistence only — elapsed comes from the
  /// controller's Stopwatch, not from `now - restStartedAt`.
  final DateTime restStartedAt;

  final Set<RestCue> firedCues;

  @override
  String get buttonLabel => '我好了';

  TimerResting copyWith({Set<RestCue>? firedCues}) => TimerResting(
        session: session,
        setJustDone: setJustDone,
        restStartedAt: restStartedAt,
        firedCues: firedCues ?? this.firedCues,
      );
}

/// All target sets done; showing per-set rest summary.
class TimerSummary extends WorkoutTimerState {
  const TimerSummary({required this.session});

  final WorkoutSession session;

  @override
  String get buttonLabel => '完成';
}
