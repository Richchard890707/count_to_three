import Foundation
import UserNotifications

/// iOS ≤25 fallback: schedules a UNNotificationRequest.
/// Without the Critical Alert entitlement (requires Apple approval),
/// the alarm can be silenced by the user. A UI banner should inform them
/// that iOS 26+ is needed for alarm-grade reliability.
final class NotificationFallback {
    static let shared = NotificationFallback()

    private let categoryId         = "ALARM_CATEGORY"
    private let stopActionId       = "ALARM_STOP"
    private let snoozeActionId     = "ALARM_SNOOZE"
    private let reminderCategoryId = "REMINDER_CATEGORY"
    private let completeActionId   = "REMINDER_COMPLETE"

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
        let alarmCategory = UNNotificationCategory(
            identifier: categoryId,
            actions: [stop, snooze],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        let complete = UNNotificationAction(
            identifier: completeActionId,
            title: "✓ 完成",
            options: [.foreground]
        )
        let reminderCategory = UNNotificationCategory(
            identifier: reminderCategoryId,
            actions: [complete],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current()
            .setNotificationCategories([alarmCategory, reminderCategory])
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

    // MARK: - Simple (NOTIFICATION-level, no actions)

    /// Schedules a plain banner notification without stop/snooze actions.
    /// Used for NOTIFICATION-grade reminders on iOS where FLN is not the delegate.
    func scheduleSimple(id: Int, reminderId: String, title: String, body: String?, triggerAtMs: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body ?? ""
        content.sound = .default
        content.categoryIdentifier = reminderCategoryId
        content.userInfo = ["notifId": id, "reminderId": reminderId, "scheduledAtMs": triggerAtMs]

        let triggerDate = Date(timeIntervalSince1970: Double(triggerAtMs) / 1000)
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "notif_\(id)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelSimple(id: Int) {
        let identifier = "notif_\(id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    // MARK: - Action handling (called from AppDelegate UNUserNotificationCenterDelegate)

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let info = response.notification.request.content.userInfo

        // NOTIFICATION-level simple notification (not an alarm): handle tap and "完成" action.
        if let reminderId    = info["reminderId"]    as? String,
           let scheduledAtMs = info["scheduledAtMs"] as? Int,
           info["alarmId"] == nil {
            let isDefaultTap = response.actionIdentifier == UNNotificationDefaultActionIdentifier
            let isComplete   = response.actionIdentifier == completeActionId
            if isDefaultTap || isComplete {
                AlarmEventBus.shared.emit([
                    "type": "notif_tapped",
                    "reminderId": reminderId,
                    "scheduledAtMs": scheduledAtMs,
                ])
            }
            return
        }

        guard let alarmId    = info["alarmId"]    as? Int,
              let reminderId = info["reminderId"] as? String else { return }

        switch response.actionIdentifier {
        case stopActionId:
            let scheduledAtMs = AlarmStore.shared.get(alarmId)?.scheduledAt ?? 0
            emitDismissed(alarmId: alarmId, reminderId: reminderId, scheduledAtMs: scheduledAtMs, auto: false)
            AlarmStore.shared.remove(alarmId)

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification body → bring to foreground and show ring screen
            if let alarm = AlarmStore.shared.get(alarmId) {
                AlarmEventBus.shared.emit([
                    "type": "fired",
                    "alarmId": alarmId,
                    "reminderId": alarm.reminderId,
                    "title": alarm.title,
                    "scheduledAtMs": alarm.scheduledAt,
                    "snoozeCount": alarm.snoozeCount,
                    "maxSnoozeCount": alarm.maxSnoozeCount,
                ])
            } else {
                emitDismissed(alarmId: alarmId, reminderId: reminderId, scheduledAtMs: 0, auto: false)
            }

        case snoozeActionId:
            let capturedAlarmId = alarmId
            Task { try? await AlarmEngine.shared.snooze(alarmId: capturedAlarmId) }

        case UNNotificationDismissActionIdentifier:
            let dismissScheduledAtMs = AlarmStore.shared.get(alarmId)?.scheduledAt ?? 0
            emitDismissed(alarmId: alarmId, reminderId: reminderId, scheduledAtMs: dismissScheduledAtMs, auto: false)
            AlarmStore.shared.remove(alarmId)

        default:
            break
        }
    }

    // MARK: - Private

    private func emitDismissed(alarmId: Int, reminderId: String, scheduledAtMs: Int, auto: Bool) {
        AlarmEventBus.shared.emit([
            "type": "dismissed",
            "alarmId": alarmId,
            "reminderId": reminderId,
            "scheduledAtMs": scheduledAtMs,
            "auto": auto,
        ])
    }
}
