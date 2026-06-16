abstract interface class SyncService {
  /// Push-first initial sync: pushPending → pullAll → subscribeSnapshots.
  Future<void> startSync(String uid);

  /// Cancel Firestore subscription; mark local PENDING → local_only.
  Future<void> stopSync();

  /// Push all syncStatus='pending' records to Firestore (outbox flush).
  Future<void> pushPending();
}
