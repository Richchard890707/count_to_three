import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Returns the device's current IANA timezone name (e.g. "America/New_York").
/// Cached for the app lifetime; falls back to 'Asia/Taipei' on error.
final localTimezoneProvider = FutureProvider<String>((ref) async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (_) {
    return 'Asia/Taipei';
  }
});
