import Foundation

final class AlarmEngine {
    static let shared = AlarmEngine()
    private init() {}

    // MARK: - Permission

    @discardableResult
    func requestPermission() async -> Bool {
        // Always request UNUserNotificationCenter auth (used as AlarmKit fallback on simulator)
        let notifGranted = await withCheckedContinuation { cont in
            NotificationFallback.shared.requestAuthorization { cont.resume(returning: $0) }
        }
        if #available(iOS 26.1, *) {
            let kitGranted = await AlarmKitScheduler.shared.requestAuthorization()
            return kitGranted || notifGranted
        }
        return notifGranted
    }

    // MARK: - Schedule

    func schedule(alarm: AlarmData) async throws {
        AlarmStore.shared.put(alarm)
        if #available(iOS 26.1, *) {
            do {
                try await AlarmKitScheduler.shared.schedule(alarm)
                return
            } catch {
                // AlarmKit unavailable (simulator, unauthorized) — fall through to UNNotification
            }
        }
        NotificationFallback.shared.registerCategory()
        NotificationFallback.shared.schedule(alarm)
    }

    // MARK: - Snooze

    func snooze(alarmId: Int) async throws {
        guard var alarm = AlarmStore.shared.get(alarmId) else { return }

        if alarm.snoozeCount >= alarm.maxSnoozeCount {
            // Max snoozes reached — just dismiss
            try await cancel(alarmId: alarmId)
            AlarmEventBus.shared.emit([
                "type": "dismissed",
                "alarmId": alarmId,
                "reminderId": alarm.reminderId,
                "auto": true,
            ])
            return
        }

        // Cancel current alarm
        if #available(iOS 26.1, *) { try? AlarmKitScheduler.shared.cancel(alarmId: alarmId) }
        NotificationFallback.shared.cancel(alarmId: alarmId)

        // Reschedule
        alarm.snoozeCount += 1
        alarm.scheduledAt = Int(Date().timeIntervalSince1970 * 1000) + alarm.snoozeMinutes * 60_000
        AlarmStore.shared.put(alarm)

        try await schedule(alarm: alarm)

        AlarmEventBus.shared.emit([
            "type": "snoozed",
            "alarmId": alarmId,
            "reminderId": alarm.reminderId,
            "snoozeCount": alarm.snoozeCount,
        ])
    }

    // MARK: - Cancel

    func cancel(alarmId: Int) async throws {
        if #available(iOS 26.1, *) {
            try? AlarmKitScheduler.shared.cancel(alarmId: alarmId)
        }
        // Also cancel UNNotification in case this alarm used the fallback path
        NotificationFallback.shared.cancel(alarmId: alarmId)
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
