import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/shared/database/daos/occurrence_dao.dart';
import 'package:count_to_three/shared/database/daos/reminder_dao.dart';
import 'package:drift/drift.dart';
import '../domain/sync_service.dart';

class FirestoreSyncService implements SyncService {
  FirestoreSyncService({
    required this.reminderDao,
    required this.recurrenceRuleDao,
    required this.occurrenceDao,
  }) : _firestore = FirebaseFirestore.instance;

  final ReminderDao reminderDao;
  final RecurrenceRuleDao recurrenceRuleDao;
  final OccurrenceDao occurrenceDao;
  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot>? _subscription;
  StreamSubscription<QuerySnapshot>? _occSubscription;
  String? _uid;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('reminders');

  CollectionReference<Map<String, dynamic>> _rulesCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('recurrenceRules');

  CollectionReference<Map<String, dynamic>> _occCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('occurrences');

  // ── Public API ─────────────────────────────────────────────────────────────

  @override
  Future<void> startSync(String uid) async {
    await _subscription?.cancel();
    await _occSubscription?.cancel();
    _subscription = null;
    _occSubscription = null;
    _uid = uid;

    await pushPending();
    await _pullAll(uid);
    _subscribeSnapshots(uid);
  }

  @override
  Future<void> stopSync() async {
    await _subscription?.cancel();
    await _occSubscription?.cancel();
    _subscription = null;
    _occSubscription = null;
    await reminderDao.resetPendingToLocalOnly();
    await occurrenceDao.resetPendingToLocalOnly();
    _uid = null;
  }

  @override
  Future<void> pushPending() async {
    final uid = _uid;
    if (uid == null) return;

    final pending = await reminderDao.getPendingSync();
    final pendingOccs = await occurrenceDao.getPendingSync();
    if (pending.isEmpty && pendingOccs.isEmpty) return;

    // Collect rule IDs referenced by pending reminders
    final ruleIds = pending
        .map((r) => r.recurrenceRuleId)
        .whereType<String>()
        .toSet();

    final col = _col(uid);
    final rulesCol = _rulesCol(uid);
    final occCol = _occCol(uid);
    final batch = _firestore.batch();

    for (final r in pending) {
      batch.set(col.doc(r.id), _toMap(r));
    }
    for (final ruleId in ruleIds) {
      final rule = await recurrenceRuleDao.findById(ruleId);
      if (rule != null) {
        batch.set(rulesCol.doc(rule.id), _ruleToMap(rule));
      }
    }
    for (final occ in pendingOccs) {
      batch.set(occCol.doc(occ.id), _occToMap(occ));
    }

    try {
      await batch.commit();
    } catch (_) {
      return; // network failure — leave records as 'pending' for next sync
    }

    for (final r in pending) {
      await reminderDao.updateSyncStatus(r.id, 'synced');
    }
    for (final occ in pendingOccs) {
      await occurrenceDao.updateSyncStatus(occ.id, 'synced');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _pullAll(String uid) async {
    // Pull rules first so reminder upsert can reference them
    final rulesSnap = await _rulesCol(uid).get();
    for (final doc in rulesSnap.docs) {
      await recurrenceRuleDao.upsert(_ruleFromMap(doc.id, doc.data()));
    }

    final remindersSnap = await _col(uid).get();
    for (final doc in remindersSnap.docs) {
      await _upsertLww(doc.id, doc.data());
    }

    final occSnap = await _occCol(uid).get();
    for (final doc in occSnap.docs) {
      await _upsertOccurrenceLww(doc.id, doc.data());
    }
  }

  void _subscribeSnapshots(String uid) {
    _subscription = _col(uid).snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) continue;
        final data = change.doc.data()!;

        final ruleId = data['recurrenceRuleId'] as String?;
        if (ruleId != null) {
          final existing = await recurrenceRuleDao.findById(ruleId);
          if (existing == null) {
            final ruleDoc = await _rulesCol(uid).doc(ruleId).get();
            if (ruleDoc.exists) {
              await recurrenceRuleDao.upsert(
                _ruleFromMap(ruleId, ruleDoc.data()!),
              );
            }
          }
        }

        await _upsertLww(change.doc.id, data);
      }
    });

    _occSubscription = _occCol(uid).snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          await occurrenceDao.deleteById(change.doc.id);
          continue;
        }
        await _upsertOccurrenceLww(change.doc.id, change.doc.data()!);
      }
    });
  }

  /// LWW conflict resolution: remote wins only if remote.updatedAt > local.updatedAt.
  Future<void> _upsertLww(String id, Map<String, dynamic> data) async {
    final remoteUpdatedAt = (data['updatedAt'] as num?)?.toInt() ?? 0;
    final local = await reminderDao.findById(id);

    if (local != null && local.updatedAt >= remoteUpdatedAt) return;

    await reminderDao.upsert(_fromMap(id, data));
  }

  Future<void> _upsertOccurrenceLww(String id, Map<String, dynamic> data) async {
    final remoteUpdatedAt = (data['updatedAt'] as num?)?.toInt() ?? 0;
    final local = await occurrenceDao.findById(id);

    if (local != null && (local.updatedAt ?? 0) >= remoteUpdatedAt) return;

    await occurrenceDao.upsert(OccurrencesCompanion(
      id: Value(id),
      reminderId: Value(data['reminderId'] as String? ?? ''),
      scheduledAt: Value((data['scheduledAt'] as num?)?.toInt() ?? 0),
      state: Value(data['state'] as String? ?? 'pending'),
      snoozeCount: Value((data['snoozeCount'] as num?)?.toInt() ?? 0),
      syncStatus: const Value('synced'),
      updatedAt: Value(remoteUpdatedAt),
    ));
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> _toMap(Reminder r) => {
        'id': r.id,
        'userId': r.userId,
        'type': r.type,
        'title': r.title,
        'note': r.note,
        'startAt': r.startAt,
        'timezone': r.timezone,
        'recurrenceRuleId': r.recurrenceRuleId,
        'alertLevel': r.alertLevel,
        'isEnabled': r.isEnabled,
        'isCompleted': r.isCompleted,
        'completedAt': r.completedAt,
        'createdAt': r.createdAt,
        'updatedAt': r.updatedAt,
        'isDeleted': r.isDeleted,
        'version': r.version,
        'color': r.color,
      };

  RemindersCompanion _fromMap(String id, Map<String, dynamic> d) =>
      RemindersCompanion(
        id: Value(id),
        userId: Value(d['userId'] as String?),
        type: Value(d['type'] as String? ?? 'alarm'),
        title: Value(d['title'] as String? ?? ''),
        note: Value(d['note'] as String?),
        startAt: Value((d['startAt'] as num?)?.toInt() ?? 0),
        timezone: Value(d['timezone'] as String? ?? 'Asia/Taipei'),
        recurrenceRuleId: Value(d['recurrenceRuleId'] as String?),
        alertLevel: Value(d['alertLevel'] as String? ?? 'NOTIFICATION'),
        isEnabled: Value(d['isEnabled'] as bool? ?? true),
        isCompleted: Value(d['isCompleted'] as bool? ?? false),
        completedAt: Value((d['completedAt'] as num?)?.toInt()),
        createdAt: Value((d['createdAt'] as num?)?.toInt() ?? 0),
        updatedAt: Value((d['updatedAt'] as num?)?.toInt() ?? 0),
        isDeleted: Value(d['isDeleted'] as bool? ?? false),
        version: Value((d['version'] as num?)?.toInt() ?? 1),
        color: Value(d['color'] as String?),
        syncStatus: const Value('synced'),
      );

  Map<String, dynamic> _occToMap(Occurrence o) => {
        'id': o.id,
        'reminderId': o.reminderId,
        'scheduledAt': o.scheduledAt,
        'state': o.state,
        'snoozeCount': o.snoozeCount,
        'updatedAt': o.updatedAt,
      };

  Map<String, dynamic> _ruleToMap(RecurrenceRule r) => {
        'id': r.id,
        'rruleString': r.rruleString,
        'freq': r.freq,
        'interval': r.interval,
        'byWeekday': r.byWeekday,
        'byMonthday': r.byMonthday,
        'byMonth': r.byMonth,
        'timesOfDay': r.timesOfDay,
        'count': r.count,
        'until': r.until,
      };

  RecurrenceRulesCompanion _ruleFromMap(String id, Map<String, dynamic> d) =>
      RecurrenceRulesCompanion(
        id: Value(id),
        rruleString: Value(d['rruleString'] as String? ?? ''),
        freq: Value(d['freq'] as String? ?? 'NONE'),
        interval: Value((d['interval'] as num?)?.toInt() ?? 1),
        byWeekday: Value(d['byWeekday'] as String?),
        byMonthday: Value(d['byMonthday'] as String?),
        byMonth: Value(d['byMonth'] as String?),
        timesOfDay: Value(d['timesOfDay'] as String?),
        count: Value((d['count'] as num?)?.toInt()),
        until: Value((d['until'] as num?)?.toInt()),
      );
}
