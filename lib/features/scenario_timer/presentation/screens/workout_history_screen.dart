import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:count_to_three/shared/database/app_database.dart';
import 'package:count_to_three/features/scenario_timer/presentation/controllers/workout_timer_controller.dart';

String _fmtDate(int ms) {
  final t = DateTime.fromMillisecondsSinceEpoch(ms);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

final _sessionsProvider =
    StreamProvider.autoDispose<List<WorkoutSessionRow>>((ref) {
  return ref.watch(workoutDaoProvider).watchSessions();
});

/// dogfood 數據檢視:每次訓練的每組真實休息(固定計時器拿不到的數據)+ CSV 匯出。
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final dao = ref.read(workoutDaoProvider);
    final sessions = await dao.watchSessions().first;
    final rows = <String>[
      'session_started,set_index,rest_seconds,rest_start_ms,rest_end_ms',
    ];
    for (final s in sessions) {
      for (final r in await dao.recordsForSession(s.id)) {
        rows.add('${_fmtDate(s.startedAt)},${r.setIndex},'
            '${(r.restDurationMs / 1000).toStringAsFixed(1)},'
            '${r.restStartMs},${r.restEndMs}');
      }
    }
    if (rows.length == 1) return; // nothing but header
    await Share.share(rows.join('\n'), subject: '組間休息數據');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_sessionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('休息紀錄'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: '匯出 CSV',
            onPressed: () => _exportCsv(context, ref),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('讀取失敗:$e')),
        data: (sessions) => sessions.isEmpty
            ? const Center(child: Text('還沒有任何訓練紀錄'))
            : ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (_, i) => _SessionTile(session: sessions[i]),
              ),
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session});
  final WorkoutSessionRow session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: Text(_fmtDate(session.startedAt)),
      subtitle: Text(
          '目標 ${session.targetSets} 組 · 軟目標 ${session.softTargetMs ~/ 1000}s'),
      children: [
        FutureBuilder<List<SetRecordRow>>(
          future: ref.read(workoutDaoProvider).recordsForSession(session.id),
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: LinearProgressIndicator(),
              );
            }
            final recs = snap.data!;
            if (recs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Text('（沒有完成的休息記錄）'),
              );
            }
            return Column(
              children: [
                for (final r in recs)
                  ListTile(
                    dense: true,
                    title: Text('第 ${r.setIndex} 組後'),
                    trailing: Text(
                      '${(r.restDurationMs / 1000).toStringAsFixed(1)}s',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
