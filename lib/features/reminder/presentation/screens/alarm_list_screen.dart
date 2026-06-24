import 'package:count_to_three/app/theme/app_colors.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/tick_provider.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/reminder/presentation/controllers/alarm_list_controller.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/shared/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alarm_list_screen.g.dart';

@riverpod
Future<RecurrenceRule?> recurrenceRule(RecurrenceRuleRef ref, String? ruleId) async {
  if (ruleId == null) return null;
  return ref.watch(appDatabaseProvider).recurrenceRuleDao.findById(ruleId);
}

@riverpod
Future<List<Occurrence>> recentOccurrences(
  RecentOccurrencesRef ref,
  String reminderId,
) =>
    ref.watch(appDatabaseProvider).occurrenceDao.getRecentByReminder(
      reminderId,
      limit: 15,
    );

/// Streams the next pending occurrence for a reminder so the card can
/// display the correct upcoming fire time instead of the original startAt.
@riverpod
Stream<Occurrence?> nextOccurrence(NextOccurrenceRef ref, String reminderId) =>
    ref.watch(appDatabaseProvider).occurrenceDao.watchNextPending(reminderId);

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(alarmListControllerProvider);
    final filter = ref.watch(alarmFilterProvider);
    final filterNotifier = ref.read(alarmFilterProvider.notifier);

    ref.listen(alarmEventsProvider, (_, next) {
      next.whenData((event) {
        final msg = switch (event.type) {
          AlarmEventType.fired => '鬧鐘響了：${event.title ?? ""}',
          AlarmEventType.snoozed => '貪睡（第 ${event.snoozeCount} 次）',
          AlarmEventType.dismissed => event.auto ? '自動關閉' : '已停止',
          AlarmEventType.notifTapped => null,
        };
        if (msg == null) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      });
    });

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: '搜尋標題或備忘…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: filter.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              filterNotifier.setQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                  onChanged: filterNotifier.setQuery,
                ),
              ),
              _SortButton(filter: filter, notifier: filterNotifier),
            ],
          ),
        ),

        // ── Filter chips ────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              for (final (type, label) in [
                ('alarm', '鬧鐘'),
                ('event', '事件'),
                ('todo', '待辦'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(label),
                    selected: filter.types.contains(type),
                    onSelected: (_) => filterNotifier.toggleType(type),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              FilterChip(
                label: const Text('僅啟用'),
                selected: filter.onlyEnabled,
                onSelected: (_) => filterNotifier.toggleOnlyEnabled(),
                visualDensity: VisualDensity.compact,
              ),
              if (filter.isActive) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _searchCtrl.clear();
                    filterNotifier.clear();
                  },
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                  label: const Text('清除'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Selection header ────────────────────────────────────────
        reminders.whenOrNull(
          data: (list) {
            final sel = ref.watch(alarmListSelectionProvider);
            if (!sel.isActive) return null;
            return _SelectionHeader(
              count: sel.count,
              allIds: list.map((r) => r.id).toList(),
            );
          },
        ) ?? const SizedBox.shrink(),

        // ── List ────────────────────────────────────────────────────
        Expanded(
          child: reminders.when(
            data: (list) {
              if (list.isEmpty && filter.isActive) {
                return _NoResults(query: filter.query);
              }
              return list.isEmpty
                  ? const _EmptyState()
                  : _ReminderList(reminders: list);
            },
            loading: () => const SkeletonAlarmList(),
            error: (e, _) => Center(child: Text('錯誤：$e')),
          ),
        ),

        // ── Bulk action bar ─────────────────────────────────────────
        _BulkActionBar(context: context, ref: ref),
      ],
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

// ── Sort button ───────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  const _SortButton({required this.filter, required this.notifier});
  final AlarmListFilterState filter;
  final AlarmFilter notifier;

  @override
  Widget build(BuildContext context) {
    final isCustomSort = filter.isSorted;
    return PopupMenuButton<AlarmSortField>(
      icon: Badge(
        isLabelVisible: isCustomSort,
        child: const Icon(Icons.sort_outlined),
      ),
      tooltip: '排序',
      onSelected: (field) => notifier.setSort(field),
      itemBuilder: (ctx) => AlarmSortField.values.map((field) {
        final isActive = filter.sortField == field;
        return PopupMenuItem<AlarmSortField>(
          value: field,
          child: Row(
            children: [
              Icon(
                isActive
                    ? (filter.sortDesc
                        ? Icons.arrow_downward
                        : Icons.arrow_upward)
                    : Icons.remove,
                size: 16,
                color: isActive
                    ? Theme.of(ctx).colorScheme.primary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                field.label,
                style: isActive
                    ? TextStyle(
                        color: Theme.of(ctx).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      )
                    : null,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── No results ────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_outlined, size: 60, color: hint),
          const SizedBox(height: 12),
          Text(
            query.isNotEmpty ? '找不到「$query」' : '沒有符合條件的提醒',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: hint),
          ),
        ],
      ),
    );
  }
}

// ── Selection header ──────────────────────────────────────────────────────────

class _SelectionHeader extends ConsumerWidget {
  const _SelectionHeader({required this.count, required this.allIds});
  final int count;
  final List<String> allIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(alarmListSelectionProvider);
    final isAllSelected = sel.selectedIds.length == allIds.length;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: cs.primaryContainer.withAlpha(100),
      child: Row(
        children: [
          Text(
            '已選 $count 項',
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              if (isAllSelected) {
                ref.read(alarmListSelectionProvider.notifier).clear();
              } else {
                ref.read(alarmListSelectionProvider.notifier).selectAll(allIds);
              }
            },
            child: Text(isAllSelected ? '取消全選' : '全選'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () =>
                ref.read(alarmListSelectionProvider.notifier).clear(),
          ),
        ],
      ),
    );
  }
}

// ── Bulk action bar ───────────────────────────────────────────────────────────

class _BulkActionBar extends ConsumerWidget {
  const _BulkActionBar({required this.context, required this.ref});
  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext buildContext, WidgetRef widgetRef) {
    final sel = widgetRef.watch(alarmListSelectionProvider);
    if (!sel.isActive) return const SizedBox.shrink();

    final notifier = widgetRef.read(alarmListControllerProvider.notifier);
    final selNotifier = widgetRef.read(alarmListSelectionProvider.notifier);
    final ids = sel.selectedIds;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(buildContext).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: ids.isEmpty
                    ? null
                    : () async {
                        await notifier.bulkSetEnabled(ids, enabled: true);
                        selNotifier.clear();
                      },
                icon: const Icon(Icons.alarm_on_outlined, size: 18),
                label: const Text('啟用'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: ids.isEmpty
                    ? null
                    : () async {
                        await notifier.bulkSetEnabled(ids, enabled: false);
                        selNotifier.clear();
                      },
                icon: const Icon(Icons.alarm_off_outlined, size: 18),
                label: const Text('停用'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: ids.isEmpty
                    ? null
                    : () => _confirmBulkDelete(buildContext, widgetRef, ids),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade400),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('刪除'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBulkDelete(
    BuildContext ctx,
    WidgetRef widgetRef,
    Set<String> ids,
  ) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('批次刪除'),
        content: Text('確定要刪除選取的 ${ids.length} 個提醒？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widgetRef
        .read(alarmListControllerProvider.notifier)
        .bulkDelete(ids);
    widgetRef.read(alarmListSelectionProvider.notifier).clear();
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
    // Use next pending occurrence time when available; fall back to startAt
    // so that recurring reminders always show when they will next fire.
    final nextOcc = ref.watch(nextOccurrenceProvider(reminder.id));
    final t = nextOcc.whenOrNull(
          data: (occ) => occ != null
              ? DateTime.fromMillisecondsSinceEpoch(occ.scheduledAt)
              : null,
        ) ??
        DateTime.fromMillisecondsSinceEpoch(reminder.startAt);
    ref.watch(minuteTickProvider); // rebuild every minute for live countdown
    final isAlarm = reminder.alertLevel == 'ALARM';
    final isTodo = reminder.type == 'todo';
    final isRecurring = reminder.recurrenceRuleId != null;
    final enabled = reminder.isEnabled;
    final countdown = _countdownLabel(t);

    final sel = ref.watch(alarmListSelectionProvider);
    final inSelectionMode = sel.isActive;
    final isSelected = sel.contains(reminder.id);
    final selNotifier = ref.read(alarmListSelectionProvider.notifier);

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: inSelectionMode
          ? DismissDirection.none
          : DismissDirection.endToStart,
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
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withAlpha(80)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withAlpha(120)
                : enabled
                    ? (isAlarm
                        ? AppColors.primaryRed.withAlpha(60)
                        : Theme.of(context).colorScheme.outlineVariant)
                    : Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: inSelectionMode
              ? () => selNotifier.toggle(reminder.id)
              : () => context.push('/alarm/edit', extra: reminder),
          onLongPress: inSelectionMode
              ? null
              : () => selNotifier.activate(reminder.id),
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Color accent bar
                  if (reminder.color != null) ...[
                    Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                            'FF${reminder.color!.substring(1)}',
                            radix: 16)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  // Selection checkbox (selection mode only)
                  if (inSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => selNotifier.toggle(reminder.id),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                  ],
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
                      if (countdown != null && enabled)
                        Text(
                          countdown,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryRed,
                                fontSize: 10,
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
                        if (reminder.note != null && reminder.note!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            reminder.note!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: [
                            _SmallChip(
                              icon: _typeIcon(reminder.type),
                              label: _typeLabel(reminder.type),
                            ),
                            if (isRecurring)
                              _RecurringChip(ruleId: reminder.recurrenceRuleId!),
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
                  // Actions column
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: enabled,
                        activeThumbColor: isAlarm ? AppColors.primaryRed : null,
                        onChanged: (v) => ref
                            .read(alarmListControllerProvider.notifier)
                            .toggleEnabled(reminder.id, enabled: v),
                      ),
                      if (isTodo)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          color: Colors.green,
                          tooltip: '標記完成',
                          iconSize: 20,
                          onPressed: () => ref
                              .read(alarmListControllerProvider.notifier)
                              .completeTodo(reminder.id),
                        ),
                      IconButton(
                        icon: const Icon(Icons.history_outlined),
                        iconSize: 20,
                        tooltip: '歷史記錄',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => _OccurrenceHistorySheet(
                            reminder: reminder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _countdownLabel(DateTime t) {
    final diff = t.difference(DateTime.now());
    if (diff.isNegative) return null;
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return '還有 $h 小時 $m 分';
    if (m > 0) return '還有 $m 分鐘';
    return '即將響鈴';
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

// Resolves weekday text from the RecurrenceRule (e.g. "週一三五" or "每天").
class _RecurringChip extends ConsumerWidget {
  const _RecurringChip({required this.ruleId});
  final String ruleId;

  static const _dayMap = {
    'MO': '一', 'TU': '二', 'WE': '三',
    'TH': '四', 'FR': '五', 'SA': '六', 'SU': '日',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ref.watch(recurrenceRuleProvider(ruleId));
    final label = rule.maybeWhen(
      data: (r) {
        if (r == null) return '重複';
        if (r.byWeekday != null && r.byWeekday!.isNotEmpty) {
          final days = r.byWeekday!
              .split(',')
              .map((d) => _dayMap[d.trim()] ?? '')
              .where((s) => s.isNotEmpty)
              .join('');
          return '週$days';
        }
        return switch (r.freq) {
          'DAILY'   => '每天',
          'WEEKLY'  => '每週',
          'MONTHLY' => '每月',
          'YEARLY'  => '每年',
          _ => '重複',
        };
      },
      orElse: () => '重複',
    );
    return _SmallChip(icon: Icons.repeat, label: label);
  }
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

// ── Occurrence history bottom sheet ──────────────────────────────────────────

class _OccurrenceHistorySheet extends ConsumerWidget {
  const _OccurrenceHistorySheet({required this.reminder});
  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occAsync = ref.watch(recentOccurrencesProvider(reminder.id));
    final theme = Theme.of(context);
    final now = DateTime.now().millisecondsSinceEpoch;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.title, style: theme.textTheme.titleMedium),
                  if (reminder.note != null && reminder.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        reminder.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Occurrence list
          Expanded(
            child: occAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('錯誤：$e')),
              data: (occs) {
                if (occs.isEmpty) {
                  return Center(
                    child: Text(
                      '尚無記錄',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: occs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 56),
                  itemBuilder: (_, i) => _OccurrenceRow(
                    occ: occs[i],
                    isPast: occs[i].scheduledAt < now,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OccurrenceRow extends StatelessWidget {
  const _OccurrenceRow({required this.occ, required this.isPast});
  final Occurrence occ;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dt = DateTime.fromMillisecondsSinceEpoch(occ.scheduledAt);
    final timeStr =
        '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}'
        '  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    final (icon, color, label) = switch (occ.state) {
      'completed' => (Icons.check_circle_outline, Colors.green, '已完成'),
      'missed'    => (Icons.cancel_outlined, Colors.red.shade400, '已漏響'),
      _           => isPast
          ? (Icons.error_outline, Colors.orange, '待確認')
          : (Icons.schedule_outlined, theme.colorScheme.onSurfaceVariant, '待響鈴'),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(timeStr, style: theme.textTheme.bodyMedium),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
