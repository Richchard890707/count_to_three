import 'dart:io';
import 'package:count_to_three/core/providers/auth_provider.dart';
import 'package:count_to_three/features/auth/domain/models/app_user.dart';
import 'package:count_to_three/shared/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Battery / reliability section (Android only)
          if (Platform.isAndroid) ...[
            const _BatteryGuidanceCard(),
            const SizedBox(height: 8),
          ],
          // Auth section
          authState.when(
            data: (user) =>
                user != null ? _SignedInBody(user: user) : const _SignedOutBody(),
            loading: () => const _SettingsSkeleton(),
            error: (e, _) => Center(child: Text('錯誤：$e')),
          ),
        ],
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

class _BatteryGuidanceCardState extends State<_BatteryGuidanceCard> {
  static const _channel = MethodChannel('app.ontime/alarm');

  bool? _isIgnoring;

  @override
  void initState() {
    super.initState();
    _checkStatus();
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
      // Re-check after user returns from settings
      await Future.delayed(const Duration(seconds: 1));
      await _checkStatus();
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
