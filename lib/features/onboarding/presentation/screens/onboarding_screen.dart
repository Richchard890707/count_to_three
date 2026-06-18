import 'package:count_to_three/app/theme/app_colors.dart';
import 'package:count_to_three/core/providers/notification_scheduler_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [_PageData.welcome, _PageData.featuresPage, _PageData.permission];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    // Initialize notification scheduler (also triggers permission request on iOS/Android)
    await ref.read(notificationSchedulerProvider).initialize();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go('/alarms');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _PageView(data: _pages[i]),
              ),
            ),
            _Dots(count: _pages.length, current: _page),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _page < _pages.length - 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _finish,
                          child: const Text('跳過'),
                        ),
                        FilledButton(
                          onPressed: _next,
                          child: const Text('下一步'),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _finish,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('開始使用'),
                      ),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.features,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_Feature>? features;

  static const welcome = _PageData(
    icon: Icons.alarm_rounded,
    title: 'Count to Three',
    subtitle: '鬧鐘、行事曆、待辦三合一\n讓你再也不會錯過重要的事',
  );

  static const featuresPage = _PageData(
    icon: Icons.auto_awesome_rounded,
    title: '三種提醒模式',
    subtitle: '根據重要程度選擇最適合的提醒方式',
    features: [
      _Feature(Icons.alarm_on_rounded, '鬧鐘', '穿透靜音，強制叫醒你', AppColors.primaryRed),
      _Feature(Icons.notifications_rounded, '通知', '一般 banner 提醒', Color(0xFF1976D2)),
      _Feature(Icons.calendar_today_rounded, '靜音', '只在行事曆上標記', Color(0xFF757575)),
    ],
  );

  static const permission = _PageData(
    icon: Icons.notifications_active_rounded,
    title: '開啟通知權限',
    subtitle: '為了在鬧鐘時間準時提醒你\n需要允許發送通知',
    features: [
      _Feature(Icons.alarm_rounded, '鬧鐘提醒', '強力提醒，不會漏響', AppColors.primaryRed),
      _Feature(Icons.do_not_disturb_off_rounded, '穿透靜音 (iOS 26+)', '即使靜音模式也會響', Color(0xFF388E3C)),
    ],
  );
}

class _Feature {
  const _Feature(this.icon, this.label, this.description, this.color);
  final IconData icon;
  final String label;
  final String description;
  final Color color;
}

class _PageView extends StatelessWidget {
  const _PageView({required this.data});
  final _PageData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 52, color: AppColors.primaryRed),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          if (data.features != null) ...[
            const SizedBox(height: 36),
            ...data.features!.map((f) => _FeatureTile(feature: f)),
          ],
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: feature.color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(feature.description,
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primaryRed
                : AppColors.primaryRed.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
