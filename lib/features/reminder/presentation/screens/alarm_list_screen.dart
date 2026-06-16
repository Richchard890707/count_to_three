import 'package:count_to_three/app/theme/app_colors.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/reminder/presentation/controllers/alarm_list_controller.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmListScreen extends ConsumerWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(alarmListControllerProvider);

    ref.listen(alarmEventsProvider, (_, next) {
      next.whenData((event) {
        final msg = switch (event.type) {
          AlarmEventType.fired => '鬧鐘響了：${event.title ?? ""}',
          AlarmEventType.snoozed => '貪睡（第 ${event.snoozeCount} 次）',
          AlarmEventType.dismissed => event.auto ? '自動關閉' : '已停止',
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      });
    });

    return reminders.when(
      data: (list) => list.isEmpty ? const _EmptyState() : _ReminderList(reminders: list),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('錯誤：$e')),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm_add_outlined, size: 72, color: hint),
          const SizedBox(height: 16),
          Text(
            '還沒有提醒',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: hint),
          ),
          const SizedBox(height: 8),
          Text(
            '點右下角 + 新增第一個',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: hint),
          ),
        ],
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _ReminderList extends StatelessWidget {
  const _ReminderList({required this.reminders});
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: reminders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ReminderCard(reminder: reminders[i]),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.reminder});
  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DateTime.fromMillisecondsSinceEpoch(reminder.startAt);
    final isAlarm = reminder.alertLevel == 'ALARM';
    final isTodo = reminder.type == 'todo';
    final isRecurring = reminder.recurrenceRuleId != null;

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('刪除提醒'),
          content: Text('確定要刪除「${reminder.title}」？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => ref
          .read(alarmListControllerProvider.notifier)
          .deleteReminder(reminder.id),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isAlarm
                ? AppColors.primaryRed.withAlpha(60)
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Time column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isAlarm ? AppColors.primaryRed : null,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    _dateLabel(t),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        _SmallChip(
                          icon: _typeIcon(reminder.type),
                          label: _typeLabel(reminder.type),
                        ),
                        if (isRecurring)
                          const _SmallChip(
                            icon: Icons.repeat,
                            label: '重複',
                          ),
                        if (!isAlarm)
                          _SmallChip(
                            icon: reminder.alertLevel == 'NOTIFICATION'
                                ? Icons.notifications_outlined
                                : Icons.notifications_off_outlined,
                            label: reminder.alertLevel == 'NOTIFICATION'
                                ? '通知'
                                : '靜默',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action
              if (isTodo)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.green,
                  tooltip: '標記完成',
                  onPressed: () => ref
                      .read(alarmListControllerProvider.notifier)
                      .completeTodo(reminder.id),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime t) {
    final today = DateTime.now();
    final diff = DateTime(t.year, t.month, t.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return switch (diff) {
      0 => '今天',
      1 => '明天',
      < 0 => '${t.month}月${t.day}日（已過）',
      _ => '${t.month}月${t.day}日',
    };
  }

  IconData _typeIcon(String type) => switch (type) {
        'todo' => Icons.check_box_outline_blank,
        'event' => Icons.event_outlined,
        _ => Icons.alarm,
      };

  String _typeLabel(String type) => switch (type) {
        'todo' => '待辦',
        'event' => '事件',
        _ => '鬧鐘',
      };
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
