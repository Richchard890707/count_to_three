import 'package:count_to_three/features/alarm_engine/domain/models/notification_request.dart';
import 'package:count_to_three/features/alarm_engine/domain/notification_scheduler.dart';
import 'package:count_to_three/features/scenario_timer/domain/models/workout_timer_state.dart';

/// Track B (screen-off fallback): pre-schedules the two rest cues as one-shot
/// notifications so the ding still fires if the app is backgrounded / screen
/// off. Cancelled the moment the user is back in the foreground or taps ready.
///
/// Reuses the existing [NotificationScheduler] — the ONLY thing borrowed from
/// alarm_engine (see ADR-001). Only one rest is active at a time, so fixed ids.
class RestCueScheduler {
  RestCueScheduler(this._scheduler);

  final NotificationScheduler _scheduler;

  static const int softId = 920001;
  static const int spineId = 920002;

  /// Schedules the screen-off fallback cues. [skip] holds cues already fired
  /// in the foreground (track A) so they aren't double-delivered.
  Future<void> scheduleForRest({
    required String sessionId,
    required DateTime restStart,
    required Duration softTarget,
    required Duration spineThreshold,
    Set<RestCue> skip = const {},
  }) async {
    // Best-effort: a notification failure (e.g. permission off) must never
    // disrupt the timer itself.
    try {
      if (!skip.contains(RestCue.soft)) {
        await _scheduler.scheduleNotification(
          NotificationRequest(
            id: softId,
            reminderId: sessionId,
            title: '建議開始下一組',
            triggerAt: restStart.add(softTarget),
          ),
        );
      }
      if (!skip.contains(RestCue.spine)) {
        await _scheduler.scheduleNotification(
          NotificationRequest(
            id: spineId,
            reminderId: sessionId,
            title: '休息有點久了',
            triggerAt: restStart.add(spineThreshold),
          ),
        );
      }
    } catch (_) {
      // ignore — track A (foreground audio) is the primary path
    }
  }

  Future<void> cancelAll() async {
    try {
      await _scheduler.cancelNotification(softId);
      await _scheduler.cancelNotification(spineId);
    } catch (_) {
      // ignore
    }
  }
}
