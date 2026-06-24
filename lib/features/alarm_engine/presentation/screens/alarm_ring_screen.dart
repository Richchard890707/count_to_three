import 'dart:async';

import 'package:count_to_three/app/theme/app_colors.dart';
import 'package:count_to_three/core/providers/alarm_scheduler_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({
    super.key,
    required this.alarmId,
    required this.reminderId,
    required this.title,
    this.snoozeCount = 0,
    this.maxSnoozeCount = 3,
  });

  final int alarmId;
  final String reminderId;
  final String title;
  final int snoozeCount;
  final int maxSnoozeCount;

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Timer _clock;
  DateTime _now = DateTime.now();
  final DateTime _ringStartTime = DateTime.now();
  String? _note;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    ref
        .read(appDatabaseProvider)
        .reminderDao
        .findById(widget.reminderId)
        .then((r) {
      if (mounted && r?.note != null && r!.note!.isNotEmpty) {
        setState(() => _note = r.note);
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _clock.cancel();
    super.dispose();
  }

  Future<void> _stop() async {
    await ref.read(alarmSchedulerProvider).cancelAlarm(widget.alarmId);
    if (mounted) context.go('/alarms');
  }

  Future<void> _snooze() async {
    await ref.read(alarmSchedulerProvider).snoozeAlarm(widget.alarmId);
    if (mounted) context.go('/alarms');
  }

  String _elapsedLabel() {
    final elapsed = _now.difference(_ringStartTime);
    final s = elapsed.inSeconds % 60;
    final min = elapsed.inMinutes;
    if (min == 0) return '已響 $s 秒';
    return '已響 $min 分 $s 秒';
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');

    return PopScope(
      canPop: false, // prevent back gesture dismissing the ring screen
      child: Scaffold(
        backgroundColor: AppColors.primaryRed,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Pulsing alarm icon
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => Transform.scale(
                  scale: 1.0 + _pulse.value * 0.15,
                  child: const Icon(
                    Icons.alarm_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Clock
              Text(
                '$h:$m',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Note (shown only when non-empty)
              if (_note != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _note!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Elapsed ringing time
              Text(
                _elapsedLabel(),
                style: const TextStyle(fontSize: 13, color: Colors.white38),
              ),

              const SizedBox(height: 8),

              // Snooze indicator
              if (widget.snoozeCount > 0)
                Text(
                  '已貪睡 ${widget.snoozeCount} / ${widget.maxSnoozeCount} 次',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),

              const Spacer(),

              // Snooze limit warning
              if (widget.snoozeCount >= widget.maxSnoozeCount)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '已達貪睡上限，停止後不可再貪睡',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: Row(
                  children: [
                    // Snooze (disabled when limit reached)
                    Expanded(
                      child: _RingButton(
                        icon: Icons.snooze_rounded,
                        label: '貪睡',
                        onTap: widget.snoozeCount < widget.maxSnoozeCount ? _snooze : null,
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Stop
                    Expanded(
                      child: _RingButton(
                        icon: Icons.stop_rounded,
                        label: '停止',
                        onTap: _stop,
                        outlined: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingButton extends StatelessWidget {
  const _RingButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.outlined,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return outlined
        ? OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white),
            label: Text(label, style: const TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          )
        : FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: AppColors.primaryRed),
            label: Text(label,
                style: const TextStyle(color: AppColors.primaryRed)),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          );
  }
}
