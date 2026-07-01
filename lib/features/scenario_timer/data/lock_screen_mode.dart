import 'package:flutter/services.dart';

/// Toggles the native Activity into "lock-screen mode": shown over the
/// keyguard + screen kept on, so the timer's 做完這組 / 我好了 buttons are
/// tappable without unlocking. Reuses the same flags as the alarm screen.
///
/// MIUI note: needs the app's "在鎖定螢幕上顯示" permission granted (same one
/// the alarm feature relies on).
class LockScreenMode {
  static const _channel = MethodChannel('app.ontime/timer');

  static Future<void> enable() => _set(true);
  static Future<void> disable() => _set(false);

  static Future<void> _set(bool enabled) async {
    try {
      await _channel.invokeMethod('setLockScreenMode', enabled);
    } catch (_) {
      // Best-effort: ignore on platforms/devices without the channel.
    }
  }
}
