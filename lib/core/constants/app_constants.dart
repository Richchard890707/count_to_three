abstract final class AppConstants {
  static const dbName = 'count_to_three.db';

  // MethodChannel / EventChannel names (M2)
  static const alarmMethodChannel = 'app.ontime/alarm';
  static const alarmEventChannel = 'app.ontime/alarm_events';

  // Rolling window scheduling limits
  static const alarmWindowSizeAndroid = 100;
  static const alarmWindowSizeIos = 50;
}
