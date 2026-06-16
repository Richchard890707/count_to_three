import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

    // MARK: - Foreground reconciliation (Decision C)

    // When the app returns to foreground, compare AlarmStore vs AlarmKit's
    // live list. Any alarm that has vanished was stopped/snoozed via the
    // system UI; emit a Dismissed event so Drift DB can be updated.
    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        Task { await AlarmEngine.shared.detectHandledAlarms() }
    }
}
