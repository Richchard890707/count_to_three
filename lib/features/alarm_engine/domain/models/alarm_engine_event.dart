enum AlarmEventType { fired, snoozed, dismissed }

class AlarmEngineEvent {
  const AlarmEngineEvent({
    required this.type,
    required this.alarmId,
    required this.reminderId,
    this.title,
    this.snoozeCount,
    this.auto = false,
  });

  final AlarmEventType type;
  final int alarmId;
  final String reminderId;
  final String? title;
  final int? snoozeCount;
  final bool auto;

  factory AlarmEngineEvent.fromMap(Map<dynamic, dynamic> map) {
    final type = switch (map['type'] as String) {
      'fired' => AlarmEventType.fired,
      'snoozed' => AlarmEventType.snoozed,
      _ => AlarmEventType.dismissed,
    };
    return AlarmEngineEvent(
      type: type,
      alarmId: (map['alarmId'] as num).toInt(),
      reminderId: map['reminderId'] as String,
      title: map['title'] as String?,
      snoozeCount: (map['snoozeCount'] as num?)?.toInt(),
      auto: (map['auto'] as bool?) ?? false,
    );
  }

  @override
  String toString() => 'AlarmEngineEvent($type, alarmId=$alarmId)';
}
