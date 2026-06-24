import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits a value every 60 seconds. Watch this to force a widget to rebuild
/// once per minute (e.g., countdown timers in list cards).
final minuteTickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(minutes: 1), (i) => i);
});
