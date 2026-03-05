import SwiftUI
import Observation

@Observable
final class ThemeManager {
    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.id, forKey: "selectedTheme")
        }
    }

    init() {
        let savedId = UserDefaults.standard.string(forKey: "selectedTheme") ?? "midnight"
        self.currentTheme = AppTheme.all.first { $0.id == savedId } ?? .midnight
    }
}
