import Foundation

final class AlarmEngine {
    static let shared = AlarmEngine()
    private init() {}

    // MARK: - Permission

    @discardableResult
    func requestPermission() async -> Bool {
        if #available(iOS 26.1, *) {
            return await AlarmKitScheduler.shared.requestAuthorization()
        } else {
            return await withCheckedContinuation { cont in
                NotificationFallback.shared.requestAuthorization { cont.resume(returning: $0) }
            }
        }
    }

    // MARK: - Schedule

    func schedule(alarm: AlarmData) async throws {
        AlarmStore.shared.put(alarm)
        if #available(iOS 26.1, *) {
            try await AlarmKitScheduler.shared.schedule(alarm)
        } else {
            NotificationFallback.shared.registerCategory()
            NotificationFallback.shared.schedule(alarm)
        }
    }

    // MARK: - Cancel

    func cancel(alarmId: Int) async throws {
        if #available(iOS 26.1, *) {
            try AlarmKitScheduler.shared.cancel(alarmId: alarmId)
        } else {
            NotificationFallback.shared.cancel(alarmId: alarmId)
        }
        AlarmStore.shared.remove(alarmId)
    }

    // MARK: - Foreground reconciliation (Decision C)

    /// Called from SceneDelegate.sceneDidBecomeActive.
    /// Compares AlarmStore vs AlarmKit's live list; alarms that vanished were
    /// stopped/snoozed via the system UI — emit Dismissed events and clean up.
    func detectHandledAlarms() async {
        guard #available(iOS 26.1, *) else { return }
        let activeIds = await AlarmKitScheduler.shared.pendingAlarmIds()
        for alarm in AlarmStore.shared.getAll() where !activeIds.contains(alarm.id) {
            AlarmEventBus.shared.emit([
                "type": "dismissed",
                "alarmId": alarm.id,
                "reminderId": alarm.reminderId,
                "auto": false,
            ])
            AlarmStore.shared.remove(alarm.id)
        }
    }
}
