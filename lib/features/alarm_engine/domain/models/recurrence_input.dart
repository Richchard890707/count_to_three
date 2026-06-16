enum RecurrenceFreq {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  String get label => switch (this) {
        none => '不重複',
        daily => '每天',
        weekly => '每週',
        monthly => '每月',
        yearly => '每年',
      };
}

class RecurrenceInput {
  const RecurrenceInput({
    this.freq = RecurrenceFreq.none,
    this.interval = 1,
    this.byWeekday,   // ["MO","TU","WE","TH","FR","SA","SU"]
    this.until,
    this.count,
  });

  final RecurrenceFreq freq;
  final int interval;
  final List<String>? byWeekday;
  final DateTime? until;
  final int? count;

  static const none = RecurrenceInput();
}