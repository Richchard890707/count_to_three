import 'dart:async';

import 'package:count_to_three/app/theme/app_colors.dart';
import 'package:count_to_three/core/providers/alarm_scheduler_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({
    super.key,
    required this.alarmId,
    required this.reminderId,
    required this.title,
  });

  final int alarmId;
  final String reminderId;
  final String title;

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Timer _clock;
  DateTime _now = DateTime.now();

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
    // Cancel current, the native side handles snooze via NotificationFallback/AlarmKit
    // Here we just dismiss the ring screen — native snooze action already re-scheduled
    await ref.read(alarmSchedulerProvider).cancelAlarm(widget.alarmId);
    if (mounted) context.go('/alarms');
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

              const Spacer(),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: Row(
                  children: [
                    // Snooze
                    Expanded(
                      child: _RingButton(
                        icon: Icons.snooze_rounded,
                        label: '貪睡',
                        onTap: _snooze,
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
  final VoidCallback onTap;
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
