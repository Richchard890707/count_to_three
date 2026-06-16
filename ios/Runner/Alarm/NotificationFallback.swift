import Foundation
import UserNotifications

/// iOS ≤25 fallback: schedules a UNNotificationRequest.
/// Without the Critical Alert entitlement (requires Apple approval),
/// the alarm can be silenced by the user. A UI banner should inform them
/// that iOS 26+ is needed for alarm-grade reliability.
final class NotificationFallback {
    static let shared = NotificationFallback()

    private let categoryId    = "ALARM_CATEGORY"
    private let stopActionId  = "ALARM_STOP"
    private let snoozeActionId = "ALARM_SNOOZE"

    private init() {}

    // MARK: - Setup

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async { completion(granted) }
            }
    }

    func registerCategory() {
        let stop = UNNotificationAction(
            identifier: stopActionId,
            title: "停止",
            options: [.destructive, .foreground]
        )
        let snooze = UNNotificationAction(
            identifier: snoozeActionId,
            title: "貪睡",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: categoryId,
            actions: [stop, snooze],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Schedule / Cancel

    func schedule(_ alarm: AlarmData) {
        let content = UNMutableNotificationContent()
        content.title = alarm.title
        content.body  = "點擊查看（iOS ≤25：無法穿透靜音，請升級至 iOS 26 取得完整保護）"
        content.categoryIdentifier = categoryId
        content.sound = .default
        content.userInfo = ["alarmId": alarm.id, "reminderId": alarm.reminderId]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: alarm.triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: String(alarm.id),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancel(alarmId: Int) {
        let id = String(alarmId)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }

    // MARK: - Action handling (called from AppDelegate UNUserNotificationCenterDelegate)

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let info     = response.notification.request.content.userInfo
        guard let alarmId    = info["alarmId"]    as? Int,
              let reminderId = info["reminderId"] as? String else { return }

        switch response.actionIdentifier {
        case stopActionId, UNNotificationDefaultActionIdentifier:
            emitDismissed(alarmId: alarmId, reminderId: reminderId, auto: false)
            AlarmStore.shared.remove(alarmId)

        case snoozeActionId:
            guard var alarm = AlarmStore.shared.get(alarmId) else { return }
            if alarm.snoozeCount >= alarm.maxSnoozeCount {
                emitDismissed(alarmId: alarmId, reminderId: reminderId, auto: true)
                AlarmStore.shared.remove(alarmId)
            } else {
                alarm.scheduledAt = Int(Date().timeIntervalSince1970 * 1000)
                    + alarm.snoozeMinutes * 60_000
                alarm.snoozeCount += 1
                AlarmStore.shared.put(alarm)
                schedule(alarm)
                AlarmEventBus.shared.emit([
                    "type": "snoozed",
                    "alarmId": alarmId,
                    "reminderId": reminderId,
                    "snoozeCount": alarm.snoozeCount,
                ])
            }

        case UNNotificationDismissActionIdentifier:
            emitDismissed(alarmId: alarmId, reminderId: reminderId, auto: false)
            AlarmStore.shared.remove(alarmId)

        default:
            break
        }
    }

    // MARK: - Private

    private func emitDismissed(alarmId: Int, reminderId: String, auto: Bool) {
        AlarmEventBus.shared.emit([
            "type": "dismissed",
            "alarmId": alarmId,
            "reminderId": reminderId,
            "auto": auto,
        ])
    }
}
