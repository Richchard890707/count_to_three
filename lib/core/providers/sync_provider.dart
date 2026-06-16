import 'package:count_to_three/core/providers/database_provider.dart';
import 'package:count_to_three/features/sync/data/firestore_sync_service.dart';
import 'package:count_to_three/features/sync/domain/sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_provider.g.dart';

@Riverpod(keepAlive: true)
SyncService syncService(SyncServiceRef ref) => FirestoreSyncService(
      reminderDao: ref.watch(appDatabaseProvider).reminderDao,
      recurrenceRuleDao: ref.watch(appDatabaseProvider).recurrenceRuleDao,
    );
