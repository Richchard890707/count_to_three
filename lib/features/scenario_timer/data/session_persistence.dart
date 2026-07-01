import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A snapshot of the live session, just enough to resume after the OS (MIUI is
/// aggressive) kills the app mid-workout. Completed rests live in the DB; this
/// only captures the in-flight phase. See ADR-001.
class SessionSnapshot {
  const SessionSnapshot({
    required this.sessionId,
    required this.targetSets,
    required this.softTargetMs,
    required this.setsCompleted,
    required this.phase, // 'working' | 'resting'
    required this.setRef, // working: currentSet; resting: setJustDone
    required this.restStartedAtMs, // resting only; 0 when working
    required this.firedSoft,
    required this.firedSpine,
    required this.savedAtMs, // wall-clock when written; used to drop stale snapshots
    required this.sessionStartedAtMs, // whole-session start; restores total pill
  });

  final String sessionId;
  final int targetSets;
  final int softTargetMs;
  final int setsCompleted;
  final String phase;
  final int setRef;
  final int restStartedAtMs;
  final bool firedSoft;
  final bool firedSpine;
  final int savedAtMs;
  final int sessionStartedAtMs;

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'targetSets': targetSets,
        'softTargetMs': softTargetMs,
        'setsCompleted': setsCompleted,
        'phase': phase,
        'setRef': setRef,
        'restStartedAtMs': restStartedAtMs,
        'firedSoft': firedSoft,
        'firedSpine': firedSpine,
        'savedAtMs': savedAtMs,
        'sessionStartedAtMs': sessionStartedAtMs,
      };

  factory SessionSnapshot.fromJson(Map<String, dynamic> j) => SessionSnapshot(
        sessionId: j['sessionId'] as String,
        targetSets: j['targetSets'] as int,
        softTargetMs: j['softTargetMs'] as int,
        setsCompleted: j['setsCompleted'] as int,
        phase: j['phase'] as String,
        setRef: j['setRef'] as int,
        restStartedAtMs: j['restStartedAtMs'] as int,
        firedSoft: j['firedSoft'] as bool,
        firedSpine: j['firedSpine'] as bool,
        savedAtMs: (j['savedAtMs'] as int?) ?? 0,
        sessionStartedAtMs: (j['sessionStartedAtMs'] as int?) ?? 0,
      );
}

class SessionPersistence {
  static const _key = 'scenario_timer_live_session';

  Future<void> save(SessionSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }

  Future<SessionSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return SessionSnapshot.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // corrupt snapshot → ignore
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
