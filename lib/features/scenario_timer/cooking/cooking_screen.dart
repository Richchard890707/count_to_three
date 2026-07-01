import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:count_to_three/features/scenario_timer/cooking/cooking_controller.dart';
import 'package:count_to_three/features/scenario_timer/data/lock_screen_mode.dart';
import 'package:count_to_three/features/scenario_timer/presentation/widgets/timer_theme.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) return '${d.inHours}:$m:$s';
  return '$m:$s';
}

/// 煮飯模式:多個並行獨立倒數,各有標籤,到點各自叮。
class CookingScreen extends ConsumerStatefulWidget {
  const CookingScreen({super.key});

  @override
  ConsumerState<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends ConsumerState<CookingScreen> {
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

  Future<void> _addDialog() async {
    final result = await showDialog<({String label, Duration total})>(
      context: context,
      builder: (_) => const _AddTimerDialog(),
    );
    if (result != null) {
      ref
          .read(cookingControllerProvider.notifier)
          .addLane(result.label, result.total);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cookingTickerProvider);
    final lanes = ref.watch(cookingControllerProvider);

    return Scaffold(
      backgroundColor: TimerTheme.calm,
      appBar: AppBar(
        backgroundColor: TimerTheme.calm,
        foregroundColor: TimerTheme.textPrimary,
        title: const Text('煮飯計時'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDialog,
        backgroundColor: TimerTheme.cyan,
        foregroundColor: TimerTheme.onCyan,
        icon: const Icon(Icons.add),
        label: const Text('新增計時器'),
      ),
      body: lanes.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined,
                      size: 56,
                      color: TimerTheme.textPrimary.withValues(alpha: 0.25)),
                  const SizedBox(height: 12),
                  Text('按右下角加一個倒數\n(蛋 8 分、燙青菜 3 分…)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: TimerTheme.textPrimary.withValues(alpha: 0.5),
                          fontSize: 15)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: lanes.length,
              itemBuilder: (_, i) => _LaneCard(lane: lanes[i]),
            ),
    );
  }
}

class _LaneCard extends ConsumerWidget {
  const _LaneCard({required this.lane});
  final CookingLane lane;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = lane.finished;
    final remaining = lane.remaining();
    final accent = done ? TimerTheme.amber : TimerTheme.cyan;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
      decoration: BoxDecoration(
        color: TimerTheme.glass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: done ? accent.withValues(alpha: 0.6) : TimerTheme.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lane.label,
                    style: TextStyle(
                        color: TimerTheme.textPrimary.withValues(alpha: 0.7),
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  done ? '完成' : _fmt(remaining),
                  style: TextStyle(
                    color: done ? accent : TimerTheme.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: lane.progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(cookingControllerProvider.notifier).removeLane(lane.id),
            icon: Icon(Icons.close,
                color: TimerTheme.textPrimary.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

class _AddTimerDialog extends StatefulWidget {
  const _AddTimerDialog();

  @override
  State<_AddTimerDialog> createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends State<_AddTimerDialog> {
  final _label = TextEditingController();
  int _minutes = 3;
  int _seconds = 0;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF222C38),
      title: const Text('新增計時器',
          style: TextStyle(color: TimerTheme.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _label,
            style: const TextStyle(color: TimerTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: '標籤(蛋 / 菜…)',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NumPicker(
                  label: '分',
                  value: _minutes,
                  onChanged: (v) => setState(() => _minutes = v.clamp(0, 180))),
              const SizedBox(width: 16),
              _NumPicker(
                  label: '秒',
                  value: _seconds,
                  step: 15,
                  onChanged: (v) => setState(() => _seconds = v % 60)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消')),
        TextButton(
          onPressed: () {
            final total = Duration(minutes: _minutes, seconds: _seconds);
            if (total.inSeconds == 0) return;
            Navigator.pop(
                context, (label: _label.text, total: total));
          },
          child: const Text('開始'),
        ),
      ],
    );
  }
}

class _NumPicker extends StatelessWidget {
  const _NumPicker({
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
  });
  final String label;
  final int value;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Row(
          children: [
            IconButton(
                onPressed: () => onChanged(value - step),
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.white70)),
            SizedBox(
              width: 40,
              child: Text('$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: TimerTheme.textPrimary,
                      fontSize: 22,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ),
            IconButton(
                onPressed: () => onChanged(value + step),
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white70)),
          ],
        ),
      ],
    );
  }
}
