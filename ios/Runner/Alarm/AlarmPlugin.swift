import AudioToolbox
import Flutter
import Foundation
import UIKit
import UserNotifications
#if canImport(AlarmKit)
import AlarmKit
#endif

final class AlarmPlugin: NSObject {
    static let shared = AlarmPlugin()
    private override init() {}

    func setup(messenger: FlutterBinaryMessenger) {
        let method = FlutterMethodChannel(name: "app.ontime/alarm", binaryMessenger: messenger)
        method.setMethodCallHandler(handleMethodCall(_:result:))

        let event = FlutterEventChannel(name: "app.ontime/alarm_events", binaryMessenger: messenger)
        event.setStreamHandler(AlarmEventBus.shared)

        // Register both ALARM and REMINDER UNNotificationCategories early
        // so action buttons appear even if requestPermission hasn't been called yet.
        NotificationFallback.shared.registerCategory()
    }

    // MARK: - MethodChannel handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "scheduleAlarm":
            guard
                let args        = call.arguments as? [String: Any],
                let alarmId     = args["alarmId"]     as? Int,
                let reminderId  = args["reminderId"]  as? String,
                let title       = args["title"]       as? String,
                let triggerAtMs = args["triggerAtMs"] as? Int
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                return
            }
            let alarm = AlarmData(
                id: alarmId,
                reminderId: reminderId,
                title: title,
                scheduledAt: triggerAtMs,
                snoozeCount: 0,
                snoozeMinutes: args["snoozeMinutes"]  as? Int ?? 5,
                maxSnoozeCount: args["maxSnoozeCount"] as? Int ?? 3,
                volumeRamp: args["volumeRamp"]  as? Bool ?? false,
                vibrate:    args["vibrate"]     as? Bool ?? true,
                ringtoneUri: args["ringtoneUri"] as? String
            )
            Task {
                await AlarmEngine.shared.requestPermission()
                do {
                    try await AlarmEngine.shared.schedule(alarm: alarm)
                    result(nil)
                } catch {
                    result(FlutterError(code: "SCHEDULE_FAILED", message: error.localizedDescription, details: nil))
                }
            }

        case "cancelAlarm":
            guard let alarmId = call.arguments as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected Int alarmId", details: nil))
                return
            }
            Task {
                do {
                    try await AlarmEngine.shared.cancel(alarmId: alarmId)
                    result(nil)
                } catch {
                    result(FlutterError(code: "CANCEL_FAILED", message: error.localizedDescription, details: nil))
                }
            }

        case "snoozeAlarm":
            guard let alarmId = call.arguments as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected Int alarmId", details: nil))
                return
            }
            Task {
                do {
                    try await AlarmEngine.shared.snooze(alarmId: alarmId)
                    result(nil)
                } catch {
                    result(FlutterError(code: "SNOOZE_FAILED", message: error.localizedDescription, details: nil))
                }
            }

        case "scheduleNotification":
            guard
                let args        = call.arguments as? [String: Any],
                let notifId     = args["id"]          as? Int,
                let reminderId  = args["reminderId"]  as? String,
                let title       = args["title"]       as? String,
                let triggerAtMs = args["triggerAtMs"] as? Int
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                return
            }
            NotificationFallback.shared.requestAuthorization { _ in }
            NotificationFallback.shared.scheduleSimple(
                id: notifId,
                reminderId: reminderId,
                title: title,
                body: args["body"] as? String,
                triggerAtMs: triggerAtMs
            )
            result(nil)

        case "cancelNotification":
            guard let notifId = call.arguments as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected Int id", details: nil))
                return
            }
            NotificationFallback.shared.cancelSimple(id: notifId)
            result(nil)

        case "getPendingAlarms":
            let alarms = AlarmStore.shared.getAll().map { a -> [String: Any] in
                ["alarmId": a.id, "reminderId": a.reminderId,
                 "title": a.title, "triggerAtMs": a.scheduledAt, "snoozeCount": a.snoozeCount]
            }
            result(alarms)

        case "requestPermission":
            Task {
                let granted = await AlarmEngine.shared.requestPermission()
                result(granted)
            }

        case "notif.checkAuthorized":
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let ok = settings.authorizationStatus == .authorized
                    || settings.authorizationStatus == .provisional
                DispatchQueue.main.async { result(ok) }
            }

        case "notif.openSettings":
            DispatchQueue.main.async {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            result(nil)

        case "alarm.testRing":
            // iOS: play system alarm sound + vibrate as preview
            AudioServicesPlayAlertSound(SystemSoundID(1304))
            result(nil)

        case "alarm.stopTestRing":
            // System sounds can't be stopped mid-play; no-op
            result(nil)

        case "alarmkit.isAuthorized":
            #if canImport(AlarmKit)
            if #available(iOS 26.1, *) {
                Task {
                    // AlarmManager.shared.alarms throws if not authorized — use as status probe.
                    let authorized = (try? AlarmManager.shared.alarms) != nil
                    result(authorized)
                }
                return
            }
            #endif
            result(true) // < iOS 26: no AlarmKit needed, UNNotification fallback handles it

        case "alarmkit.openSettings":
            DispatchQueue.main.async {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            result(nil)

        case "badge.setCount":
            let count = call.arguments as? Int ?? 0
            if #available(iOS 16.0, *) {
                Task {
                    try? await UNUserNotificationCenter.current().setBadgeCount(count)
                    result(nil)
                }
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = count
                    result(nil)
                }
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Notification response forwarding (iOS ≤25)

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        NotificationFallback.shared.handleNotificationResponse(response)
    }
}
