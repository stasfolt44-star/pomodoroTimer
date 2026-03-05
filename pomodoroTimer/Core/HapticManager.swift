import UIKit

enum HapticManager {

    static func tap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func phaseComplete() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
