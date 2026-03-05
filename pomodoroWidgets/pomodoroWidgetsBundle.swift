import WidgetKit
import SwiftUI

@main
struct pomodoroWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PomodoroLockScreenWidget()
        PomodoroHomeWidget()
        PomodoroLiveActivity()
    }
}
