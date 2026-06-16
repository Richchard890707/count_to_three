enum ReminderType {
  alarm,
  event,
  todo;

  String get label => switch (this) {
        alarm => '鬧鐘',
        event => '行事曆事件',
        todo => '待辦',
      };

  String get value => name; // 'alarm' | 'event' | 'todo'
}

enum AlertLevel {
  alarm,
  notification,
  silent;

  String get label => switch (this) {
        alarm => '鬧鐘級',
        notification => '通知級',
        silent => '靜默',
      };

  // Matches the DB value stored in Reminders.alertLevel
  String get value => name.toUpperCase(); // 'ALARM' | 'NOTIFICATION' | 'SILENT'
}
