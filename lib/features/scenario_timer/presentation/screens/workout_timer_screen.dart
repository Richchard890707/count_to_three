import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:count_to_three/features/scenario_timer/data/lock_screen_mode.dart';
import 'package:count_to_three/features/scenario_timer/domain/models/workout_timer_state.dart';
import 'package:count_to_three/features/scenario_timer/presentation/controllers/workout_timer_controller.dart';
import 'package:count_to_three/features/scenario_timer/presentation/screens/workout_history_screen.dart';
import 'package:count_to_three/features/scenario_timer/presentation/widgets/timer_theme.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) return '${d.inHours}:$m:$s';
  return '$m:$s';
}

/// 健身組間計時器(精緻版,Model C)。
class WorkoutTimerScreen extends ConsumerStatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  ConsumerState<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends ConsumerState<WorkoutTimerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LockScreenMode.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(workoutTimerControllerProvider.notifier).resumeForeground();
      }
    });
  }

  @override
  void dispose() {
    ref.read(workoutTimerControllerProvider.notifier).suspendForeground();
    WidgetsBinding.instance.removeObserver(this);
    LockScreenMode.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final c = ref.read(workoutTimerControllerProvider.notifier);
    switch (lifecycle) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        c.suspendForeground();
      case AppLifecycleState.resumed:
        c.resumeForeground();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutTimerControllerProvider);
    // resting 背景在三階段間漸變;其餘畫面用安靜底。
    final bg = state is TimerResting
        ? TimerTheme.fieldFor(state.firedCues)
        : TimerTheme.calm;

    return Scaffold(
      backgroundColor: TimerTheme.calm,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        color: bg,
        child: SafeArea(
          child: switch (state) {
            TimerSetup s => _SetupView(s),
            TimerWorking() => const _RunningScaffold(child: _WorkingView()),
            TimerResting s => _RunningScaffold(child: _RestingView(s)),
            TimerSummary s => _SummaryView(s),
          },
        ),
      ),
    );
  }
}

/// working / resting 共用:頂部「已健身」總時長 pill + 內容。
class _RunningScaffold extends ConsumerWidget {
  const _RunningScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child,
        const Positioned(top: 16, left: 0, right: 0, child: _TotalTimePill()),
      ],
    );
  }
}

/// 頂部中性深玻璃 pill:已健身總時長。不染 accent,跨三底色恆定可讀。
class _TotalTimePill extends ConsumerWidget {
  const _TotalTimePill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(restTickerProvider); // 每秒重畫
    // working 沒有 restTicker → 也靠 1s 心跳;用 sessionElapsed 直接讀
    final elapsed =
        ref.read(workoutTimerControllerProvider.notifier).currentSessionElapsed;
    if (elapsed == null) return const SizedBox.shrink();
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: TimerTheme.pillGlass,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: TimerTheme.pillStroke),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: TimerTheme.onPill.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('已健身 ',
                    style: TextStyle(
                        color: TimerTheme.onPill.withValues(alpha: 0.55),
                        fontSize: 11)),
                Text(
                  _fmt(elapsed),
                  style: const TextStyle(
                    color: TimerTheme.onPill,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 大按鈕 ──────────────────────────────────────────────────────────────────

class _BigButton extends StatefulWidget {
  const _BigButton({
    required this.label,
    required this.onTap,
    this.sub,
    this.bg = TimerTheme.cyan,
    this.fg = TimerTheme.onCyan,
    this.ghost = false,
  });
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;
  final bool ghost;

  @override
  State<_BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<_BigButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final ghost = widget.ghost;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: 200,
          width: double.infinity,
          transform: Matrix4.translationValues(0, _down ? 3 : 0, 0)
            ..scaleByDouble(_down ? 0.985 : 1.0, _down ? 0.985 : 1.0, 1.0, 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: ghost ? TimerTheme.glass : widget.bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: ghost ? TimerTheme.hairline : widget.bg,
            ),
            boxShadow: ghost
                ? null
                : [
                    BoxShadow(
                      color: widget.bg.withValues(alpha: _down ? 0.09 : 0.18),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: ghost ? TimerTheme.textPrimary : widget.fg,
                  ),
                ),
                if (widget.sub != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.sub!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: (ghost ? TimerTheme.textPrimary : widget.fg)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 小型「結束訓練」鈕(角落,含確認對話框防誤觸)。
class _EndButton extends ConsumerWidget {
  const _EndButton({required this.fg});
  final Color fg;

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('結束這次訓練?'),
        content: const Text('會直接跳到總結,已記錄的休息都會保留。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('結束')),
        ],
      ),
    );
    if (ok == true) {
      ref.read(workoutTimerControllerProvider.notifier).endEarly();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, right: 8),
        child: TextButton.icon(
          onPressed: () => _confirm(context, ref),
          icon: Icon(Icons.stop_circle_outlined, color: fg, size: 20),
          label: Text('結束', style: TextStyle(color: fg)),
        ),
      ),
    );
  }
}

// ── SETUP ───────────────────────────────────────────────────────────────────

class _SetupView extends ConsumerWidget {
  const _SetupView(this.state);
  final TimerSetup state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(workoutTimerControllerProvider.notifier);
    final softSec = state.softTarget.inSeconds;
    final spineSec = (softSec * 1.5).round();
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('組間計時器',
                        style: TextStyle(
                            color: TimerTheme.textPrimary, fontSize: 22)),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WorkoutHistoryScreen(),
                        ),
                      ),
                      icon: Icon(Icons.history,
                          color: TimerTheme.textPrimary.withValues(alpha: 0.5)),
                      label: Text('紀錄',
                          style: TextStyle(
                              color: TimerTheme.textPrimary
                                  .withValues(alpha: 0.5))),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                _Stepper(
                  label: '目標組數',
                  value: '${state.targetSets}',
                  onMinus: () => c.updateTargetSets(state.targetSets - 1),
                  onPlus: () => c.updateTargetSets(state.targetSets + 1),
                ),
                const SizedBox(height: 26),
                _Stepper(
                  label: '軟目標休息',
                  value: '${softSec}s',
                  onMinus: () => c.updateSoftTarget(
                      Duration(seconds: (softSec - 15).clamp(15, 600))),
                  onPlus: () => c.updateSoftTarget(
                      Duration(seconds: (softSec + 15).clamp(15, 600))),
                ),
                const SizedBox(height: 14),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '脊椎提示 = 軟目標 ×1.5 = ',
                      style: TextStyle(
                          color: TimerTheme.textPrimary.withValues(alpha: 0.4),
                          fontSize: 13)),
                  TextSpan(
                      text: '${spineSec}s',
                      style: const TextStyle(
                          color: TimerTheme.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ])),
              ],
            ),
          ),
        ),
        _BigButton(label: '開始', onTap: c.start),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: TimerTheme.textPrimary.withValues(alpha: 0.6),
                fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            _RoundBtn(icon: Icons.remove, onTap: onMinus),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: TimerTheme.textPrimary,
                    fontSize: 46,
                    fontWeight: FontWeight.w300,
                    fontFeatures: [FontFeature.tabularFigures()],
                  )),
            ),
            _RoundBtn(icon: Icons.add, onTap: onPlus),
          ],
        ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: TimerTheme.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TimerTheme.hairline),
        ),
        child: Icon(icon, color: TimerTheme.textPrimary, size: 24),
      ),
    );
  }
}

// ── WORKING ─────────────────────────────────────────────────────────────────

class _WorkingView extends ConsumerWidget {
  const _WorkingView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutTimerControllerProvider);
    if (state is! TimerWorking) return const SizedBox.shrink();
    final c = ref.read(workoutTimerControllerProvider.notifier);
    final total = state.session.targetSets;
    final cur = state.currentSet;
    return Column(
      children: [
        _EndButton(fg: TimerTheme.textPrimary.withValues(alpha: 0.45)),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: '$cur',
                        style: const TextStyle(
                            color: TimerTheme.textPrimary,
                            fontSize: 96,
                            fontWeight: FontWeight.w300,
                            fontFeatures: [FontFeature.tabularFigures()])),
                    TextSpan(
                        text: ' / $total',
                        style: TextStyle(
                            color: TimerTheme.textPrimary.withValues(alpha: 0.4),
                            fontSize: 96,
                            fontWeight: FontWeight.w300,
                            fontFeatures: const [FontFeature.tabularFigures()])),
                  ]),
                ),
                const SizedBox(height: 16),
                _SetDots(total: total, current: cur),
                const SizedBox(height: 12),
                Text('進行中',
                    style: TextStyle(
                        color: TimerTheme.textPrimary.withValues(alpha: 0.5),
                        fontSize: 14)),
              ],
            ),
          ),
        ),
        _BigButton(
          label: '做完這組',
          sub: cur >= total ? '結束訓練' : '開始休息',
          onTap: c.finishSet,
        ),
      ],
    );
  }
}

class _SetDots extends StatelessWidget {
  const _SetDots({required this.total, required this.current});
  final int total;
  final int current;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 1; i <= total; i++)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < current
                  ? TimerTheme.cyan
                  : i == current
                      ? TimerTheme.cyan.withValues(alpha: 0.5)
                      : TimerTheme.textPrimary.withValues(alpha: 0.15),
            ),
          ),
      ],
    );
  }
}

// ── RESTING ─────────────────────────────────────────────────────────────────

class _RestingView extends ConsumerStatefulWidget {
  const _RestingView(this.state);
  final TimerResting state;

  @override
  ConsumerState<_RestingView> createState() => _RestingViewState();
}

class _RestingViewState extends ConsumerState<_RestingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Color _pulseColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _firePulse(Color c) {
    _pulseColor = c;
    _pulse.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(restTickerProvider); // 每 250ms 重畫
    final c = ref.read(workoutTimerControllerProvider.notifier);
    final state = ref.watch(workoutTimerControllerProvider);
    if (state is! TimerResting) return const SizedBox.shrink();

    // 偵測 cue 跨越 → 觸發一次性脈動
    ref.listen<WorkoutTimerState>(workoutTimerControllerProvider, (prev, next) {
      if (prev is TimerResting && next is TimerResting) {
        final gained = next.firedCues.difference(prev.firedCues);
        if (gained.contains(RestCue.spine)) {
          _firePulse(TimerTheme.amber.withValues(alpha: 0.6));
        } else if (gained.contains(RestCue.soft)) {
          _firePulse(Colors.white.withValues(alpha: 0.5));
        }
      }
    });

    final elapsed = c.currentRestElapsed;
    final spine = state.session.spineThreshold;
    final soft = state.session.softTarget;
    final progress = (elapsed.inMilliseconds / spine.inMilliseconds);
    final softFraction = soft.inMilliseconds / spine.inMilliseconds;

    final (accent, hint) = state.firedCues.contains(RestCue.spine)
        ? (TimerTheme.amber, '該動了')
        : state.firedCues.contains(RestCue.soft)
            ? (TimerTheme.cyan, '建議開始下一組')
            : (TimerTheme.neutral, '休息中');

    return Stack(
      children: [
        Column(
          children: [
            _EndButton(fg: TimerTheme.textPrimary.withValues(alpha: 0.55)),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(240, 240),
                        painter: _ArcPainter(
                          progress: progress,
                          softFraction: softFraction,
                          color: accent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hint,
                              style: TextStyle(
                                  color: accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            _fmt(elapsed),
                            style: const TextStyle(
                              color: TimerTheme.textPrimary,
                              fontSize: 72,
                              fontWeight: FontWeight.w300,
                              fontFeatures: [FontFeature.tabularFigures()],
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('已休息',
                              style: TextStyle(
                                  color: TimerTheme.textPrimary
                                      .withValues(alpha: 0.45),
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 固定參照 chips
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RefChip(label: '軟 ${soft.inSeconds}s'),
                  const SizedBox(width: 10),
                  _RefChip(label: '脊椎 ${spine.inSeconds}s'),
                ],
              ),
            ),
            _BigButton(
              label: '我好了',
              sub: '開始第 ${state.setJustDone + 1} 組',
              bg: state.firedCues.contains(RestCue.spine)
                  ? TimerTheme.amber
                  : TimerTheme.cyan,
              fg: state.firedCues.contains(RestCue.spine)
                  ? TimerTheme.onAmber
                  : TimerTheme.onCyan,
              onTap: c.readyForNext,
            ),
          ],
        ),
        // 一次性脈動
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) {
                final t = math.sin(_pulse.value * math.pi); // 0→1→0
                if (t <= 0.01) return const SizedBox.shrink();
                return CustomPaint(painter: _PulsePainter(t, _pulseColor));
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RefChip extends StatelessWidget {
  const _RefChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: TimerTheme.glass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TimerTheme.hairline),
      ),
      child: Text(label,
          style: TextStyle(
              color: TimerTheme.textPrimary.withValues(alpha: 0.55),
              fontSize: 12)),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.progress,
    required this.softFraction,
    required this.color,
  });
  final double progress;
  final double softFraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = color;
    final sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2,
        sweep, false, arc);

    // soft 目標 tick
    final a = -math.pi / 2 + softFraction.clamp(0.0, 1.0) * 2 * math.pi;
    final dir = Offset(math.cos(a), math.sin(a));
    final tick = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center + dir * (radius - 6), center + dir * (radius + 6),
        tick);
  }

  @override
  bool shouldRepaint(_ArcPainter o) =>
      o.progress != progress || o.color != color;
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.t, this.color);
  final double t; // 0..1
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 + 22 * t
      ..color = color.withValues(alpha: color.a * t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_PulsePainter o) => o.t != t || o.color != color;
}

// ── SUMMARY ─────────────────────────────────────────────────────────────────

class _SummaryView extends ConsumerWidget {
  const _SummaryView(this.state);
  final TimerSummary state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(workoutTimerControllerProvider.notifier);
    final records = state.session.restRecords;
    final totalRest = state.session.totalRest;
    final totalSession =
        c.currentSessionElapsed ?? totalRest; // 結束後 session 仍在記憶體
    final working = totalSession - totalRest;
    final workMs = working.inMilliseconds.clamp(0, 1 << 31);
    final restMs = totalRest.inMilliseconds;
    final denom = (workMs + restMs) == 0 ? 1 : (workMs + restMs);
    final softSec = state.session.softTarget.inSeconds;
    final maxRest = records.isEmpty
        ? 1
        : records.map((r) => r.actualRest.inSeconds).reduce(math.max);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
            children: [
              const Text('完成 ！',
                  style: TextStyle(
                      color: TimerTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('總時長',
                            style: TextStyle(
                                color: TimerTheme.textPrimary
                                    .withValues(alpha: 0.5),
                                fontSize: 12)),
                        Text(_fmt(totalSession),
                            style: const TextStyle(
                                color: TimerTheme.textPrimary,
                                fontSize: 40,
                                fontWeight: FontWeight.w300,
                                fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('總休息',
                          style: TextStyle(
                              color: TimerTheme.textPrimary
                                  .withValues(alpha: 0.5),
                              fontSize: 12)),
                      Text(_fmt(totalRest),
                          style: const TextStyle(
                              color: TimerTheme.cyan,
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              fontFeatures: [FontFeature.tabularFigures()])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 做組:休息 比例條
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    Expanded(
                      flex: workMs.clamp(1, denom),
                      child: Container(
                          height: 10,
                          color: Colors.white.withValues(alpha: 0.22)),
                    ),
                    Expanded(
                      flex: (restMs == 0 ? 1 : restMs),
                      child: Container(
                          height: 10,
                          color: TimerTheme.cyan.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('實際做組 ${_fmt(working)}',
                      style: TextStyle(
                          color: TimerTheme.textPrimary.withValues(alpha: 0.6),
                          fontSize: 11)),
                  Text('休息 ${_fmt(totalRest)}',
                      style: TextStyle(
                          color: TimerTheme.cyan.withValues(alpha: 0.8),
                          fontSize: 11)),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: TimerTheme.hairline),
              const SizedBox(height: 8),
              for (final r in records)
                _RestBar(
                  setIndex: r.setIndex,
                  seconds: r.actualRest.inSeconds,
                  maxSeconds: maxRest,
                  softSeconds: softSec,
                ),
            ],
          ),
        ),
        _BigButton(label: '完成', ghost: true, onTap: c.reset),
      ],
    );
  }
}

class _RestBar extends StatelessWidget {
  const _RestBar({
    required this.setIndex,
    required this.seconds,
    required this.maxSeconds,
    required this.softSeconds,
  });
  final int setIndex;
  final int seconds;
  final int maxSeconds;
  final int softSeconds;

  @override
  Widget build(BuildContext context) {
    // 顏色語意:青=達軟目標 / 灰=偏短 / 橘=超脊椎
    final spine = (softSeconds * 1.5).round();
    final color = seconds > spine
        ? TimerTheme.amber
        : seconds >= softSeconds
            ? TimerTheme.cyan
            : TimerTheme.neutral;
    final frac = (seconds / maxSeconds).clamp(0.05, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text('第 $setIndex 組',
                style: TextStyle(
                    color: TimerTheme.textPrimary.withValues(alpha: 0.6),
                    fontSize: 12)),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, cons) {
              final softX = (softSeconds / maxSeconds).clamp(0.0, 1.0) *
                  cons.maxWidth;
              return Stack(
                children: [
                  Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: TimerTheme.glass,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: frac,
                    child: Container(
                      height: 26,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // 軟目標虛線基準
                  Positioned(
                    left: softX,
                    top: 0,
                    bottom: 0,
                    child: Container(
                        width: 1.5,
                        color: TimerTheme.textPrimary.withValues(alpha: 0.35)),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(width: 10),
          Text('${seconds}s',
              style: const TextStyle(
                  color: TimerTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
