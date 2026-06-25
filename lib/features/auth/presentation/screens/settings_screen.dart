import 'dart:io';
import 'package:count_to_three/core/providers/auth_provider.dart';
import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/core/providers/quiet_hours_provider.dart';
import 'package:count_to_three/core/providers/reschedule_window_provider.dart';
import 'package:count_to_three/core/providers/theme_provider.dart';
import 'package:count_to_three/features/auth/domain/models/app_user.dart';
import 'package:count_to_three/features/settings/domain/usecases/export_data_usecase.dart';
import 'package:count_to_three/features/settings/domain/usecases/import_data_usecase.dart';
import 'package:count_to_three/shared/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _exporting = false;
  bool _importing = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final json = await ExportDataUseCase(
        reminderDao: db.reminderDao,
        recurrenceRuleDao: db.recurrenceRuleDao,
        alarmConfigDao: db.alarmConfigDao,
        occurrenceDao: db.occurrenceDao,
      ).call();

      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/count_to_three_$stamp.json');
      await file.writeAsString(json);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Count to Three 匯出資料',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('匯出失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  static const _dataChannel = MethodChannel('app.ontime/data');

  Future<void> _import() async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final jsonString = await _dataChannel.invokeMethod<String>('pickFile');
      if (jsonString == null) return; // user cancelled

      final db = ref.read(appDatabaseProvider);
      final importResult = await ImportDataUseCase(
        reminderDao: db.reminderDao,
        recurrenceRuleDao: db.recurrenceRuleDao,
        alarmConfigDao: db.alarmConfigDao,
      ).call(jsonString);

      // Delete stale pending occurrences for updated reminders so that
      // rescheduleWindow starts fresh from the new startAt / recurrence rule.
      for (final id in importResult.updatedIds) {
        await db.occurrenceDao.deleteAllPendingByReminder(id);
      }

      // Reschedule all alarms for newly imported reminders
      await ref.read(rescheduleWindowProvider).call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '匯入完成：${importResult.imported} 個提醒'
              '${importResult.skipped > 0 ? '（${importResult.skipped} 個已跳過）' : ''}',
            ),
          ),
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('匯入失敗：${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('匯入失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(appThemeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // iOS-only: notification + AlarmKit permission guidance
          if (Platform.isIOS) ...[
            const _IosNotifCard(),
            const _AlarmKitCard(),
            const SizedBox(height: 16),
          ],

          // Android-only reliability cards
          if (Platform.isAndroid) ...[
            const _ExactAlarmCard(),
            const _FullScreenIntentCard(),
            const _BatteryGuidanceCard(),
            const SizedBox(height: 16),
          ],

          // ── Quiet Hours ───────────────────────────────────────────
          _SectionLabel(label: '靜音時段'),
          const SizedBox(height: 8),
          const _QuietHoursCard(),
          const SizedBox(height: 16),

          // ── Theme ─────────────────────────────────────────────────
          _SectionLabel(label: '外觀'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text('主題', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined, size: 18),
                        label: Text('自動'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined, size: 18),
                        label: Text('淺色'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined, size: 18),
                        label: Text('深色'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) =>
                        ref.read(appThemeModeNotifierProvider.notifier).set(s.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Account ───────────────────────────────────────────────
          _SectionLabel(label: '帳號與同步'),
          const SizedBox(height: 8),
          authState.when(
            data: (user) =>
                user != null ? _SignedInBody(user: user) : const _SignedOutBody(),
            loading: () => const _SettingsSkeleton(),
            error: (e, _) => Center(child: Text('錯誤：$e')),
          ),
          const SizedBox(height: 16),

          // ── About ─────────────────────────────────────────────────
          _SectionLabel(label: '關於'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Count to Three'),
                  subtitle: const Text('整合型時間提醒工具'),
                  trailing: Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _exporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_outlined),
                  title: const Text('匯出資料'),
                  subtitle: const Text('將所有提醒匯出為 JSON 檔'),
                  onTap: _exporting ? null : _export,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _importing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  title: const Text('匯入資料'),
                  subtitle: const Text('從 JSON 備份還原提醒'),
                  onTap: _importing ? null : _import,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
}

// ── iOS notification permission ───────────────────────────────────────────────

class _IosNotifCard extends StatefulWidget {
  const _IosNotifCard();
  @override
  State<_IosNotifCard> createState() => _IosNotifCardState();
}

class _IosNotifCardState extends State<_IosNotifCard>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('app.ontime/alarm');
  bool? _authorized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final ok = await _channel.invokeMethod<bool>('notif.checkAuthorized');
      if (mounted) setState(() => _authorized = ok ?? true);
    } catch (_) {
      if (mounted) setState(() => _authorized = true);
    }
  }

  Future<void> _open() async {
    try {
      await _channel.invokeMethod('notif.openSettings');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isOk = _authorized ?? true;
    if (isOk) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications_off_outlined, color: Colors.orange),
        title: const Text('通知權限'),
        subtitle: const Text('請開啟通知以接收提醒與鬧鐘'),
        trailing: TextButton(
          onPressed: _open,
          child: const Text('前往開啟'),
        ),
      ),
    );
  }
}

// ── AlarmKit permission (iOS 26+) ─────────────────────────────────────────────

class _AlarmKitCard extends StatefulWidget {
  const _AlarmKitCard();
  @override
  State<_AlarmKitCard> createState() => _AlarmKitCardState();
}

class _AlarmKitCardState extends State<_AlarmKitCard>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('app.ontime/alarm');
  bool? _authorized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final ok = await _channel.invokeMethod<bool>('alarmkit.isAuthorized');
      if (mounted) setState(() => _authorized = ok ?? true);
    } catch (_) {
      if (mounted) setState(() => _authorized = true);
    }
  }

  Future<void> _open() async {
    try {
      await _channel.invokeMethod('alarmkit.openSettings');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isOk = _authorized ?? true;
    if (isOk) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.alarm_off_outlined, color: Colors.orange),
          title: const Text('AlarmKit 鬧鐘權限'),
          subtitle: const Text('請授權 AlarmKit 以在靜音模式下準時響鈴（需 iOS 26+）'),
          trailing: TextButton(
            onPressed: _open,
            child: const Text('前往開啟'),
          ),
        ),
      ),
    );
  }
}

// ── Exact alarm permission (Android 12, API 31-32) ────────────────────────────

class _ExactAlarmCard extends StatefulWidget {
  const _ExactAlarmCard();
  @override
  State<_ExactAlarmCard> createState() => _ExactAlarmCardState();
}

class _ExactAlarmCardState extends State<_ExactAlarmCard>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('app.ontime/alarm');
  bool? _canSchedule;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final ok = await _channel.invokeMethod<bool>('alarm.canScheduleExact');
      if (mounted) setState(() => _canSchedule = ok ?? true);
    } catch (_) {
      if (mounted) setState(() => _canSchedule = true);
    }
  }

  Future<void> _open() async {
    try {
      await _channel.invokeMethod('alarm.openExactAlarmSettings');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isOk = _canSchedule ?? true;
    if (isOk) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.alarm_off_outlined, color: Colors.orange),
          title: const Text('精確鬧鐘權限'),
          subtitle: const Text('請開啟「精確鬧鐘」以確保鬧鐘準時響起'),
          trailing: TextButton(
            onPressed: _open,
            child: const Text('前往開啟'),
          ),
        ),
      ),
    );
  }
}

// ── Full-screen intent permission (Android 14+) ───────────────────────────────

class _FullScreenIntentCard extends StatefulWidget {
  const _FullScreenIntentCard();
  @override
  State<_FullScreenIntentCard> createState() => _FullScreenIntentCardState();
}

class _FullScreenIntentCardState extends State<_FullScreenIntentCard>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('app.ontime/alarm');
  bool? _canUse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final ok = await _channel.invokeMethod<bool>('fullscreen.canUse');
      if (mounted) setState(() => _canUse = ok ?? true);
    } catch (_) {
      if (mounted) setState(() => _canUse = true);
    }
  }

  Future<void> _open() async {
    try {
      await _channel.invokeMethod('fullscreen.openSettings');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isOk = _canUse ?? true;
    if (isOk) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.fullscreen_exit_outlined, color: Colors.orange),
          title: const Text('全螢幕鬧鐘權限'),
          subtitle: const Text('請開啟「全螢幕通知」，鬧鐘才能在螢幕關閉時彈出'),
          trailing: TextButton(
            onPressed: _open,
            child: const Text('前往開啟'),
          ),
        ),
      ),
    );
  }
}

// ── Battery reliability (Android) ─────────────────────────────────────────────

class _BatteryGuidanceCard extends StatefulWidget {
  const _BatteryGuidanceCard();

  @override
  State<_BatteryGuidanceCard> createState() => _BatteryGuidanceCardState();
}

class _BatteryGuidanceCardState extends State<_BatteryGuidanceCard>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('app.ontime/alarm');

  bool? _isIgnoring;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('battery.isIgnoring');
      if (mounted) setState(() => _isIgnoring = result ?? false);
    } catch (_) {
      if (mounted) setState(() => _isIgnoring = false);
    }
  }

  Future<void> _requestIgnore() async {
    try {
      await _channel.invokeMethod('battery.requestIgnore');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isOk = _isIgnoring ?? false;
    return Card(
      child: ListTile(
        leading: Icon(
          isOk ? Icons.battery_charging_full_outlined : Icons.battery_alert_outlined,
          color: isOk ? Colors.green : Colors.orange,
        ),
        title: const Text('鬧鐘可靠度'),
        subtitle: Text(
          isOk ? '電池最佳化已關閉，鬧鐘可靠' : '建議關閉電池最佳化以確保鬧鐘準時響起',
        ),
        trailing: isOk
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(
                onPressed: _requestIgnore,
                child: const Text('修復'),
              ),
        onTap: isOk ? null : _requestIgnore,
      ),
    );
  }
}

// ── Settings skeleton ─────────────────────────────────────────────────────────

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ListTile(
            leading: const SkeletonBox(width: 40, height: 40, radius: 20),
            title: SkeletonBox(width: 120, height: 16, radius: 4),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SkeletonBox(width: 180, height: 12, radius: 4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const SkeletonBox(width: 24, height: 24, radius: 4),
            title: SkeletonBox(width: 80, height: 16, radius: 4),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SkeletonBox(width: 140, height: 12, radius: 4),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Signed-in ─────────────────────────────────────────────────────────────────

class _SignedInBody extends ConsumerWidget {
  const _SignedInBody({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: user.photoUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl!),
                  )
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.displayName ?? user.email),
            subtitle: Text(user.email),
          ),
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            leading: Icon(Icons.cloud_done_outlined),
            title: Text('雲端同步'),
            subtitle: Text('即時同步已啟用'),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () async {
            await ref.read(authServiceProvider).signOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text('登出'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}

// ── Quiet Hours ───────────────────────────────────────────────────────────────

class _QuietHoursCard extends ConsumerWidget {
  const _QuietHoursCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quietHoursNotifierProvider).valueOrNull
        ?? const QuietHoursState();
    final notifier = ref.read(quietHoursNotifierProvider.notifier);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.bedtime_outlined),
            title: const Text('靜音時段'),
            subtitle: Text(
              state.enabled
                  ? '${state.startLabel} – ${state.endLabel}　不傳送通知提醒'
                  : '停用（全天皆傳送通知提醒）',
            ),
            value: state.enabled,
            onChanged: (v) => notifier.setEnabled(v),
          ),
          if (state.enabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.nights_stay_outlined),
              title: const Text('開始時間'),
              trailing: Text(
                state.startLabel,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: state.startMinutes ~/ 60,
                    minute: state.startMinutes % 60,
                  ),
                );
                if (picked != null) {
                  notifier.setStart(picked.hour * 60 + picked.minute);
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('結束時間'),
              trailing: Text(
                state.endLabel,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: state.endMinutes ~/ 60,
                    minute: state.endMinutes % 60,
                  ),
                );
                if (picked != null) {
                  notifier.setEnd(picked.hour * 60 + picked.minute);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ── Signed-out ────────────────────────────────────────────────────────────────

class _SignedOutBody extends ConsumerWidget {
  const _SignedOutBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              '登入後可在多裝置同步提醒資料',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await ref.read(authServiceProvider).signInWithGoogle();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('登入失敗：$e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('使用 Google 帳號登入'),
            ),
          ],
        ),
      ),
    );
  }
}
