import SwiftUI

@main
struct pomodoroTimerApp: App {
    @State private var settings = TimerSettings()
    @State private var themeManager = ThemeManager()
    @State private var storeManager = StoreManager()
    @State private var timer: TimerManager
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let s = TimerSettings()
        let tm = TimerManager(settings: s)
        tm.notificationManager = NotificationManager.shared

        NotificationManager.shared.onStartNext = { [weak tm] in
            tm?.start()
        }
        NotificationManager.shared.onSkip = { [weak tm] in
            tm?.skipPhase()
        }

        _settings = State(wrappedValue: s)
        _themeManager = State(wrappedValue: ThemeManager())
        _storeManager = State(wrappedValue: StoreManager())
        _timer = State(wrappedValue: tm)
    }

    var body: some Scene {
        WindowGroup {
            TimerView()
                .environment(settings)
                .environment(themeManager)
                .environment(storeManager)
                .environment(timer)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        timer.restoreOnForeground()
                    }
                }
        }
    }
}
