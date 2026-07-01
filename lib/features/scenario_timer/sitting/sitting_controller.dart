import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:count_to_three/features/scenario_timer/domain/models/workout_timer_state.dart'
    show RestCue;
import 'package:count_to_three/features/scenario_timer/presentation/controllers/workout_timer_controller.dart'
    show audioCuePlayerProvider;

enum SittingPhase { setup, sitting, standing, done }

class SittingState {
  const SittingState({
    this.sitDuration = const Duration(minutes: 25),
    this.standDuration = const Duration(minutes: 5),
    this.repeat, // null = 無限循環
    this.phase = SittingPhase.setup,
    this.phaseStartedAt,
    this.completedCycles = 0,
  });

  final Duration sitDuration;
  final Duration standDuration;
  final int? repeat;
  final SittingPhase phase;
  final DateTime? phaseStartedAt;
  final int completedCycles;

  Duration get _currentTotal =>
      phase == SittingPhase.standing ? standDuration : sitDuration;

  Duration remaining() {
    if (phaseStartedAt == null) return _currentTotal;
    final r = _currentTotal - DateTime.now().difference(phaseStartedAt!);
    return r.isNegative ? Duration.zero : r;
  }

  bool get phaseElapsed =>
      phaseStartedAt != null &&
      DateTime.now().difference(phaseStartedAt!) >= _currentTotal;

  SittingState copyWith({
    Duration? sitDuration,
    Duration? standDuration,
    Object? repeat = _sentinel,
    SittingPhase? phase,
    Object? phaseStartedAt = _sentinel,
    int? completedCycles,
  }) {
    return SittingState(
      sitDuration: sitDuration ?? this.sitDuration,
      standDuration: standDuration ?? this.standDuration,
      repeat: repeat == _sentinel ? this.repeat : repeat as int?,
      phase: phase ?? this.phase,
      phaseStartedAt: phaseStartedAt == _sentinel
          ? this.phaseStartedAt
          : phaseStartedAt as DateTime?,
      completedCycles: completedCycles ?? this.completedCycles,
    );
  }

  static const _sentinel = Object();
}

final sittingTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream<int>.periodic(const Duration(milliseconds: 500), (i) => i);
});

final sittingControllerProvider =
    NotifierProvider<SittingController, SittingState>(SittingController.new);

class SittingController extends Notifier<SittingState> {
  Timer? _timer;

  @override
  SittingState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SittingState();
  }

  // ── setup ──
  void updateSit(Duration d) {
    if (state.phase == SittingPhase.setup) {
      state = state.copyWith(sitDuration: d);
    }
  }

  void updateStand(Duration d) {
    if (state.phase == SittingPhase.setup) {
      state = state.copyWith(standDuration: d);
    }
  }

  void updateRepeat(int? r) {
    if (state.phase == SittingPhase.setup) {
      state = state.copyWith(repeat: r);
    }
  }

  // ── run ──
  void start() {
    if (state.phase != SittingPhase.setup) return;
    state = state.copyWith(
      phase: SittingPhase.sitting,
      phaseStartedAt: DateTime.now(),
      completedCycles: 0,
    );
    _timer =
        Timer.periodic(const Duration(milliseconds: 500), (_) => _check());
  }

  void _check() {
    final s = state;
    if (!s.phaseElapsed) return;
    unawaited(ref.read(audioCuePlayerProvider).play(RestCue.spine));
    if (s.phase == SittingPhase.sitting) {
      // 坐完 → 起身
      state = s.copyWith(
          phase: SittingPhase.standing, phaseStartedAt: DateTime.now());
    } else {
      // 站完 = 完成一圈
      final cycles = s.completedCycles + 1;
      if (s.repeat != null && cycles >= s.repeat!) {
        _timer?.cancel();
        _timer = null;
        state = s.copyWith(
            phase: SittingPhase.done,
            completedCycles: cycles,
            phaseStartedAt: null);
      } else {
        state = s.copyWith(
            phase: SittingPhase.sitting,
            phaseStartedAt: DateTime.now(),
            completedCycles: cycles);
      }
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(phase: SittingPhase.done, phaseStartedAt: null);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = SittingState(
      sitDuration: state.sitDuration,
      standDuration: state.standDuration,
      repeat: state.repeat,
    );
  }
}
