// NOTE: AlarmKit was introduced in iOS 26 (WWDC 2025).
// This file is compiled only on iOS 26+ targets; on older devices the
// runtime `#available` guards in AlarmEngine route to NotificationFallback.

import Foundation
import SwiftUI

#if canImport(AlarmKit)
import AlarmKit

/// Empty metadata type — AlarmKit requires a concrete AlarmMetadata conformance
/// even when no Live Activity metadata is needed.
struct AlarmEmptyMetadata: AlarmMetadata {}

@available(iOS 26.0, *)
final class AlarmKitScheduler {
    static let shared = AlarmKitScheduler()
    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let status = try await AlarmManager.shared.requestAuthorization()
            return status == .authorized
        } catch {
            return false
        }
    }

    // MARK: - Schedule / Cancel

    func schedule(_ alarm: AlarmData) async throws {
        let alert = AlarmPresentation.Alert(
            title: alarm.title,
            stopButton: AlarmButton(text: "停止") // ⚠️ VERIFY AlarmButton init params
        )
        let attributes = AlarmAttributes<AlarmEmptyMetadata>(
            presentation: AlarmPresentation(alert: alert),
            tintColor: Color(red: 0.898, green: 0.224, blue: 0.208)
        )
        let configuration = AlarmConfiguration(
            schedule: .fixed(alarm.triggerDate),
            attributes: attributes
        )
        try await AlarmManager.shared.schedule(
            id: alarmUUID(alarm.id),
            configuration: configuration
        )
    }

    func cancel(alarmId: Int) async throws {
        try await AlarmManager.shared.cancel(id: alarmUUID(alarmId))
    }

    // MARK: - Pending alarm detection (called on app foreground)

    /// Returns the set of our alarmIds that are still actively scheduled in AlarmKit.
    func pendingAlarmIds() async -> Set<Int> {
        let stored = AlarmStore.shared.getAll()
        guard !stored.isEmpty else { return [] }

        let kitAlarms = AlarmManager.shared.alarms  // synchronous property
        let activeUUIDs = Set(kitAlarms.map { $0.id })
        return Set(stored.filter { activeUUIDs.contains(alarmUUID($0.id)) }.map { $0.id })
    }

    // MARK: - Helpers

    /// Converts our Int alarmId to a deterministic UUID suitable for AlarmKit.
    private func alarmUUID(_ id: Int) -> UUID {
        // Format: 00000000-0000-4000-8000-{id as 12 lower-hex digits}
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
