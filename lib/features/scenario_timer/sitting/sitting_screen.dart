import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:count_to_three/features/scenario_timer/data/lock_screen_mode.dart';
import 'package:count_to_three/features/scenario_timer/sitting/sitting_controller.dart';
import 'package:count_to_three/features/scenario_timer/presentation/widgets/timer_theme.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) return '${d.inHours}:$m:$s';
  return '$m:$s';
}

class SittingScreen extends ConsumerStatefulWidget {
  const SittingScreen({super.key});

  @override
  ConsumerState<SittingScreen> createState() => _SittingScreenState();
}

class _SittingScreenState extends ConsumerState<SittingScreen> {
  @override
  void initState() {
    super.initState();
    LockScreenMode.enable();
  }

  @override
  void dispose() {
    LockScreenMode.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sittingTickerProvider);
    final state = ref.watch(sittingControllerProvider);
    final standing = state.phase == SittingPhase.standing;
    final bg = standing ? TimerTheme.cyanField : TimerTheme.calm;

    return Scaffold(
      backgroundColor: TimerTheme.calm,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        color: bg,
        child: SafeArea(
          child: switch (state.phase) {
            SittingPhase.setup => const _SittingSetup(),
            SittingPhase.done => const _SittingDone(),
            _ => _SittingRunning(state: state),
          },
        ),
      ),
    );
  }
}

class _SittingSetup extends ConsumerWidget {
  const _SittingSetup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(sittingControllerProvider.notifier);
    final s = ref.watch(sittingControllerProvider);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('久坐提醒',
                    style: TextStyle(
                        color: TimerTheme.textPrimary, fontSize: 22)),
                const SizedBox(height: 36),
                _MinStepper(
                  label: '坐多久提醒一次',
                  minutes: s.sitDuration.inMinutes,
                  onChanged: (m) => c.updateSit(Duration(minutes: m)),
                ),
                const SizedBox(height: 26),
                _MinStepper(
                  label: '起來動多久',
                  minutes: s.standDuration.inMinutes,
                  onChanged: (m) => c.updateStand(Duration(minutes: m)),
                ),
                const SizedBox(height: 26),
                _RepeatRow(repeat: s.repeat, onChanged: c.updateRepeat),
              ],
            ),
          ),
        ),
        _BottomButton(label: '開始', onTap: c.start),
      ],
    );
  }
}

class _SittingRunning extends ConsumerWidget {
  const _SittingRunning({required this.state});
  final SittingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(sittingControllerProvider.notifier);
    final standing = state.phase == SittingPhase.standing;
    final accent = standing ? TimerTheme.cyan : TimerTheme.neutral;
    final label = standing ? '起來動一動' : '坐著工作中';
    final cycleText = state.repeat == null
        ? '第 ${state.completedCycles + 1} 圈'
        : '第 ${state.completedCycles + 1} / ${state.repeat} 圈';
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: TextButton.icon(
              onPressed: c.stop,
              icon: Icon(Icons.stop_circle_outlined,
                  color: TimerTheme.textPrimary.withValues(alpha: 0.5),
                  size: 20),
              label: Text('結束',
                  style: TextStyle(
                      color: TimerTheme.textPrimary.withValues(alpha: 0.5))),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                        color: accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  _fmt(state.remaining()),
                  style: const TextStyle(
                    color: TimerTheme.textPrimary,
                    fontSize: 96,
                    fontWeight: FontWeight.w200,
                    fontFeatures: [FontFeature.tabularFigures()],
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(cycleText,
                    style: TextStyle(
                        color: TimerTheme.textPrimary.withValues(alpha: 0.5),
                        fontSize: 15)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SittingDone extends ConsumerWidget {
  const _SittingDone();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(sittingControllerProvider.notifier);
    final s = ref.watch(sittingControllerProvider);
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('結束',
                    style: TextStyle(
                        color: TimerTheme.textPrimary, fontSize: 28)),
                const SizedBox(height: 8),
                Text('完成 ${s.completedCycles} 圈',
                    style: TextStyle(
                        color: TimerTheme.textPrimary.withValues(alpha: 0.5),
                        fontSize: 16)),
              ],
            ),
          ),
        ),
        _BottomButton(label: '再來一次', onTap: c.reset, ghost: true),
      ],
    );
  }
}

class _MinStepper extends StatelessWidget {
  const _MinStepper({
    required this.label,
    required this.minutes,
    required this.onChanged,
  });
  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

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
            _Round(
                icon: Icons.remove,
                onTap: () => onChanged((minutes - 5).clamp(1, 180))),
            Expanded(
              child: Text('$minutes 分',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: TimerTheme.textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ),
            _Round(
                icon: Icons.add,
                onTap: () => onChanged((minutes + 5).clamp(1, 180))),
          ],
        ),
      ],
    );
  }
}

class _RepeatRow extends StatelessWidget {
  const _RepeatRow({required this.repeat, required this.onChanged});
  final int? repeat;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('循環',
            style: TextStyle(
                color: TimerTheme.textPrimary.withValues(alpha: 0.6),
                fontSize: 14)),
        const Spacer(),
        ChoiceChip(
          label: const Text('無限'),
          selected: repeat == null,
          onSelected: (_) => onChanged(null),
        ),
        const SizedBox(width: 8),
        for (final n in [4, 8])
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text('$n 圈'),
              selected: repeat == n,
              onSelected: (_) => onChanged(n),
            ),
          ),
      ],
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.onTap});
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

class _BottomButton extends StatelessWidget {
  const _BottomButton(
      {required this.label, required this.onTap, this.ghost = false});
  final String label;
  final VoidCallback onTap;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ghost ? TimerTheme.glass : TimerTheme.cyan,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: ghost ? TimerTheme.hairline : TimerTheme.cyan),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: ghost ? TimerTheme.textPrimary : TimerTheme.onCyan)),
          ),
        ),
      ),
    );
  }
}
