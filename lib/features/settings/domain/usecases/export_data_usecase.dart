import 'dart:convert';

import 'package:count_to_three/shared/database/daos/alarm_config_dao.dart';
import 'package:count_to_three/shared/database/daos/occurrence_dao.dart';
import 'package:count_to_three/shared/database/daos/recurrence_rule_dao.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';

class ExportDataUseCase {
  const ExportDataUseCase({
    required this.reminderDao,
    required this.recurrenceRuleDao,
    required this.alarmConfigDao,
    required this.occurrenceDao,
  });

  final ReminderDao reminderDao;
  final RecurrenceRuleDao recurrenceRuleDao;
  final AlarmConfigDao alarmConfigDao;
  final OccurrenceDao occurrenceDao;

  Future<String> call() async {
    final reminders = await reminderDao.getAll();
    final reminderList = <Map<String, dynamic>>[];

    for (final r in reminders) {
      final Map<String, dynamic> entry = {
        'id': r.id,
        'title': r.title,
        'note': r.note,
        'type': r.type,
        'alertLevel': r.alertLevel,
        'startAt': r.startAt,
        'timezone': r.timezone,
        'isEnabled': r.isEnabled,
        'isDeleted': r.isDeleted,
        'createdAt': r.createdAt,
        'updatedAt': r.updatedAt,
        'color': r.color,
      };

      if (r.recurrenceRuleId != null) {
        final rule = await recurrenceRuleDao.findById(r.recurrenceRuleId!);
        if (rule != null) {
          entry['recurrenceRule'] = {
            'rruleString': rule.rruleString,
            'freq': rule.freq,
            'interval': rule.interval,
            'byWeekday': rule.byWeekday,
            'until': rule.until,
            'count': rule.count,
          };
        }
      }

      final config = await alarmConfigDao.findByReminder(r.id);
      if (config != null) {
        entry['alarmConfig'] = {
          'snoozeMinutes': config.snoozeMinutes,
          'snoozeMaxCount': config.snoozeMaxCount,
          'preNotifyMinutes': config.preNotifyMinutes,
          'volumeRamp': config.volumeRamp,
          'vibrate': config.vibrate,
          'ringtoneUri': config.ringtoneUri,
        };
      }

      reminderList.add(entry);
    }

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'reminderCount': reminderList.length,
      'reminders': reminderList,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
