import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

const _appGroup = 'group.com.example.countToThree';
const _iOSWidgetName = 'CountWidget';
const _androidWidgetName = 'AlarmWidget';

/// Writes the next upcoming alarm to home_widget storage and requests a widget refresh.
/// Call this whenever the reminder list changes.
Future<void> updateHomeWidget(List<Reminder> reminders) async {
  await HomeWidget.setAppGroupId(_appGroup);

  final now = DateTime.now().millisecondsSinceEpoch;
  final next = reminders
      .where((r) => r.startAt > now && !r.isDeleted)
      .fold<Reminder?>(null, (best, r) => best == null || r.startAt < best.startAt ? r : best);

  if (next != null) {
    final t = DateTime.fromMillisecondsSinceEpoch(next.startAt);
    await Future.wait([
      HomeWidget.saveWidgetData<String>('nextAlarmTitle', next.title),
      HomeWidget.saveWidgetData<String>(
          'nextAlarmTime',
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'),
      HomeWidget.saveWidgetData<int>('nextAlarmMs', next.startAt),
    ]);
  } else {
    await Future.wait([
      HomeWidget.saveWidgetData<String?>('nextAlarmTitle', null),
      HomeWidget.saveWidgetData<String?>('nextAlarmTime', null),
      HomeWidget.saveWidgetData<int?>('nextAlarmMs', null),
    ]);
  }

  await HomeWidget.updateWidget(
    iOSName: _iOSWidgetName,
    androidName: _androidWidgetName,
  );
}

/// Provider that auto-updates the home widget whenever the reminder list changes.
final homeWidgetSyncProvider = StreamProvider<void>((ref) async* {
  await HomeWidget.setAppGroupId(_appGroup);
  final stream = ref.watch(appDatabaseProvider).reminderDao.watchAll();
  await for (final reminders in stream) {
    await updateHomeWidget(reminders);
    yield null;
  }
});
