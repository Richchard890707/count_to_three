import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:count_to_three/features/scenario_timer/data/session_persistence.dart';

void main() {
  test('SessionSnapshot JSON round-trips all fields', () {
    const snap = SessionSnapshot(
      sessionId: 's1',
      targetSets: 5,
      softTargetMs: 90000,
      setsCompleted: 2,
      phase: 'resting',
      setRef: 2,
      restStartedAtMs: 1700000000000,
      firedSoft: true,
      firedSpine: false,
      savedAtMs: 1700000123456,
      sessionStartedAtMs: 1699999999000,
    );
    final back = SessionSnapshot.fromJson(snap.toJson());
    expect(back.sessionId, 's1');
    expect(back.targetSets, 5);
    expect(back.softTargetMs, 90000);
    expect(back.setsCompleted, 2);
    expect(back.phase, 'resting');
    expect(back.setRef, 2);
    expect(back.restStartedAtMs, 1700000000000);
    expect(back.firedSoft, true);
    expect(back.firedSpine, false);
    expect(back.savedAtMs, 1700000123456);
    expect(back.sessionStartedAtMs, 1699999999000);
  });

  test('legacy snapshot without savedAtMs defaults to 0', () {
    final back = SessionSnapshot.fromJson(const {
      'sessionId': 'old',
      'targetSets': 4,
      'softTargetMs': 90000,
      'setsCompleted': 0,
      'phase': 'working',
      'setRef': 1,
      'restStartedAtMs': 0,
      'firedSoft': false,
      'firedSpine': false,
    });
    expect(back.savedAtMs, 0);
  });

  test('SessionPersistence save → load → clear', () async {
    SharedPreferences.setMockInitialValues({});
    final p = SessionPersistence();

    expect(await p.load(), isNull, reason: 'nothing saved yet');

    await p.save(const SessionSnapshot(
      sessionId: 's2',
      targetSets: 3,
      softTargetMs: 60000,
      setsCompleted: 1,
      phase: 'working',
      setRef: 2,
      restStartedAtMs: 0,
      firedSoft: false,
      firedSpine: false,
      savedAtMs: 1700000000000,
      sessionStartedAtMs: 1700000000000,
    ));

    final loaded = await p.load();
    expect(loaded, isNotNull);
    expect(loaded!.sessionId, 's2');
    expect(loaded.phase, 'working');
    expect(loaded.setRef, 2);

    await p.clear();
    expect(await p.load(), isNull, reason: 'cleared');
  });

  test('corrupt snapshot is ignored, not thrown', () async {
    SharedPreferences.setMockInitialValues(
        {'scenario_timer_live_session': '{not valid json'});
    final p = SessionPersistence();
    expect(await p.load(), isNull);
  });
}
