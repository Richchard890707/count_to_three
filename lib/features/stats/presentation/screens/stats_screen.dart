import 'dart:io';

import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/features/stats/domain/models/stats_data.dart';
import 'package:count_to_three/features/stats/presentation/controllers/stats_controller.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(statsControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(statsControllerProvider.future),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
        data: (stats) => _StatsBody(stats: stats),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Today counts ─────────────────────────────────────────────
        _SectionHeader(title: '今日'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: '已完成',
                value: '${stats.todayCompleted}',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: '漏響',
                value: '${stats.todayMissed}',
                icon: Icons.cancel_outlined,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: '待觸發',
                value: '${stats.todayPending}',
                icon: Icons.schedule_outlined,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Today occurrence list ────────────────────────────────────
        const _TodayListSection(),
        const SizedBox(height: 20),

        // ── This week ───────────────────────────────────────────────
        _SectionHeader(title: '近 7 天'),
        const SizedBox(height: 8),
        _WeekRateCard(stats: stats),
        const SizedBox(height: 12),
        _DayBarChart(days: stats.last7Days),
        const SizedBox(height: 20),

        // ── Streak ──────────────────────────────────────────────────
        _SectionHeader(title: '連續完成'),
        const SizedBox(height: 8),
        _StreakCard(streak: stats.currentStreak),
        const SizedBox(height: 20),

        // ── All time ────────────────────────────────────────────────
        _SectionHeader(title: '歷史總計'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: '累計完成',
                value: '${stats.allTimeCompleted}',
                icon: Icons.emoji_events_outlined,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: '累計漏響',
                value: '${stats.allTimeMissed}',
                icon: Icons.warning_amber_outlined,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekRateCard extends StatelessWidget {
  const _WeekRateCard({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context) {
    final rate = stats.weekCompletionRate;
    final pct = rate == null ? '-' : '${(rate * 100).round()}%';
    final total = stats.weekCompleted + stats.weekMissed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  pct,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _rateColor(rate),
                      ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('完成率', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '完成 ${stats.weekCompleted} / 共 $total 次',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            if (rate != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: rate,
                color: _rateColor(rate),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _rateColor(double? rate) {
    if (rate == null) return Colors.grey;
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final label = streak == 0
        ? '尚無連續紀錄'
        : streak == 1
            ? '連續 1 天'
            : '連續 $streak 天';

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.local_fire_department,
          color: streak > 0 ? Colors.deepOrange : Colors.grey,
          size: 36,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          streak > 0 ? '每天都有完成至少一個提醒' : '今天完成第一個提醒，開始你的連續紀錄！',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── 7-day bar chart ───────────────────────────────────────────────────────────

class _DayBarChart extends StatelessWidget {
  const _DayBarChart({required this.days});
  final List<DayStats> days;

  static const _barMaxH = 72.0;
  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final maxTotal = days.fold(0, (m, d) => d.total > m ? d.total : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '每日明細',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final frac = maxTotal == 0 ? 0.0 : d.total / maxTotal;
                final barH = (_barMaxH * frac).clamp(d.total > 0 ? 6.0 : 0.0, _barMaxH);
                final completedFrac = d.total == 0 ? 0.0 : d.completed / d.total;
                final greenH = barH * completedFrac;
                final orangeH = barH - greenH;
                final wd = _weekdays[d.date.weekday - 1];
                final isToday = _isToday(d.date);

                return Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: _barMaxH,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: d.total == 0
                              ? Container(
                                  width: 10,
                                  height: 2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (orangeH > 0)
                                      Container(
                                        height: orangeH,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade300,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(4),
                                            topRight: const Radius.circular(4),
                                            bottomLeft: greenH > 0
                                                ? Radius.zero
                                                : const Radius.circular(4),
                                            bottomRight: greenH > 0
                                                ? Radius.zero
                                                : const Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                    if (greenH > 0)
                                      Container(
                                        height: greenH,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade400,
                                          borderRadius: BorderRadius.only(
                                            topLeft: orangeH > 0
                                                ? Radius.zero
                                                : const Radius.circular(4),
                                            topRight: orangeH > 0
                                                ? Radius.zero
                                                : const Radius.circular(4),
                                            bottomLeft: const Radius.circular(4),
                                            bottomRight: const Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '週$wd',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: isToday ? FontWeight.bold : null,
                              color: isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Legend(color: Colors.green.shade400, label: '完成'),
                const SizedBox(width: 16),
                _Legend(color: Colors.orange.shade300, label: '漏響'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

// ── Today occurrence list ─────────────────────────────────────────────────────

class _TodayListSection extends ConsumerWidget {
  const _TodayListSection();

  static const _alarmChannel = MethodChannel('app.ontime/alarm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occsAsync  = ref.watch(todayOccurrencesProvider);
    final titlesAsync = ref.watch(reminderTitleMapProvider);

    return occsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (occs) {
        if (occs.isEmpty) return const SizedBox.shrink();
        final titles = titlesAsync.valueOrNull ?? {};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: '今日詳細（${occs.length} 筆）'),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: occs.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
                itemBuilder: (_, i) => _TodayOccurrenceRow(
                  occ: occs[i],
                  title: titles[occs[i].reminderId] ?? '提醒',
                  onComplete: () => _markComplete(context, ref, occs[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markComplete(
    BuildContext context,
    WidgetRef ref,
    Occurrence occ,
  ) async {
    await ref.read(appDatabaseProvider).occurrenceDao
        .updateState(occ.id, 'completed');
    await ref.read(rescheduleWindowProvider).fillForReminder(occ.reminderId);
    if (Platform.isIOS) {
      try {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
        final count = await ref.read(appDatabaseProvider).occurrenceDao
            .countByStateInRange('pending', todayStart, todayStart + 86400000);
        await _alarmChannel.invokeMethod('badge.setCount', count);
      } catch (_) {}
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已記錄完成'), duration: Duration(seconds: 2)),
      );
    }
  }
}

class _TodayOccurrenceRow extends StatelessWidget {
  const _TodayOccurrenceRow({
    required this.occ,
    required this.title,
    required this.onComplete,
  });

  final Occurrence occ;
  final String title;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dt = DateTime.fromMillisecondsSinceEpoch(occ.scheduledAt);
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    final (icon, color, label) = switch (occ.state) {
      'completed' => (Icons.check_circle_outline, Colors.green, '已完成'),
      'missed'    => (Icons.cancel_outlined, Colors.red.shade400, '漏響'),
      _           => (Icons.schedule_outlined, theme.colorScheme.primary, '待觸發'),
    };

    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        timeStr,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: occ.state == 'pending'
          ? TextButton(
              onPressed: onComplete,
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('✓ 完成'),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: color),
              ),
            ),
    );
  }
}
