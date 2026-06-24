import 'dart:io';

import 'package:count_to_three/app/theme/app_colors.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/recurrence_input.dart';
import 'package:count_to_three/features/reminder/domain/models/reminder_enums.dart';
import 'package:count_to_three/features/reminder/presentation/controllers/alarm_list_controller.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

enum _EditAction { duplicate, share }

class AlarmEditScreen extends ConsumerStatefulWidget {
  const AlarmEditScreen({super.key, this.initialDate, this.reminder});

  /// Pre-fills the date (e.g. when launched from calendar tap).
  final DateTime? initialDate;

  /// When non-null, puts the screen in edit mode (pre-fills all fields).
  final Reminder? reminder;

  @override
  ConsumerState<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends ConsumerState<AlarmEditScreen> {
  late DateTime _triggerAt;
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  ReminderType _type = ReminderType.alarm;
  AlertLevel _alertLevel = AlertLevel.alarm;
  RecurrenceFreq _freq = RecurrenceFreq.none;
  Set<String> _byWeekday = {};
  int _snoozeMinutes = 5;
  int _maxSnoozeCount = 3;
  int? _preNotifyMinutes;
  bool _volumeRamp = false;
  bool _vibrate = true;
  String? _ringtoneUri;
  String? _ringtoneName;
  String? _color;
  bool _isTesting = false;
  DateTime? _untilDate;
  int? _repeatCount;
  int _interval = 1;
  bool _saving = false;

  static const _alarmChannel = MethodChannel('app.ontime/alarm');

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    if (r != null) {
      _triggerAt = DateTime.fromMillisecondsSinceEpoch(r.startAt);
      _titleController.text = r.title;
      _noteController.text = r.note ?? '';
      _type = ReminderType.values.firstWhere(
        (t) => t.value == r.type,
        orElse: () => ReminderType.alarm,
      );
      _alertLevel = AlertLevel.values.firstWhere(
        (a) => a.value == r.alertLevel,
        orElse: () => AlertLevel.alarm,
      );
      // Fetch RecurrenceRule and AlarmConfig async to reconstruct all edit fields
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final db = ref.read(appDatabaseProvider);
        final futures = await Future.wait([
          if (r.recurrenceRuleId != null)
            db.recurrenceRuleDao.findById(r.recurrenceRuleId!) as Future
          else
            Future.value(null),
          db.alarmConfigDao.findByReminder(r.id),
        ]);
        if (!mounted) return;
        final rule = futures[0] as RecurrenceRule?;
        final config = futures[1] as AlarmConfig?;
        setState(() {
          if (rule != null) {
            _freq = _freqFromString(rule.freq);
            if (rule.byWeekday != null && rule.byWeekday!.isNotEmpty) {
              _byWeekday = Set<String>.from(
                rule.byWeekday!.split(',').map((s) => s.trim()),
              );
            }
            if (rule.until != null) {
              _untilDate = DateTime.fromMillisecondsSinceEpoch(rule.until!);
            }
            _repeatCount = rule.count;
            _interval = rule.interval;
          }
          if (config != null) {
            _snoozeMinutes = config.snoozeMinutes;
            _maxSnoozeCount = config.snoozeMaxCount;
            _preNotifyMinutes = config.preNotifyMinutes;
            _volumeRamp = config.volumeRamp;
            _vibrate = config.vibrate;
            _ringtoneUri = config.ringtoneUri;
          }
          _color = r.color;
        });
        if (mounted && Platform.isAndroid && _ringtoneUri != null) {
          final name = await _alarmChannel
              .invokeMethod<String>('alarm.getRingtoneName', _ringtoneUri)
              .catchError((_) => null);
          if (mounted) setState(() => _ringtoneName = name);
        }
      });
    } else {
      final base = widget.initialDate ?? DateTime.now();
      final now = DateTime.now();
      final nextHour = now.add(const Duration(hours: 1));
      _triggerAt = DateTime(
        base.year,
        base.month,
        base.day,
        widget.initialDate != null ? 9 : nextHour.hour,
        0,
      );
    }
  }

  @override
  void dispose() {
    _alarmChannel.invokeMethod('alarm.stopTestRing').ignore();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _onEditAction(_EditAction action) async {
    switch (action) {
      case _EditAction.duplicate:
        final newId = await ref
            .read(alarmListControllerProvider.notifier)
            .duplicateReminder(widget.reminder!.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已複製提醒')),
        );
        // Replace this edit screen with the new duplicate's edit screen.
        final db = ref.read(appDatabaseProvider);
        final copy = await db.reminderDao.findById(newId);
        if (!mounted || copy == null) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AlarmEditScreen(reminder: copy),
          ),
        );
      case _EditAction.share:
        await Share.share(_shareText());
    }
  }

  String _shareText() {
    final h = _triggerAt.hour.toString().padLeft(2, '0');
    final m = _triggerAt.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m';
    final dateStr = '${_triggerAt.month}/${_triggerAt.day}';
    final typeLabel = switch (_type) {
      ReminderType.alarm => '鬧鐘',
      ReminderType.event => '事件',
      ReminderType.todo  => '待辦',
    };
    final repeatLabel = _freq == RecurrenceFreq.none
        ? '不重複（$dateStr）'
        : _freq.label;
    final note = _noteController.text.trim();
    final buf = StringBuffer();
    buf.writeln('[Count to Three 提醒]');
    buf.writeln('${_titleController.text.trim()}');
    buf.writeln('時間：$timeStr');
    buf.writeln('類型：$typeLabel  重複：$repeatLabel');
    if (note.isNotEmpty) buf.writeln('備注：$note');
    return buf.toString().trimRight();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_triggerAt),
      barrierDismissible: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _triggerAt = DateTime(
          _triggerAt.year,
          _triggerAt.month,
          _triggerAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _triggerAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      barrierDismissible: false,
    );
    if (picked != null) {
      setState(() {
        _triggerAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _triggerAt.hour,
          _triggerAt.minute,
        );
      });
    }
  }

  Future<void> _pickUntilDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _untilDate ?? _triggerAt.add(const Duration(days: 30)),
      firstDate: _triggerAt,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() { _untilDate = picked; _repeatCount = null; });
  }

  Future<void> _testRing() async {
    if (_isTesting) {
      await _alarmChannel.invokeMethod('alarm.stopTestRing');
      if (mounted) setState(() => _isTesting = false);
      return;
    }
    setState(() => _isTesting = true);
    await _alarmChannel.invokeMethod('alarm.testRing', {
      'ringtoneUri': _ringtoneUri,
      'volumeRamp': _volumeRamp,
      'vibrate': _vibrate,
    });
    // ringtone plays once and auto-stops; reset state after a reasonable window
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isTesting) setState(() => _isTesting = false);
    });
  }

  Future<void> _pickRingtone() async {
    List<dynamic> raw;
    try {
      raw = await _alarmChannel.invokeMethod('alarm.getRingtones') as List<dynamic>;
    } catch (_) {
      return;
    }
    final ringtones = raw.cast<Map<Object?, Object?>>().map((m) => (
          title: m['title'] as String,
          uri: m['uri'] as String,
        )).toList();
    if (!mounted) return;
    final result = await showDialog<({String title, String uri})>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('選擇鈴聲'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('預設鈴聲'),
          ),
          for (final r in ringtones)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, r),
              child: Text(r.title),
            ),
        ],
      ),
    );
    setState(() {
      _ringtoneUri = result?.uri;
      _ringtoneName = result?.title;
    });
  }

  Future<void> _save() async {
    final rawTitle = _titleController.text.trim();
    setState(() => _saving = true);
    try {
      final r = widget.reminder;
      final weekdays = _freq == RecurrenceFreq.weekly && _byWeekday.isNotEmpty
          ? _byWeekday.toList()
          : null;
      final note = _noteController.text.trim();
      // If no title entered, generate a default based on type + time.
      final title = rawTitle.isNotEmpty
          ? rawTitle
          : _defaultTitle();
      if (r != null) {
        await ref.read(alarmListControllerProvider.notifier).updateReminder(
              r.id,
              _type,
              _alertLevel,
              _freq,
              title: title,
              note: note.isEmpty ? null : note,
              triggerAt: _triggerAt,
              byWeekday: weekdays,
              snoozeMinutes: _snoozeMinutes,
              maxSnoozeCount: _maxSnoozeCount,
              preNotifyMinutes: _preNotifyMinutes,
              volumeRamp: _volumeRamp,
              vibrate: _vibrate,
              ringtoneUri: _ringtoneUri,
              color: _color,
              untilDate: _freq != RecurrenceFreq.none ? _untilDate : null,
              repeatCount: _freq != RecurrenceFreq.none ? _repeatCount : null,
              interval: _interval,
            );
      } else {
        await ref.read(alarmListControllerProvider.notifier).createReminder(
              _type,
              _alertLevel,
              _freq,
              title: title,
              note: note.isEmpty ? null : note,
              triggerAt: _triggerAt,
              byWeekday: weekdays,
              snoozeMinutes: _snoozeMinutes,
              maxSnoozeCount: _maxSnoozeCount,
              preNotifyMinutes: _preNotifyMinutes,
              volumeRamp: _volumeRamp,
              vibrate: _vibrate,
              ringtoneUri: _ringtoneUri,
              color: _color,
              untilDate: _freq != RecurrenceFreq.none ? _untilDate : null,
              repeatCount: _freq != RecurrenceFreq.none ? _repeatCount : null,
              interval: _interval,
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAlarm = _type == ReminderType.alarm;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder != null ? '編輯提醒' : '新增提醒'),
        actions: [
          if (widget.reminder != null)
            PopupMenuButton<_EditAction>(
              onSelected: _onEditAction,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _EditAction.duplicate,
                  child: Row(children: [
                    Icon(Icons.copy_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('複製'),
                  ]),
                ),
                const PopupMenuItem(
                  value: _EditAction.share,
                  child: Row(children: [
                    Icon(Icons.share_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('分享'),
                  ]),
                ),
              ],
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('儲存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Time ──────────────────────────────────────────────────────────
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickTime,
            child: Center(
              child: Text(
                '${_triggerAt.hour.toString().padLeft(2, '0')}:'
                '${_triggerAt.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 88,
                  fontWeight: FontWeight.w600,
                  color: isAlarm ? AppColors.primaryRed : theme.colorScheme.primary,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Date chip ─────────────────────────────────────────────────────
          Center(
            child: ActionChip(
              avatar: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(_dateLabel(_triggerAt)),
              onPressed: _pickDate,
            ),
          ),
          const SizedBox(height: 24),

          // ── Title ─────────────────────────────────────────────────────────
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '標題',
              hintText: '為這個提醒取個名字',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // ── Note ──────────────────────────────────────────────────────────
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '備忘（選填）',
              hintText: '額外說明或備注',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            maxLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),

          // ── Color label ───────────────────────────────────────────────────
          Text('顏色標籤', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _ColorPicker(
            selected: _color,
            onSelected: (c) => setState(() => _color = c),
          ),
          const SizedBox(height: 20),

          // ── Type ──────────────────────────────────────────────────────────
          Text('類型', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _ChipRow<ReminderType>(
            values: ReminderType.values,
            selected: _type,
            labelOf: (t) => t.label,
            iconOf: (t) => switch (t) {
              ReminderType.alarm => Icons.alarm,
              ReminderType.event => Icons.event,
              ReminderType.todo => Icons.check_box_outline_blank,
            },
            onSelected: (t) {
              setState(() {
                _type = t;
                // Auto-adjust alert level to match type default
                _alertLevel = switch (t) {
                  ReminderType.alarm => AlertLevel.alarm,
                  ReminderType.event => AlertLevel.notification,
                  ReminderType.todo => AlertLevel.notification,
                };
              });
            },
          ),
          const SizedBox(height: 20),

          // ── Alert level ───────────────────────────────────────────────────
          Text('提醒強度', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _ChipRow<AlertLevel>(
            values: AlertLevel.values,
            selected: _alertLevel,
            labelOf: (a) => a.label,
            iconOf: (a) => switch (a) {
              AlertLevel.alarm => Icons.volume_up_outlined,
              AlertLevel.notification => Icons.notifications_outlined,
              AlertLevel.silent => Icons.notifications_off_outlined,
            },
            onSelected: (a) => setState(() => _alertLevel = a),
          ),
          const SizedBox(height: 20),

          // ── Recurrence ────────────────────────────────────────────────────
          Text('重複', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _ChipRow<RecurrenceFreq>(
            values: RecurrenceFreq.values,
            selected: _freq,
            labelOf: (f) => f.label,
            onSelected: (f) => setState(() {
              _freq = f;
              if (f == RecurrenceFreq.none) { _untilDate = null; _repeatCount = null; _interval = 1; }
              // Default to weekdays (Mon–Fri) when switching to weekly
              if (f == RecurrenceFreq.weekly && _byWeekday.isEmpty) {
                _byWeekday = {'MO', 'TU', 'WE', 'TH', 'FR'};
              }
            }),
          ),

          // ── Interval (when repeating) ─────────────────────────────────────
          if (_freq != RecurrenceFreq.none) ...[
            const SizedBox(height: 16),
            Text('間隔', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _ChipRow<int>(
              values: const [1, 2, 3, 4],
              selected: _interval,
              labelOf: (n) => n == 1 ? _freq.label : '每$n${_freq.unitLabel}',
              onSelected: (n) => setState(() => _interval = n),
            ),
          ],

          // ── Weekday picker (weekly only) ──────────────────────────────────
          if (_freq == RecurrenceFreq.weekly) ...[
            const SizedBox(height: 16),
            Text('選擇週期日', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _WeekdayPicker(
              selected: _byWeekday,
              onChanged: (days) => setState(() => _byWeekday = days),
            ),
          ],

          // ── Until date (recurring reminders only) ─────────────────────────
          if (_freq != RecurrenceFreq.none) ...[
            const SizedBox(height: 20),
            Text('截止日', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('不設定'),
                  selected: _untilDate == null,
                  onSelected: (_) => setState(() => _untilDate = null),
                ),
                if (_untilDate != null)
                  Chip(
                    avatar: const Icon(Icons.event_outlined, size: 16),
                    label: Text('${_untilDate!.month}月${_untilDate!.day}日'),
                    onDeleted: () => setState(() => _untilDate = null),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month_outlined, size: 16),
                  label: Text(_untilDate == null ? '選擇截止日' : '修改'),
                  onPressed: _pickUntilDate,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('或重複次數', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('不限'),
                  selected: _repeatCount == null,
                  onSelected: (_) => setState(() => _repeatCount = null),
                ),
                for (final n in [3, 5, 7, 10, 15, 20])
                  ChoiceChip(
                    label: Text('$n 次'),
                    selected: _repeatCount == n,
                    onSelected: (_) => setState(() {
                      _repeatCount = n;
                      _untilDate = null;
                    }),
                  ),
              ],
            ),
          ],

          // ── Snooze settings (alarm level only) ───────────────────────────
          if (_alertLevel == AlertLevel.alarm) ...[
            const SizedBox(height: 24),
            Text('貪睡時間', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _ChipRow<int>(
              values: const [5, 10, 15, 30],
              selected: _snoozeMinutes,
              labelOf: (m) => '$m 分',
              onSelected: (m) => setState(() => _snoozeMinutes = m),
            ),
            const SizedBox(height: 20),
            Text('最多貪睡次數', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _ChipRow<int>(
              values: const [1, 2, 3, 5],
              selected: _maxSnoozeCount,
              labelOf: (n) => '$n 次',
              onSelected: (n) => setState(() => _maxSnoozeCount = n),
            ),
            const SizedBox(height: 20),
            Text('提前提醒', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _PreNotifyChipRow(
              selected: _preNotifyMinutes,
              onSelected: (v) => setState(() => _preNotifyMinutes = v),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.volume_up_outlined),
              title: const Text('音量漸強'),
              subtitle: const Text('從低音量逐漸升高，輕柔喚醒'),
              value: _volumeRamp,
              onChanged: (v) => setState(() => _volumeRamp = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.vibration_outlined),
              title: const Text('震動'),
              value: _vibrate,
              onChanged: (v) => setState(() => _vibrate = v),
            ),
            if (Platform.isAndroid)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note_outlined),
                title: const Text('鈴聲'),
                subtitle: Text(_ringtoneName ?? '預設鈴聲'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickRingtone,
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _testRing,
              icon: Icon(_isTesting
                  ? Icons.stop_circle_outlined
                  : Icons.play_circle_outline),
              label: Text(_isTesting ? '停止試音' : '試音'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isTesting ? Colors.red : null,
                side: BorderSide(
                  color: _isTesting
                      ? Colors.red
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _defaultTitle() {
    final h = _triggerAt.hour.toString().padLeft(2, '0');
    final m = _triggerAt.minute.toString().padLeft(2, '0');
    return switch (_type) {
      ReminderType.alarm => _freq != RecurrenceFreq.none
          ? '重複鬧鐘（${_freq.label}）'
          : '鬧鐘 ${_triggerAt.month}/${_triggerAt.day} $h:$m',
      ReminderType.event => _freq != RecurrenceFreq.none
          ? '重複事件（${_freq.label}）'
          : '事件 ${_triggerAt.month}/${_triggerAt.day} $h:$m',
      ReminderType.todo => _freq != RecurrenceFreq.none
          ? '重複待辦（${_freq.label}）'
          : '待辦 ${_triggerAt.month}/${_triggerAt.day} $h:$m',
    };
  }

  RecurrenceFreq _freqFromString(String freq) => switch (freq.toUpperCase()) {
        'DAILY' => RecurrenceFreq.daily,
        'WEEKLY' => RecurrenceFreq.weekly,
        'MONTHLY' => RecurrenceFreq.monthly,
        'YEARLY' => RecurrenceFreq.yearly,
        _ => RecurrenceFreq.none,
      };

  String _dateLabel(DateTime dt) {
    final today = DateTime.now();
    final diff = DateTime(dt.year, dt.month, dt.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return switch (diff) {
      0 => '今天',
      1 => '明天',
      2 => '後天',
      _ => '${dt.month}月${dt.day}日',
    };
  }
}

// ── Color picker ──────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  static const _palette = [
    null,
    '#E53935', // 紅
    '#FF8A00', // 橙
    '#FDD835', // 黃
    '#43A047', // 綠
    '#1E88E5', // 藍
    '#8E24AA', // 紫
  ];

  static const _names = ['無', '紅', '橙', '黃', '綠', '藍', '紫'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        for (int i = 0; i < _palette.length; i++)
          _ColorDot(
            hex: _palette[i],
            label: _names[i],
            isSelected: selected == _palette[i],
            onTap: () => onSelected(_palette[i]),
          ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.hex,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String? hex;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = hex != null
        ? Color(int.parse('FF${hex!.substring(1)}', radix: 16))
        : Theme.of(context).colorScheme.outlineVariant;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hex != null ? color : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : hex != null
                        ? color
                        : Theme.of(context).colorScheme.outlineVariant,
                width: isSelected ? 3 : 1.5,
              ),
            ),
            child: hex == null
                ? Icon(Icons.block, size: 16,
                    color: Theme.of(context).colorScheme.outlineVariant)
                : isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
          ),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Weekday picker ────────────────────────────────────────────────────────────

class _WeekdayPicker extends StatelessWidget {
  const _WeekdayPicker({required this.selected, required this.onChanged});

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  static const _keys   = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  static const _labels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < _keys.length; i++)
          _DayChip(
            label: _labels[i],
            selected: selected.contains(_keys[i]),
            isWeekend: i >= 5,
            onTap: () {
              final next = Set<String>.from(selected);
              if (next.contains(_keys[i])) {
                next.remove(_keys[i]);
              } else {
                next.add(_keys[i]);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.isWeekend,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isWeekend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isWeekend
        ? theme.colorScheme.tertiary
        : AppColors.primaryRed;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? activeColor : Colors.transparent,
          border: Border.all(
            color: selected ? activeColor : theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pre-notify chip row ───────────────────────────────────────────────────────

class _PreNotifyChipRow extends StatelessWidget {
  const _PreNotifyChipRow({required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int?> onSelected;

  static const _options = [5, 10, 15, 30];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          avatar: const Icon(Icons.notifications_off_outlined, size: 16),
          label: const Text('關閉'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final m in _options)
          ChoiceChip(
            avatar: const Icon(Icons.notifications_active_outlined, size: 16),
            label: Text('$m 分前'),
            selected: selected == m,
            onSelected: (_) => onSelected(m),
          ),
      ],
    );
  }
}

// ── Chip row ──────────────────────────────────────────────────────────────────

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.iconOf,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final v in values)
          ChoiceChip(
            avatar: iconOf != null ? Icon(iconOf!(v), size: 16) : null,
            label: Text(labelOf(v)),
            selected: selected == v,
            onSelected: (_) => onSelected(v),
          ),
      ],
    );
  }
}
