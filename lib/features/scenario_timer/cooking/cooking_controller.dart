import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:count_to_three/features/scenario_timer/domain/models/workout_timer_state.dart'
    show RestCue;
import 'package:count_to_three/features/scenario_timer/presentation/controllers/workout_timer_controller.dart'
    show audioCuePlayerProvider;

/// 一條獨立倒數(蛋 8 分、菜 3 分…)。並行,各自從加入時開始倒數。
class CookingLane {
  const CookingLane({
    required this.id,
    required this.label,
    required this.total,
    required this.startedAt,
    this.dinged = false,
  });

  final String id;
  final String label;
  final Duration total;
  final DateTime startedAt;
  final bool dinged;

  Duration remaining() {
    final r = total - DateTime.now().difference(startedAt);
    return r.isNegative ? Duration.zero : r;
  }

  bool get finished => DateTime.now().difference(startedAt) >= total;

  double get progress {
    final e = DateTime.now().difference(startedAt).inMilliseconds /
        total.inMilliseconds;
    return e.clamp(0.0, 1.0);
  }

  CookingLane copyWith({bool? dinged}) => CookingLane(
        id: id,
        label: label,
        total: total,
        startedAt: startedAt,
        dinged: dinged ?? this.dinged,
      );
}

/// ~500ms UI 心跳(只在被 watch 時跑)。
final cookingTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream<int>.periodic(const Duration(milliseconds: 500), (i) => i);
});

final cookingControllerProvider =
    NotifierProvider<CookingController, List<CookingLane>>(
        CookingController.new);

class CookingController extends Notifier<List<CookingLane>> {
  Timer? _timer;
  int _seq = 0;

  @override
  List<CookingLane> build() {
    ref.onDispose(() => _timer?.cancel());
    return const [];
  }

  void addLane(String label, Duration total) {
    final lane = CookingLane(
      id: '${_seq++}',
      label: label.trim().isEmpty ? '計時器' : label.trim(),
      total: total,
      startedAt: DateTime.now(),
    );
    state = [...state, lane];
    _timer ??=
        Timer.periodic(const Duration(milliseconds: 500), (_) => _check());
  }

  void removeLane(String id) {
    state = state.where((l) => l.id != id).toList();
    if (state.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _check() {
    var changed = false;
    final next = <CookingLane>[];
    for (final l in state) {
      if (l.finished && !l.dinged) {
        unawaited(ref.read(audioCuePlayerProvider).play(RestCue.spine));
        next.add(l.copyWith(dinged: true));
        changed = true;
      } else {
        next.add(l);
      }
    }
    if (changed) state = next;
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = const [];
  }
}
