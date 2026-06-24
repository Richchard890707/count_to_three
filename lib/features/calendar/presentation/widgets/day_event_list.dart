import 'dart:io';

import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/features/calendar/domain/models/calendar_event.dart';
import 'package:count_to_three/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayEventList extends ConsumerWidget {
  const DayEventList({super.key, required this.day, required this.events});

  final DateTime day;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          '${day.month} 月 ${day.day} 日\n沒有提醒',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (_, i) {
        final e = events[i];
        final t = e.occurrenceTime;
        final timeStr =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        final levelColor = _levelColor(e.reminder.alertLevel);
        final accentColor = e.reminder.color != null
            ? Color(int.parse('FF${e.reminder.color!.substring(1)}', radix: 16))
            : levelColor;
        final icon = _typeIcon(e.reminder.type);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: accentColor.withAlpha(38),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          title: Text(e.reminder.title),
          subtitle: Text(timeStr),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _canComplete(e)
                  ? TextButton(
                      onPressed: () => _complete(context, ref, e),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('✓ 完成'),
                    )
                  : _stateIcon(e),
              const SizedBox(width: 4),
              if (_levelChip(e.reminder.alertLevel, context) != null)
                _levelChip(e.reminder.alertLevel, context)!,
            ],
          ),
        );
      },
    );
  }

  bool _canComplete(CalendarEvent e) =>
      e.occurrenceState == 'pending' ||
      (e.occurrenceState == null && e.isPast);

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    CalendarEvent e,
  ) async {
    final scheduledMs = e.occurrenceTime.millisecondsSinceEpoch;
    final occurrenceId = '${e.reminder.id}_$scheduledMs';
    final db = ref.read(appDatabaseProvider);

    if (e.occurrenceState == null) {
      // No DB row yet — create it directly as completed.
      await db.occurrenceDao.upsert(OccurrencesCompanion(
        id:           Value(occurrenceId),
        reminderId:   Value(e.reminder.id),
        scheduledAt:  Value(scheduledMs),
        state:        const Value('completed'),
        osScheduled:  const Value(false),
        syncStatus:   const Value('pending'),
        updatedAt:    Value(DateTime.now().millisecondsSinceEpoch),
      ));
    } else {
      await db.occurrenceDao.updateState(occurrenceId, 'completed');
    }
    await ref.read(rescheduleWindowProvider).fillForReminder(e.reminder.id);
    // Force calendar to reload so the state icon updates.
    ref.invalidate(calendarControllerProvider);
    // Keep iOS badge in sync.
    if (Platform.isIOS) {
      try {
        final now = DateTime.now();
        final todayStart =
            DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
        final count = await db.occurrenceDao
            .countByStateInRange('pending', todayStart, todayStart + 86400000);
        await const MethodChannel('app.ontime/alarm')
            .invokeMethod('badge.setCount', count);
      } catch (_) {}
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已記錄完成'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _stateIcon(CalendarEvent e) {
    if (e.isCompleted) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 18);
    }
    if (e.isMissed) {
      return const Icon(Icons.cancel, color: Colors.orange, size: 18);
    }
    if (e.isPast) {
      return const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 18);
    }
    return const SizedBox.shrink();
  }

  Color _levelColor(String level) => switch (level) {
        'ALARM' => Colors.red,
        'NOTIFICATION' => Colors.blue,
        _ => Colors.grey,
      };

  IconData _typeIcon(String type) => switch (type) {
        'todo' => Icons.check_box_outline_blank,
        'event' => Icons.event,
        _ => Icons.alarm,
      };

  Widget? _levelChip(String level, BuildContext context) {
    if (level == 'SILENT') return null;
    return Chip(
      label: Text(
        level == 'ALARM' ? '鬧鐘級' : '通知級',
        style: const TextStyle(fontSize: 11),
      ),
      backgroundColor: _levelColor(level).withAlpha(26),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
