import Flutter
import Foundation
import UserNotifications

final class AlarmPlugin: NSObject {
    static let shared = AlarmPlugin()
    private override init() {}

    func setup(messenger: FlutterBinaryMessenger) {
        let method = FlutterMethodChannel(name: "app.ontime/alarm", binaryMessenger: messenger)
        method.setMethodCallHandler(handleMethodCall(_:result:))

        let event = FlutterEventChannel(name: "app.ontime/alarm_events", binaryMessenger: messenger)
        event.setStreamHandler(AlarmEventBus.shared)
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
                maxSnoozeCount: args["maxSnoozeCount"] as? Int ?? 3
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

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Notification response forwarding (iOS ≤25)

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        NotificationFallback.shared.handleNotificationResponse(response)
    }
}
