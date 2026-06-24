import 'package:count_to_three/core/providers/alarm_scheduler_provider.dart';
import 'package:count_to_three/core/providers/auth_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/core/providers/rule_engine_provider.dart';
import 'package:count_to_three/core/providers/sync_provider.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/alarm_engine_event.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/recurrence_input.dart';
import 'package:count_to_three/features/reminder/domain/models/reminder_enums.dart';
import 'package:count_to_three/features/reminder/domain/usecases/complete_todo_usecase.dart';
import 'package:count_to_three/features/reminder/domain/usecases/create_recurring_alarm_usecase.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alarm_list_controller.g.dart';

// ── Selection state model ─────────────────────────────────────────────────────

class AlarmListSelectionState {
  const AlarmListSelectionState({
    this.isActive = false,
    this.selectedIds = const {},
  });
  final bool isActive;
  final Set<String> selectedIds;
  int get count => selectedIds.length;
  bool contains(String id) => selectedIds.contains(id);

  AlarmListSelectionState copyWith({bool? isActive, Set<String>? selectedIds}) =>
      AlarmListSelectionState(
        isActive: isActive ?? this.isActive,
        selectedIds: selectedIds ?? this.selectedIds,
      );
}

// ── Selection notifier ────────────────────────────────────────────────────────

@riverpod
class AlarmListSelection extends _$AlarmListSelection {
  @override
  AlarmListSelectionState build() => const AlarmListSelectionState();

  void activate(String id) => state = AlarmListSelectionState(
        isActive: true,
        selectedIds: {id},
      );

  void toggle(String id) {
    final ids = Set<String>.from(state.selectedIds);
    if (!ids.remove(id)) ids.add(id);
    state = state.copyWith(selectedIds: ids);
  }

  void selectAll(List<String> allIds) => state = AlarmListSelectionState(
        isActive: true,
        selectedIds: Set.from(allIds),
      );

  void clear() => state = const AlarmListSelectionState();
}

// ── Sort field constants ──────────────────────────────────────────────────────

enum AlarmSortField {
  time('startAt', '時間'),
  name('title', '名稱'),
  type('type', '類型'),
  created('createdAt', '建立時間');

  const AlarmSortField(this.column, this.label);
  final String column;
  final String label;
}

// ── Filter + sort state model ─────────────────────────────────────────────────

class AlarmListFilterState {
  const AlarmListFilterState({
    this.query = '',
    this.types = const {},
    this.onlyEnabled = false,
    this.sortField = AlarmSortField.time,
    this.sortDesc = false,
  });
  final String query;
  final Set<String> types; // 'alarm' | 'event' | 'todo'
  final bool onlyEnabled;
  final AlarmSortField sortField;
  final bool sortDesc;

  bool get isActive => query.isNotEmpty || types.isNotEmpty || onlyEnabled;
  bool get isSorted => sortField != AlarmSortField.time || sortDesc;

  AlarmListFilterState copyWith({
    String? query,
    Set<String>? types,
    bool? onlyEnabled,
    AlarmSortField? sortField,
    bool? sortDesc,
  }) => AlarmListFilterState(
        query: query ?? this.query,
        types: types ?? this.types,
        onlyEnabled: onlyEnabled ?? this.onlyEnabled,
        sortField: sortField ?? this.sortField,
        sortDesc: sortDesc ?? this.sortDesc,
      );
}

// ── Filter notifier ───────────────────────────────────────────────────────────

@riverpod
class AlarmFilter extends _$AlarmFilter {
  @override
  AlarmListFilterState build() => const AlarmListFilterState();

  void setQuery(String q) => state = state.copyWith(query: q);

  void toggleType(String type) {
    final next = Set<String>.from(state.types);
    if (!next.remove(type)) next.add(type);
    state = state.copyWith(types: next);
  }

  void toggleOnlyEnabled() =>
      state = state.copyWith(onlyEnabled: !state.onlyEnabled);

  void setSort(AlarmSortField field, {bool? desc}) {
    // Tapping the same field toggles direction; tapping new field resets to asc.
    final newDesc = desc ?? (state.sortField == field ? !state.sortDesc : false);
    state = state.copyWith(sortField: field, sortDesc: newDesc);
  }

  void clear() => state = const AlarmListFilterState();
}

// ── Other shared providers ────────────────────────────────────────────────────

@riverpod
Stream<AlarmEngineEvent> alarmEvents(AlarmEventsRef ref) =>
    ref.watch(alarmSchedulerProvider).events;

@riverpod
class SelectedReminderType extends _$SelectedReminderType {
  @override
  ReminderType build() => ReminderType.alarm;
  void set(ReminderType t) => state = t;
}

@riverpod
class SelectedAlertLevel extends _$SelectedAlertLevel {
  @override
  AlertLevel build() => AlertLevel.alarm;
  void set(AlertLevel a) => state = a;
}

@riverpod
class SelectedFreq extends _$SelectedFreq {
  @override
  RecurrenceFreq build() => RecurrenceFreq.none;
  void set(RecurrenceFreq freq) => state = freq;
}

@riverpod
class AlarmListController extends _$AlarmListController {
  @override
  Stream<List<Reminder>> build() {
    final filter = ref.watch(alarmFilterProvider);
    final db     = ref.watch(appDatabaseProvider);

    final baseStream = db.reminderDao.watchFiltered(
      query: filter.query,
      types: filter.types,
      onlyEnabled: filter.onlyEnabled,
      // For time-sort we re-sort in Dart using next pending occurrence;
      // DB only needs to supply a stable secondary order (startAt asc).
      sortColumn: filter.sortField == AlarmSortField.time
          ? 'startAt'
          : filter.sortField.column,
      sortDesc: filter.sortField == AlarmSortField.time
          ? false
          : filter.sortDesc,
    );

    if (filter.sortField != AlarmSortField.time) return baseStream;

    // Re-sort each emission by the earliest pending occurrence time.
    return baseStream.asyncMap((reminders) async {
      final nextMap = await db.occurrenceDao.getNextPendingScheduledAtMap();
      final sorted = List<Reminder>.from(reminders)
        ..sort((a, b) {
          final aMs = nextMap[a.id] ?? a.startAt;
          final bMs = nextMap[b.id] ?? b.startAt;
          return filter.sortDesc
              ? bMs.compareTo(aMs)
              : aMs.compareTo(bMs);
        });
      return sorted;
    });
  }

  Future<String> createReminder(
    ReminderType type,
    AlertLevel alertLevel,
    RecurrenceFreq freq, {
    String? title,
    String? note,
    DateTime? triggerAt,
    List<String>? byWeekday,
    int snoozeMinutes = 5,
    int maxSnoozeCount = 3,
    int? preNotifyMinutes,
    bool volumeRamp = false,
    bool vibrate = true,
    String? ringtoneUri,
    String? color,
    DateTime? untilDate,
    int? repeatCount,
    int interval = 1,
  }) async {
    final trigger = triggerAt ?? DateTime.now().add(const Duration(seconds: 30));
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(currentUserProvider)?.uid;
    final effectiveTitle = title?.isNotEmpty == true
        ? title!
        : switch (type) {
            ReminderType.alarm => freq != RecurrenceFreq.none
                ? '重複鬧鐘（${freq.label}）'
                : '鬧鐘 ${_fmt(trigger)}',
            ReminderType.event => freq != RecurrenceFreq.none
                ? '重複事件（${freq.label}）'
                : '事件 ${_fmt(trigger)}',
            ReminderType.todo => freq != RecurrenceFreq.none
                ? '重複待辦（${freq.label}）'
                : '待辦 ${_fmt(trigger)}',
          };
    final reminderId = await CreateRecurringAlarmUseCase(
      reminderDao: db.reminderDao,
      recurrenceRuleDao: db.recurrenceRuleDao,
      ruleEngine: ref.read(ruleEngineProvider),
      rescheduleWindow: ref.read(rescheduleWindowProvider),
    )(
      title: effectiveTitle,
      note: note,
      color: color,
      triggerAt: trigger,
      userId: userId,
      recurrence: RecurrenceInput(
        freq: freq,
        interval: interval,
        byWeekday: (freq == RecurrenceFreq.weekly && byWeekday?.isNotEmpty == true)
            ? byWeekday
            : null,
        until: untilDate,
        count: repeatCount,
      ),
      alertLevel: alertLevel.value,
      type: type.value,
    );
    if (alertLevel == AlertLevel.alarm) {
      await db.alarmConfigDao.upsert(AlarmConfigsCompanion(
        reminderId: Value(reminderId),
        snoozeMinutes: Value(snoozeMinutes),
        snoozeMaxCount: Value(maxSnoozeCount),
        preNotifyMinutes: Value(preNotifyMinutes),
        volumeRamp: Value(volumeRamp),
        vibrate: Value(vibrate),
        ringtoneUri: Value(ringtoneUri),
      ));
    }
    // Fire-and-forget outbox flush; failures keep syncStatus='pending' for retry.
    if (userId != null) ref.read(syncServiceProvider).pushPending();
    return reminderId;
  }

  String _fmt(DateTime t) =>
      '${t.month}/${t.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> updateReminder(
    String reminderId,
    ReminderType type,
    AlertLevel alertLevel,
    RecurrenceFreq freq, {
    required String title,
    String? note,
    required DateTime triggerAt,
    List<String>? byWeekday,
    int snoozeMinutes = 5,
    int maxSnoozeCount = 3,
    int? preNotifyMinutes,
    bool volumeRamp = false,
    bool vibrate = true,
    String? ringtoneUri,
    String? color,
    DateTime? untilDate,
    int? repeatCount,
    int interval = 1,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Cancel OS-scheduled occurrences and purge all pending rows.
    // We delete ALL pending (past + future) so a stale fired-but-not-dismissed
    // occurrence doesn't shadow the newly rescheduled time in the UI.
    final occs = await db.occurrenceDao.getFuturePendingByReminder(reminderId, now);
    for (final occ in occs) {
      final alarmId = occ.scheduledAt ~/ 1000 % 1000000;
      await ref.read(alarmSchedulerProvider).cancelAlarm(alarmId);
      await ref.read(notificationSchedulerProvider).cancelNotification(alarmId);
      await ref.read(notificationSchedulerProvider).cancelNotification(alarmId + 1000000);
    }
    await db.occurrenceDao.deleteAllPendingByReminder(reminderId);

    // Handle recurrence rule
    final existing = await db.reminderDao.findById(reminderId);
    final userId = ref.read(currentUserProvider)?.uid;
    String? ruleId = existing?.recurrenceRuleId;

    if (freq == RecurrenceFreq.none) {
      ruleId = null;
    } else {
      final effectiveWeekday = (freq == RecurrenceFreq.weekly && byWeekday?.isNotEmpty == true)
          ? byWeekday
          : null;
      final compiled = ref.read(ruleEngineProvider).compile(
        RecurrenceInput(freq: freq, interval: interval, byWeekday: effectiveWeekday, until: untilDate, count: repeatCount),
      )!;
      ruleId ??= 'rrule_$reminderId';
      await db.recurrenceRuleDao.upsert(RecurrenceRulesCompanion(
        id: Value(ruleId),
        rruleString: Value(compiled.rruleString),
        freq: Value(compiled.freq),
        interval: Value(compiled.interval),
        byWeekday: Value(effectiveWeekday?.join(',')),
        until: Value(untilDate?.millisecondsSinceEpoch),
        count: Value(repeatCount),
      ));
    }

    await db.reminderDao.upsert(RemindersCompanion(
      id: Value(reminderId),
      title: Value(title),
      note: Value(note?.isNotEmpty == true ? note : null),
      startAt: Value(triggerAt.millisecondsSinceEpoch),
      alertLevel: Value(alertLevel.value),
      type: Value(type.value),
      recurrenceRuleId: Value(ruleId),
      color: Value(color),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
      syncStatus: const Value('pending'),
      userId: Value(userId),
    ));

    if (alertLevel == AlertLevel.alarm) {
      await db.alarmConfigDao.upsert(AlarmConfigsCompanion(
        reminderId: Value(reminderId),
        snoozeMinutes: Value(snoozeMinutes),
        snoozeMaxCount: Value(maxSnoozeCount),
        preNotifyMinutes: Value(preNotifyMinutes),
        volumeRamp: Value(volumeRamp),
        vibrate: Value(vibrate),
        ringtoneUri: Value(ringtoneUri),
      ));
    } else {
      await db.alarmConfigDao.deleteByReminder(reminderId);
    }

    await ref.read(rescheduleWindowProvider).fillForReminder(reminderId);
    if (userId != null) ref.read(syncServiceProvider).pushPending();
  }

  Future<void> toggleEnabled(String reminderId, {required bool enabled}) async {
    final db = ref.read(appDatabaseProvider);
    await db.reminderDao.setEnabled(reminderId, enabled);

    if (!enabled) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final occs = await db.occurrenceDao.getFuturePendingByReminder(reminderId, now);
      for (final occ in occs) {
        final alarmId = occ.scheduledAt ~/ 1000 % 1000000;
        await ref.read(alarmSchedulerProvider).cancelAlarm(alarmId);
        await ref.read(notificationSchedulerProvider).cancelNotification(alarmId);
        await ref.read(notificationSchedulerProvider).cancelNotification(alarmId + 1000000);
      }
      // Remove occurrence rows so re-enabling starts from a clean window
      await db.occurrenceDao.deleteFutureByReminder(reminderId);
    } else {
      await ref.read(rescheduleWindowProvider).fillForReminder(reminderId);
    }

    final userId = ref.read(currentUserProvider)?.uid;
    if (userId != null) ref.read(syncServiceProvider).pushPending();
  }

  Future<void> deleteReminder(String reminderId) async {
    final db = ref.read(appDatabaseProvider);
    await CompleteTodoUseCase(
      reminderDao: db.reminderDao,
      occurrenceDao: db.occurrenceDao,
      alarmConfigDao: db.alarmConfigDao,
      alarmScheduler: ref.read(alarmSchedulerProvider),
      notificationScheduler: ref.read(notificationSchedulerProvider),
    )(reminderId);
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId != null) ref.read(syncServiceProvider).pushPending();
  }

  Future<void> completeTodo(String reminderId) async {
    final db = ref.read(appDatabaseProvider);
    await CompleteTodoUseCase(
      reminderDao: db.reminderDao,
      occurrenceDao: db.occurrenceDao,
      alarmConfigDao: db.alarmConfigDao,
      alarmScheduler: ref.read(alarmSchedulerProvider),
      notificationScheduler: ref.read(notificationSchedulerProvider),
    )(reminderId);
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId != null) ref.read(syncServiceProvider).pushPending();
  }

  Future<void> bulkDelete(Set<String> ids) async {
    for (final id in ids) {
      await deleteReminder(id);
    }
  }

  Future<void> bulkSetEnabled(Set<String> ids, {required bool enabled}) async {
    for (final id in ids) {
      await toggleEnabled(id, enabled: enabled);
    }
  }

  /// Creates a copy of [reminderId] with "(複製)" appended to the title.
  /// Returns the new reminder's ID.
  Future<String> duplicateReminder(String reminderId) async {
    final db = ref.read(appDatabaseProvider);
    final original = await db.reminderDao.findById(reminderId);
    if (original == null) throw StateError('Reminder $reminderId not found');

    final config = await db.alarmConfigDao.findByReminder(reminderId);
    final rule = original.recurrenceRuleId != null
        ? await db.recurrenceRuleDao.findById(original.recurrenceRuleId!)
        : null;

    final freq = rule != null
        ? _freqFromString(rule.freq)
        : RecurrenceFreq.none;
    final byWeekday = rule?.byWeekday?.split(',').where((s) => s.isNotEmpty).toList();
    final untilDate = rule?.until != null
        ? DateTime.fromMillisecondsSinceEpoch(rule!.until!)
        : null;
    final repeatCount = rule?.count;

    final alertLevel = AlertLevel.values.firstWhere(
      (a) => a.value == original.alertLevel,
      orElse: () => AlertLevel.alarm,
    );
    final type = ReminderType.values.firstWhere(
      (t) => t.value == original.type,
      orElse: () => ReminderType.alarm,
    );

    return createReminder(
      type,
      alertLevel,
      freq,
      title: '${original.title} (複製)',
      note: original.note,
      triggerAt: DateTime.fromMillisecondsSinceEpoch(original.startAt),
      byWeekday: byWeekday,
      snoozeMinutes: config?.snoozeMinutes ?? 5,
      maxSnoozeCount: config?.snoozeMaxCount ?? 3,
      preNotifyMinutes: config?.preNotifyMinutes,
      volumeRamp: config?.volumeRamp ?? false,
      vibrate: config?.vibrate ?? true,
      ringtoneUri: config?.ringtoneUri,
      color: original.color,
      untilDate: untilDate,
      repeatCount: repeatCount,
      interval: rule?.interval ?? 1,
    );
  }

  RecurrenceFreq _freqFromString(String freq) => switch (freq.toUpperCase()) {
        'DAILY' => RecurrenceFreq.daily,
        'WEEKLY' => RecurrenceFreq.weekly,
        'MONTHLY' => RecurrenceFreq.monthly,
        'YEARLY' => RecurrenceFreq.yearly,
        _ => RecurrenceFreq.none,
      };
}
