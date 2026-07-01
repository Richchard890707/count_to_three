import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'quiet_hours_provider.g.dart';

class QuietHoursState {
  const QuietHoursState({
    this.enabled = false,
    this.startMinutes = 22 * 60, // 22:00
    this.endMinutes = 7 * 60,   // 07:00
  });

  final bool enabled;
  final int startMinutes; // minutes since midnight
  final int endMinutes;

  bool isQuiet(DateTime time) {
    if (!enabled) return false;
    final mins = time.hour * 60 + time.minute;
    // startMinutes > endMinutes means the range wraps past midnight
    if (startMinutes > endMinutes) {
      return mins >= startMinutes || mins < endMinutes;
    }
    return mins >= startMinutes && mins < endMinutes;
  }

  String _label(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get startLabel => _label(startMinutes);
  String get endLabel => _label(endMinutes);

  QuietHoursState copyWith({bool? enabled, int? startMinutes, int? endMinutes}) =>
      QuietHoursState(
        enabled: enabled ?? this.enabled,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuietHoursState &&
          enabled == other.enabled &&
          startMinutes == other.startMinutes &&
          endMinutes == other.endMinutes;

  @override
  int get hashCode => Object.hash(enabled, startMinutes, endMinutes);
}

@Riverpod(keepAlive: true)
class QuietHoursNotifier extends _$QuietHoursNotifier {
  static const _kEnabled = 'quiet_enabled';
  static const _kStart   = 'quiet_start';
  static const _kEnd     = 'quiet_end';

  @override
  Future<QuietHoursState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return QuietHoursState(
      enabled:      prefs.getBool(_kEnabled) ?? false,
      startMinutes: prefs.getInt(_kStart)    ?? (22 * 60),
      endMinutes:   prefs.getInt(_kEnd)      ?? (7 * 60),
    );
  }

  Future<void> setEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, v);
    state = AsyncData((state.valueOrNull ?? const QuietHoursState()).copyWith(enabled: v));
  }

  Future<void> setStart(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStart, minutes);
    state = AsyncData((state.valueOrNull ?? const QuietHoursState()).copyWith(startMinutes: minutes));
  }

  Future<void> setEnd(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kEnd, minutes);
    state = AsyncData((state.valueOrNull ?? const QuietHoursState()).copyWith(endMinutes: minutes));
  }
}
