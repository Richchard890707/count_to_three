enum AlarmEventType { fired, snoozed, dismissed, notifTapped }

class AlarmEngineEvent {
  const AlarmEngineEvent({
    required this.type,
    required this.alarmId,
    required this.reminderId,
    this.title,
    this.scheduledAtMs,
    this.snoozeCount,
    this.maxSnoozeCount,
    this.auto = false,
  });

  final AlarmEventType type;
  final int alarmId;
  final String reminderId;
  final String? title;
  final int? scheduledAtMs;
  final int? snoozeCount;
  final int? maxSnoozeCount;
  final bool auto;

  factory AlarmEngineEvent.fromMap(Map<dynamic, dynamic> map) {
    final type = switch (map['type'] as String) {
      'fired' => AlarmEventType.fired,
      'snoozed' => AlarmEventType.snoozed,
      'notif_tapped' => AlarmEventType.notifTapped,
      _ => AlarmEventType.dismissed,
    };
    return AlarmEngineEvent(
      type: type,
      alarmId: (map['alarmId'] as num?)?.toInt() ?? 0,
      reminderId: map['reminderId'] as String,
      title: map['title'] as String?,
      scheduledAtMs: (map['scheduledAtMs'] as num?)?.toInt(),
      snoozeCount: (map['snoozeCount'] as num?)?.toInt(),
      maxSnoozeCount: (map['maxSnoozeCount'] as num?)?.toInt(),
      auto: (map['auto'] as bool?) ?? false,
    );
  }

  @override
  String toString() => 'AlarmEngineEvent($type, alarmId=$alarmId)';
}
