// NOTE: AlarmKit was introduced in iOS 26 (WWDC 2025).
// This file is compiled only on iOS 26+ targets; on older devices the
// runtime `#available` guards in AlarmEngine route to NotificationFallback.
//
// IMPORTANT: If any AlarmKit symbol fails to resolve, verify the API against
// Xcode 26 documentation or the WWDC25 "Introducing AlarmKit" session.
// Likely mismatch points are annotated with // ⚠️ VERIFY.

import Foundation

#if canImport(AlarmKit)
import AlarmKit

@available(iOS 26.0, *)
final class AlarmKitScheduler {
    static let shared = AlarmKitScheduler()
    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let status = try await AlarmManager.shared.requestAuthorization() // ⚠️ VERIFY return type
            return status == .authorized                                        // ⚠️ VERIFY enum case
        } catch {
            return false
        }
    }

    // MARK: - Schedule / Cancel

    func schedule(_ alarm: AlarmData) async throws {
        let kitAlarm = Alarm(
            id: alarmUUID(alarm.id),
            schedule: AlarmSchedule(date: alarm.triggerDate) // ⚠️ VERIFY AlarmSchedule init
        )
        try await AlarmManager.shared.schedule(kitAlarm) // ⚠️ VERIFY method signature
    }

    func cancel(alarmId: Int) async throws {
        try await AlarmManager.shared.cancel(alarmUUID(alarmId)) // ⚠️ VERIFY method signature
    }

    // MARK: - Pending alarm detection (called on app foreground)

    /// Returns the set of our alarmIds that are still actively scheduled in AlarmKit.
    func pendingAlarmIds() async -> Set<Int> {
        let stored = AlarmStore.shared.getAll()
        guard !stored.isEmpty else { return [] }

        let kitAlarms: [Alarm]
        do {
            kitAlarms = try await AlarmManager.shared.alarms // ⚠️ VERIFY: may be a property vs method
        } catch {
            // Cannot determine status → assume all still pending
            return Set(stored.map { $0.id })
        }

        let activeUUIDs = Set(kitAlarms.map { $0.id })
        return Set(stored.filter { activeUUIDs.contains(alarmUUID($0.id)) }.map { $0.id })
    }

    // MARK: - Helpers

    /// Converts our Int alarmId to a deterministic UUID suitable for AlarmKit.
    private func alarmUUID(_ id: Int) -> UUID {
        // Format: 00000000-0000-4000-8000-{id as 12 lower-hex digits}
        // alarmId is always < 1_000_000, so the 12-char field is more than enough.
        UUID(uuidString: String(format: "00000000-0000-4000-8000-%012x", id))!
    }
}

#else
// AlarmKit not available in this SDK (Xcode < 26).
// AlarmEngine falls through to NotificationFallback at runtime anyway,
// but this stub keeps the file compilable on older SDKs.
@available(iOS 26.0, *)
final class AlarmKitScheduler {
    static let shared = AlarmKitScheduler()
    private init() {}
    func requestAuthorization() async -> Bool { false }
    func schedule(_ alarm: AlarmData) async throws {}
    func cancel(alarmId: Int) async throws {}
    func pendingAlarmIds() async -> Set<Int> { [] }
}
#endif
