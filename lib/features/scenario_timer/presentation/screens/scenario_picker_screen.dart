import 'package:flutter/material.dart';

import 'package:count_to_three/features/scenario_timer/cooking/cooking_screen.dart';
import 'package:count_to_three/features/scenario_timer/presentation/screens/workout_timer_screen.dart';
import 'package:count_to_three/features/scenario_timer/presentation/widgets/timer_theme.dart';
import 'package:count_to_three/features/scenario_timer/sitting/sitting_screen.dart';

/// 情境選擇:健身 / 煮飯 / 久坐。未來自訂模式也從這裡加入。
class ScenarioPickerScreen extends StatelessWidget {
  const ScenarioPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimerTheme.calm,
      appBar: AppBar(
        backgroundColor: TimerTheme.calm,
        foregroundColor: TimerTheme.textPrimary,
        title: const Text('情境計時器'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          _ScenarioCard(
            icon: Icons.fitness_center,
            title: '健身組間',
            subtitle: '序列 · 正數休息 · 軟/脊椎提示',
            accent: TimerTheme.cyan,
            onTap: () => _go(context, const WorkoutTimerScreen()),
          ),
          _ScenarioCard(
            icon: Icons.restaurant,
            title: '煮飯',
            subtitle: '並行 · 多個獨立倒數',
            accent: TimerTheme.amber,
            onTap: () => _go(context, const CookingScreen()),
          ),
          _ScenarioCard(
            icon: Icons.chair_outlined,
            title: '久坐提醒',
            subtitle: '循環 · 坐 → 起身 → 重複',
            accent: TimerTheme.neutral,
            onTap: () => _go(context, const SittingScreen()),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: TimerTheme.glass,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: TimerTheme.hairline),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: TimerTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              color: TimerTheme.textPrimary
                                  .withValues(alpha: 0.5),
                              fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: TimerTheme.textPrimary.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
