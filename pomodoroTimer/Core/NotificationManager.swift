import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    // Action & category identifiers
    private enum ActionID {
        static let startNext = "START_NEXT"
        static let skip = "SKIP_PHASE"
    }
    private enum CategoryID {
        static let phaseEnd = "PHASE_END"
    }

    /// Called from TimerManager when user taps a notification action
    var onStartNext: (() -> Void)?
    var onSkip: (() -> Void)?

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }

    // MARK: - Categories & Actions

    private func registerCategories() {
        let startAction = UNNotificationAction(
            identifier: ActionID.startNext,
            title: NSLocalizedString("Start", comment: "Notification action"),
            options: .foreground
        )

        let skipAction = UNNotificationAction(
            identifier: ActionID.skip,
            title: NSLocalizedString("Skip", comment: "Notification action"),
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: CategoryID.phaseEnd,
            actions: [startAction, skipAction],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Schedule

    func schedulePhaseEnd(in interval: TimeInterval, phase: PomodoroPhase, sound: NotificationSound = .systemDefault) {
        cancelPending()

        let content = UNMutableNotificationContent()

        switch phase {
        case .work:
            content.title = String(localized: "Time's up!")
            content.body = String(localized: "Great focus session. Take a break.")
        case .shortBreak:
            content.title = String(localized: "Break is over")
            content.body = String(localized: "Ready to focus again?")
        case .longBreak:
            content.title = String(localized: "Long break is over")
            content.body = String(localized: "Let's get back to work!")
        }

        content.sound = sound.notificationSound
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = CategoryID.phaseEnd

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, interval),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "phaseEnd",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelPending() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["phaseEnd"]
        )
    }

    // MARK: - Delegate: foreground display

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.sound, .banner]
    }

    // MARK: - Delegate: action response

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        switch response.actionIdentifier {
        case ActionID.startNext:
            await MainActor.run { onStartNext?() }
        case ActionID.skip:
            await MainActor.run { onSkip?() }
        default:
            break
        }
    }
}
