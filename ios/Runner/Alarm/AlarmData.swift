import Foundation

struct AlarmData: Codable {
    let id: Int
    let reminderId: String
    let title: String
    var scheduledAt: Int   // epoch ms
    var snoozeCount: Int
    let snoozeMinutes: Int
    let maxSnoozeCount: Int

    var triggerDate: Date {
        Date(timeIntervalSince1970: Double(scheduledAt) / 1000.0)
    }
}
