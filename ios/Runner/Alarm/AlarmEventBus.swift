import Flutter
import Foundation

final class AlarmEventBus: NSObject, FlutterStreamHandler {
    static let shared = AlarmEventBus()
    private var sink: FlutterEventSink?
    private var pending: [[String: Any]] = []

    private override init() {}

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        let snapshot = pending
        pending.removeAll()
        snapshot.forEach { events($0) }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }

    func emit(_ event: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let sink = self.sink {
                sink(event)
            } else {
                self.pending.append(event)
            }
        }
    }
}
