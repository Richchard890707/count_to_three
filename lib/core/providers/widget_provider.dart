import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

const _appGroup = 'group.com.example.countToThree';
const _iOSWidgetName = 'CountWidget';
const _androidWidgetName = 'AlarmWidget';

/// Writes the next upcoming alarm (by next pending occurrence) to home_widget
/// storage and requests a widget refresh.
Future<void> updateHomeWidget(List<Reminder> reminders, AppDatabase db) async {
  await HomeWidget.setAppGroupId(_appGroup);

  final now = DateTime.now().millisecondsSinceEpoch;
  final nextMap = await db.occurrenceDao.getNextPendingScheduledAtMap();

  Reminder? bestReminder;
  int? bestMs;

  for (final r in reminders) {
    if (r.isDeleted) continue;
    // Prefer next pending occurrence; fall back to startAt for non-recurring.
    final ms = nextMap[r.id] ?? r.startAt;
    if (ms > now) {
      if (bestMs == null || ms < bestMs) {
        bestReminder = r;
        bestMs = ms;
      }
    }
  }

  if (bestReminder != null && bestMs != null) {
    final t = DateTime.fromMillisecondsSinceEpoch(bestMs);
    await Future.wait([
      HomeWidget.saveWidgetData<String>('nextAlarmTitle', bestReminder.title),
      HomeWidget.saveWidgetData<String>(
          'nextAlarmTime',
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'),
      HomeWidget.saveWidgetData<int>('nextAlarmMs', bestMs),
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
  final db = ref.watch(appDatabaseProvider);
  final stream = db.reminderDao.watchAll();
  await for (final reminders in stream) {
    await updateHomeWidget(reminders, db);
    yield null;
  }
});
