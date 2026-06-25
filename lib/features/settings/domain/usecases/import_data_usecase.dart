import 'dart:convert';

import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/shared/database/daos/alarm_config_dao.dart';
import 'package:count_to_three/shared/database/daos/recurrence_rule_dao.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';
import 'package:drift/drift.dart';

class ImportResult {
  const ImportResult({
    required this.imported,
    required this.skipped,
    required this.updatedIds,
  });
  final int imported;
  final int skipped;
  // IDs of reminders whose data was actually changed (not skipped due to LWW).
  final List<String> updatedIds;
}

class ImportDataUseCase {
  const ImportDataUseCase({
    required this.reminderDao,
    required this.recurrenceRuleDao,
    required this.alarmConfigDao,
  });

  final ReminderDao reminderDao;
  final RecurrenceRuleDao recurrenceRuleDao;
  final AlarmConfigDao alarmConfigDao;

  Future<ImportResult> call(String jsonString) async {
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('無法解析 JSON');
    }

    if (payload['version'] != 1) {
      throw const FormatException('不支援的備份版本');
    }

    final rawList = payload['reminders'];
    if (rawList == null || rawList is! List) {
      throw const FormatException('備份格式不正確');
    }

    int imported = 0;
    int skipped = 0;
    final updatedIds = <String>[];
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (final raw in rawList) {
      try {
        final entry = raw as Map<String, dynamic>;
        final id = entry['id'] as String;

        // Merge by updatedAt: skip if local is newer
        final existing = await reminderDao.findById(id);
        final exportedUpdatedAt = (entry['updatedAt'] as num?)?.toInt() ?? 0;
        if (existing != null && existing.updatedAt >= exportedUpdatedAt) {
          skipped++;
          continue;
        }

        // 1. Upsert recurrence rule
        String? ruleId;
        final ruleMap = entry['recurrenceRule'] as Map<String, dynamic>?;
        if (ruleMap != null) {
          ruleId = 'rrule_$id';
          await recurrenceRuleDao.upsert(RecurrenceRulesCompanion(
            id: Value(ruleId),
            rruleString: Value(ruleMap['rruleString'] as String? ?? ''),
            freq: Value(ruleMap['freq'] as String? ?? 'DAILY'),
            interval: Value((ruleMap['interval'] as num?)?.toInt() ?? 1),
            byWeekday: Value(ruleMap['byWeekday'] as String?),
            until: Value((ruleMap['until'] as num?)?.toInt()),
            count: Value((ruleMap['count'] as num?)?.toInt()),
          ));
        }

        // 2. Upsert reminder
        await reminderDao.upsert(RemindersCompanion(
          id: Value(id),
          title: Value(entry['title'] as String? ?? ''),
          note: Value(entry['note'] as String?),
          type: Value(entry['type'] as String? ?? 'alarm'),
          alertLevel: Value(entry['alertLevel'] as String? ?? 'NOTIFICATION'),
          startAt: Value((entry['startAt'] as num?)?.toInt() ?? nowMs),
          timezone: Value(entry['timezone'] as String? ?? 'Asia/Taipei'),
          isEnabled: Value(entry['isEnabled'] as bool? ?? true),
          isDeleted: Value(entry['isDeleted'] as bool? ?? false),
          createdAt: Value((entry['createdAt'] as num?)?.toInt() ?? nowMs),
          updatedAt: Value(exportedUpdatedAt > 0 ? exportedUpdatedAt : nowMs),
          recurrenceRuleId: Value(ruleId),
          color: Value(entry['color'] as String?),
          syncStatus: const Value('pending'),
        ));

        // 3. Upsert alarm config
        final cfgMap = entry['alarmConfig'] as Map<String, dynamic>?;
        if (cfgMap != null) {
          await alarmConfigDao.upsert(AlarmConfigsCompanion(
            reminderId: Value(id),
            snoozeMinutes: Value((cfgMap['snoozeMinutes'] as num?)?.toInt() ?? 5),
            snoozeMaxCount: Value((cfgMap['snoozeMaxCount'] as num?)?.toInt() ?? 3),
            preNotifyMinutes: Value((cfgMap['preNotifyMinutes'] as num?)?.toInt()),
            volumeRamp: Value(cfgMap['volumeRamp'] as bool? ?? false),
            vibrate: Value(cfgMap['vibrate'] as bool? ?? true),
            ringtoneUri: Value(cfgMap['ringtoneUri'] as String?),
          ));
        }

        updatedIds.add(id);
        imported++;
      } catch (_) {
        skipped++;
      }
    }

    return ImportResult(imported: imported, skipped: skipped, updatedIds: updatedIds);
  }
}
