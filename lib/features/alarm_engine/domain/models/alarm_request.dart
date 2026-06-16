class AlarmRequest {
  const AlarmRequest({
    required this.alarmId,
    required this.reminderId,
    required this.title,
    required this.triggerAt,
    this.snoozeMinutes = 5,
    this.maxSnoozeCount = 3,
  });

  final int alarmId;
  final String reminderId;
  final String title;
  final DateTime triggerAt;
  final int snoozeMinutes;
  final int maxSnoozeCount;

  Map<String, dynamic> toMap() => {
        'alarmId': alarmId,
        'reminderId': reminderId,
        'title': title,
        'triggerAtMs': triggerAt.millisecondsSinceEpoch,
        'snoozeMinutes': snoozeMinutes,
        'maxSnoozeCount': maxSnoozeCount,
      };
}
