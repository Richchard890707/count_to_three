import Flutter
import Foundation
import UIKit
import UniformTypeIdentifiers

final class DataPlugin: NSObject {
    static let shared = DataPlugin()
    private override init() {}

    private var pendingPickResult: FlutterResult?

    func setup(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "app.ontime/data", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "pickFile":
                self?.pickFile(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func pickFile(result: @escaping FlutterResult) {
        pendingPickResult = result
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
        } else {
            picker = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .import)
        }
        picker.delegate = self
        picker.allowsMultipleSelection = false

        DispatchQueue.main.async {
            guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else {
                result(nil)
                return
            }
            rootVC.present(picker, animated: true)
        }
    }
}

extension DataPlugin: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else {
            pendingPickResult?(nil)
            pendingPickResult = nil
            return
        }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            pendingPickResult?(content)
        } catch {
            pendingPickResult?(
                FlutterError(code: "READ_ERROR", message: error.localizedDescription, details: nil)
            )
        }
        pendingPickResult = nil
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        pendingPickResult?(nil)
        pendingPickResult = nil
    }
}
