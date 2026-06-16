import 'package:count_to_three/app/theme/app_colors.dart';
import 'package:count_to_three/features/alarm_engine/domain/models/recurrence_input.dart';
import 'package:count_to_three/features/reminder/domain/models/reminder_enums.dart';
import 'package:count_to_three/features/reminder/presentation/controllers/alarm_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmEditScreen extends ConsumerStatefulWidget {
  const AlarmEditScreen({super.key, this.initialDate});

  /// Pre-fills the date (e.g. when launched from calendar tap).
  final DateTime? initialDate;

  @override
  ConsumerState<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends ConsumerState<AlarmEditScreen> {
  late DateTime _triggerAt;
  final _titleController = TextEditingController();
  ReminderType _type = ReminderType.alarm;
  AlertLevel _alertLevel = AlertLevel.alarm;
  RecurrenceFreq _freq = RecurrenceFreq.none;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime.now();
    final now = DateTime.now();
    // Default: next round hour, clamped to the given date
    final nextHour = now.add(const Duration(hours: 1));
    _triggerAt = DateTime(
      base.year,
      base.month,
      base.day,
      widget.initialDate != null ? 9 : nextHour.hour,
      0,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_triggerAt),
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

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入標題')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(alarmListControllerProvider.notifier).createReminder(
            _type,
            _alertLevel,
            _freq,
            title: title,
            triggerAt: _triggerAt,
          );
      if (mounted) Navigator.of(context).pop();
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
        title: const Text('新增提醒'),
        actions: [
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
            textInputAction: TextInputAction.done,
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
            onSelected: (f) => setState(() => _freq = f),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

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
