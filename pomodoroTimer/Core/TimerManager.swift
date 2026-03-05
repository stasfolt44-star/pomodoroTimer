import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
final class TimerManager {

    enum TimerState {
        case idle
        case running
        case paused
    }

    // MARK: - Observed

    private(set) var state: TimerState = .idle
    private(set) var currentPhase: PomodoroPhase = .work
    private(set) var completedPomodoros: Int = 0
    private(set) var remainingSeconds: Int = 25 * 60
    private(set) var progress: Double = 0
    var shouldShowPaywall: Bool = false

    // MARK: - Dependencies

    var settings: TimerSettings
    var notificationManager: NotificationManager?

    // MARK: - Private

    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var pausedRemaining: Int?
    @ObservationIgnored private var displayLink: Timer?
    @ObservationIgnored private var totalDuration: Int = 25 * 60

    // MARK: - Init

    init(settings: TimerSettings) {
        self.settings = settings
        self.totalDuration = settings.workDuration
        self.remainingSeconds = settings.workDuration
    }

    // MARK: - Controls

    func start() {
        let duration = pausedRemaining ?? settings.duration(for: currentPhase)
        totalDuration = settings.duration(for: currentPhase)
        endDate = Date().addingTimeInterval(Double(duration))
        pausedRemaining = nil
        state = .running

        notificationManager?.schedulePhaseEnd(
            in: TimeInterval(duration),
            phase: currentPhase,
            sound: settings.selectedSound
        )

        LiveActivityManager.shared.start(
            endDate: endDate!,
            phase: currentPhase,
            completedCount: completedPomodoros,
            totalCount: settings.pomodorosUntilLongBreak
        )

        startDisplayLink()
    }

    func pause() {
        guard state == .running, let end = endDate else { return }
        pausedRemaining = max(0, Int(end.timeIntervalSinceNow))
        endDate = nil
        state = .paused

        notificationManager?.cancelPending()
        LiveActivityManager.shared.stop()
        stopDisplayLink()
    }

    func reset() {
        endDate = nil
        pausedRemaining = nil
        state = .idle
        currentPhase = .work
        completedPomodoros = 0
        totalDuration = settings.workDuration
        remainingSeconds = settings.workDuration
        progress = 0

        notificationManager?.cancelPending()
        LiveActivityManager.shared.stop()
        stopDisplayLink()
    }

    func skipPhase() {
        notificationManager?.cancelPending()
        stopDisplayLink()
        advancePhase()
    }

    // MARK: - Phase Logic

    private func advancePhase() {
        if currentPhase == .work {
            completedPomodoros += 1
        }

        let nextPhase: PomodoroPhase
        if currentPhase == .work {
            if completedPomodoros >= settings.pomodorosUntilLongBreak {
                nextPhase = .longBreak
                completedPomodoros = 0
                checkPaywallTrigger()
            } else {
                nextPhase = .shortBreak
            }
        } else {
            nextPhase = .work
        }

        currentPhase = nextPhase
        totalDuration = settings.duration(for: nextPhase)
        remainingSeconds = totalDuration
        progress = 0
        endDate = nil
        pausedRemaining = nil

        if settings.autoStartNextPhase {
            start()
        } else {
            state = .idle
        }
    }

    private func phaseCompleted() {
        stopDisplayLink()
        remainingSeconds = 0
        progress = 1.0

        HapticManager.phaseComplete()
        advancePhase()
    }

    // MARK: - Display Tick

    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func tick() {
        guard state == .running, let end = endDate else { return }
        let remaining = Int(ceil(end.timeIntervalSinceNow))

        if remaining <= 0 {
            phaseCompleted()
            return
        }

        remainingSeconds = remaining
        progress = 1.0 - Double(remaining) / Double(totalDuration)
    }

    // MARK: - Foreground Restore

    func restoreOnForeground() {
        guard state == .running else { return }
        tick()
        startDisplayLink()
    }

    // MARK: - Paywall

    private func checkPaywallTrigger() {
        let shown = UserDefaults.standard.bool(forKey: "paywallShown")
        if !shown {
            UserDefaults.standard.set(true, forKey: "paywallShown")
            shouldShowPaywall = true
        }
    }
}
