import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/features/scenario_timer/data/audio_cue_player.dart';
import 'package:count_to_three/features/scenario_timer/data/rest_cue_scheduler.dart';
import 'package:count_to_three/features/scenario_timer/data/session_persistence.dart';
import 'package:count_to_three/features/scenario_timer/domain/models/rest_record.dart';
import 'package:count_to_three/features/scenario_timer/domain/models/workout_session.dart';
import 'package:count_to_three/features/scenario_timer/domain/models/workout_timer_state.dart';

// ── feature-scoped providers ──────────────────────────────────────────────

final audioCuePlayerProvider = Provider<AudioCuePlayer>((ref) {
  final player = AudioCuePlayer();
  ref.onDispose(player.dispose);
  return player;
});

final restCueSchedulerProvider = Provider<RestCueScheduler>((ref) {
  return RestCueScheduler(ref.watch(notificationSchedulerProvider));
});

final workoutDaoProvider = Provider<WorkoutDao>((ref) {
  return ref.watch(appDatabaseProvider).workoutDao;
});

final sessionPersistenceProvider = Provider<SessionPersistence>((ref) {
  return SessionPersistence();
});

/// ~250ms UI rebuild cadence while resting. autoDispose → only runs while watched.
final restTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream<int>.periodic(const Duration(milliseconds: 250), (i) => i);
});

final workoutTimerControllerProvider =
    NotifierProvider<WorkoutTimerController, WorkoutTimerState>(
  WorkoutTimerController.new,
);

// ── controller ────────────────────────────────────────────────────────────

class WorkoutTimerController extends Notifier<WorkoutTimerState> {
  final Stopwatch _restStopwatch = Stopwatch();
  Timer? _cueTimer;
  String _sessionId = '';

  /// When the whole session started — drives the "已健身 MM:SS" total pill.
  DateTime? _sessionStartedAt;

  /// Elapsed already accrued before this process started the stopwatch — only
  /// non-zero after recovering a killed session (wall-clock derived).
  Duration _recoveredBase = Duration.zero;

  @override
  WorkoutTimerState build() {
    ref.onDispose(() => _cueTimer?.cancel());
    unawaited(_recover());
    return const TimerSetup();
  }

  /// Live rest elapsed. Normally monotonic (stopwatch); after a kill-recovery it
  /// is the wall-clock base plus the fresh monotonic stopwatch. Never in state.
  Duration get currentRestElapsed => _recoveredBase + _restStopwatch.elapsed;

  /// Total session elapsed (work + rest), never pauses. null before start.
  Duration? get currentSessionElapsed => _sessionStartedAt == null
      ? null
      : DateTime.now().difference(_sessionStartedAt!);

  // ── setup editing ──
  void updateTargetSets(int n) {
    final s = state;
    if (s is TimerSetup) state = s.copyWith(targetSets: n.clamp(1, 50));
  }

  void updateSoftTarget(Duration d) {
    final s = state;
    if (s is TimerSetup) state = s.copyWith(softTarget: d);
  }

  // ── transitions ──
  void start() {
    final s = state;
    if (s is! TimerSetup) return;
    _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _sessionStartedAt = DateTime.fromMillisecondsSinceEpoch(nowMs);
    // Close any abandoned session before starting a fresh one.
    unawaited(ref.read(workoutDaoProvider).closeOpenSessions(nowMs));
    unawaited(
      ref.read(workoutDaoProvider).insertSession(
            WorkoutSessionsCompanion.insert(
              id: _sessionId,
              startedAt: nowMs,
              targetSets: s.targetSets,
              softTargetMs: s.softTarget.inMilliseconds,
              createdAt: nowMs,
            ),
          ),
    );
    state = TimerWorking(
      session: WorkoutSession(targetSets: s.targetSets, softTarget: s.softTarget),
      currentSet: 1,
    );
    _persistSnapshot();
  }

  /// "做完這組" — finish the current set; either rest, or end if it was the last.
  void finishSet() {
    final s = state;
    if (s is! TimerWorking) return;
    final justDone = s.currentSet;

    if (justDone >= s.session.targetSets) {
      _endSession(s.session.copyWith(setsCompleted: justDone));
      return;
    }

    _recoveredBase = Duration.zero;
    _restStopwatch
      ..reset()
      ..start();
    final restStart = DateTime.now();
    final updated = s.session.copyWith(setsCompleted: justDone);

    // Track B (screen-off notifications) is NOT scheduled here — only when the
    // app actually goes to background (suspendForeground), so foreground audio
    // (track A) never double-fires with a notification.
    state = TimerResting(
      session: updated,
      setJustDone: justDone,
      restStartedAt: restStart,
    );
    _startCueTimer();
    _persistSnapshot();
  }

  void _startCueTimer() {
    _cueTimer?.cancel();
    _cueTimer =
        Timer.periodic(const Duration(milliseconds: 250), (_) => _checkCues());
  }

  void _stopCueTimer() {
    _cueTimer?.cancel();
    _cueTimer = null;
  }

  /// Track A (foreground audio) is only valid while the timer screen is visible
  /// AND the app is foreground. Call when either is lost (screen disposed or app
  /// backgrounded): stop the foreground ticker and hand the not-yet-fired cues
  /// to the screen-off fallback (track B). The monotonic stopwatch keeps running.
  void suspendForeground() {
    _stopCueTimer();
    final s = state;
    if (s is! TimerResting) return;
    unawaited(
      ref.read(restCueSchedulerProvider).scheduleForRest(
            sessionId: _sessionId,
            restStart: s.restStartedAt,
            softTarget: s.session.softTarget,
            spineThreshold: s.session.spineThreshold,
            skip: s.firedCues,
          ),
    );
  }

  /// Screen visible + foreground again → cancel the fallback, mark any cue whose
  /// time already passed as fired (track B handled it) so track A doesn't replay
  /// it, then resume the foreground ticker.
  void resumeForeground() {
    final s = state;
    if (s is! TimerResting) return;
    unawaited(ref.read(restCueSchedulerProvider).cancelAll());
    final elapsed = currentRestElapsed;
    final fired = {...s.firedCues};
    if (elapsed >= s.session.spineThreshold) fired.add(RestCue.spine);
    if (elapsed >= s.session.softTarget) fired.add(RestCue.soft);
    if (fired.length != s.firedCues.length) {
      state = s.copyWith(firedCues: fired);
      _persistSnapshot();
    }
    _startCueTimer();
  }

  void _checkCues() {
    final s = state;
    if (s is! TimerResting) return;
    final elapsed = currentRestElapsed;
    if (elapsed >= s.session.spineThreshold &&
        !s.firedCues.contains(RestCue.spine)) {
      state = s.copyWith(firedCues: {...s.firedCues, RestCue.spine});
      _persistSnapshot();
      unawaited(ref.read(audioCuePlayerProvider).play(RestCue.spine));
    } else if (elapsed >= s.session.softTarget &&
        !s.firedCues.contains(RestCue.soft)) {
      state = s.copyWith(firedCues: {...s.firedCues, RestCue.soft});
      _persistSnapshot();
      unawaited(ref.read(audioCuePlayerProvider).play(RestCue.soft));
    }
  }

  /// "我好了" — end rest, persist the record, advance to the next set.
  void readyForNext() {
    final s = state;
    if (s is! TimerResting) return;
    _cueTimer?.cancel();
    final restEnd = DateTime.now();
    final restDuration = currentRestElapsed;
    _restStopwatch.stop();
    _recoveredBase = Duration.zero;
    unawaited(ref.read(restCueSchedulerProvider).cancelAll());

    unawaited(
      ref.read(workoutDaoProvider).insertSetRecord(
            SetRecordsCompanion.insert(
              id: '$_sessionId-${s.setJustDone}',
              sessionId: _sessionId,
              setIndex: s.setJustDone,
              restStartMs: s.restStartedAt.millisecondsSinceEpoch,
              restEndMs: restEnd.millisecondsSinceEpoch,
              restDurationMs: restDuration.inMilliseconds,
              cueConfigJson:
                  '[${s.session.softTarget.inMilliseconds},${s.session.spineThreshold.inMilliseconds}]',
              createdAt: restEnd.millisecondsSinceEpoch,
            ),
          ),
    );

    final updated = s.session.copyWith(
      restRecords: [
        ...s.session.restRecords,
        RestRecord(
          setIndex: s.setJustDone,
          actualRest: restDuration,
          softTarget: s.session.softTarget,
        ),
      ],
    );
    state = TimerWorking(session: updated, currentSet: s.setJustDone + 1);
    _persistSnapshot();
  }

  /// 提早結束:不管現在在 working 還是 resting,直接收尾看總結。
  void endEarly() {
    final s = state;
    if (s is TimerWorking) {
      _endSession(s.session);
    } else if (s is TimerResting) {
      _endSession(s.session);
    }
  }

  void _endSession(WorkoutSession session) {
    _cueTimer?.cancel();
    _restStopwatch.stop();
    _recoveredBase = Duration.zero;
    unawaited(ref.read(restCueSchedulerProvider).cancelAll());
    _clearSnapshot();
    unawaited(
      ref
          .read(workoutDaoProvider)
          .finishSession(_sessionId, DateTime.now().millisecondsSinceEpoch),
    );
    state = TimerSummary(session: session);
  }

  void reset() {
    _cueTimer?.cancel();
    _restStopwatch
      ..stop()
      ..reset();
    _recoveredBase = Duration.zero;
    _sessionId = '';
    _sessionStartedAt = null;
    _clearSnapshot();
    state = const TimerSetup();
  }

  // ── kill-recovery persistence ──────────────────────────────────────────────

  void _persistSnapshot() {
    final s = state;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    SessionSnapshot? snap;
    if (s is TimerWorking) {
      snap = SessionSnapshot(
        sessionId: _sessionId,
        targetSets: s.session.targetSets,
        softTargetMs: s.session.softTarget.inMilliseconds,
        setsCompleted: s.session.setsCompleted,
        phase: 'working',
        setRef: s.currentSet,
        restStartedAtMs: 0,
        firedSoft: false,
        firedSpine: false,
        savedAtMs: nowMs,
        sessionStartedAtMs: _sessionStartedAt?.millisecondsSinceEpoch ?? nowMs,
      );
    } else if (s is TimerResting) {
      snap = SessionSnapshot(
        sessionId: _sessionId,
        targetSets: s.session.targetSets,
        softTargetMs: s.session.softTarget.inMilliseconds,
        setsCompleted: s.session.setsCompleted,
        phase: 'resting',
        setRef: s.setJustDone,
        restStartedAtMs: s.restStartedAt.millisecondsSinceEpoch,
        firedSoft: s.firedCues.contains(RestCue.soft),
        firedSpine: s.firedCues.contains(RestCue.spine),
        savedAtMs: nowMs,
        sessionStartedAtMs: _sessionStartedAt?.millisecondsSinceEpoch ?? nowMs,
      );
    }
    if (snap != null) {
      unawaited(ref.read(sessionPersistenceProvider).save(snap));
    }
  }

  void _clearSnapshot() =>
      unawaited(ref.read(sessionPersistenceProvider).clear());

  /// On a fresh process, rebuild an interrupted session from the snapshot +
  /// the rests already saved in the DB. Rest elapsed is recovered from wall
  /// clock (the monotonic stopwatch is gone after a kill).
  /// Discard a recovered session older than this — resuming a rest from hours
  /// ago is nonsense (e.g. killed yesterday, opened today).
  static const _maxSnapshotAge = Duration(hours: 3);

  Future<void> _recover() async {
    final snap = await ref.read(sessionPersistenceProvider).load();
    if (snap == null) return;
    if (state is! TimerSetup) return; // user already started interacting

    final age = DateTime.now().millisecondsSinceEpoch - snap.savedAtMs;
    if (age > _maxSnapshotAge.inMilliseconds) {
      _clearSnapshot();
      return; // too stale to resume
    }

    final records =
        await ref.read(workoutDaoProvider).recordsForSession(snap.sessionId);
    final softTarget = Duration(milliseconds: snap.softTargetMs);
    final session = WorkoutSession(
      targetSets: snap.targetSets,
      softTarget: softTarget,
      setsCompleted: snap.setsCompleted,
      restRecords: [
        for (final r in records)
          RestRecord(
            setIndex: r.setIndex,
            actualRest: Duration(milliseconds: r.restDurationMs),
            softTarget: softTarget,
          ),
      ],
    );
    _sessionId = snap.sessionId;
    _sessionStartedAt = snap.sessionStartedAtMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(snap.sessionStartedAtMs)
        : DateTime.now();

    if (snap.phase == 'resting') {
      final fired = <RestCue>{
        if (snap.firedSoft) RestCue.soft,
        if (snap.firedSpine) RestCue.spine,
      };
      final restStart =
          DateTime.fromMillisecondsSinceEpoch(snap.restStartedAtMs);
      final already = DateTime.now().difference(restStart);
      _recoveredBase = already.isNegative ? Duration.zero : already;
      _restStopwatch
        ..reset()
        ..start();
      state = TimerResting(
        session: session,
        setJustDone: snap.setRef,
        restStartedAt: restStart,
        firedCues: fired,
      );
      _startCueTimer();
    } else {
      state = TimerWorking(session: session, currentSet: snap.setRef);
    }
  }
}
