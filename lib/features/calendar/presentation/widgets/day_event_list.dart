import 'package:count_to_three/features/calendar/domain/models/calendar_event.dart';
import 'package:flutter/material.dart';

class DayEventList extends StatelessWidget {
  const DayEventList({super.key, required this.day, required this.events});

  final DateTime day;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
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
        final color = _levelColor(e.reminder.alertLevel);
        final icon = _typeIcon(e.reminder.type);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withAlpha(38),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(e.reminder.title),
          subtitle: Text(timeStr),
          trailing: _levelChip(e.reminder.alertLevel, context),
        );
      },
    );
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
      backgroundColor:
          _levelColor(level).withAlpha(26),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
