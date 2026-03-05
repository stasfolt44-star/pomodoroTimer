import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {

    static let shared = LiveActivityManager()
    private var currentActivity: Activity<PomodoroAttributes>?

    private init() {}

    func start(endDate: Date, phase: PomodoroPhase, completedCount: Int, totalCount: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let state = PomodoroAttributes.ContentState(
            endDate: endDate,
            phase: phase,
            completedCount: completedCount,
            totalCount: totalCount
        )

        let content = ActivityContent(state: state, staleDate: endDate)
        let attributes = PomodoroAttributes()

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Live Activity start failed: \(error)")
        }
    }

    func update(endDate: Date, phase: PomodoroPhase, completedCount: Int, totalCount: Int) {
        let state = PomodoroAttributes.ContentState(
            endDate: endDate,
            phase: phase,
            completedCount: completedCount,
            totalCount: totalCount
        )
        let content = ActivityContent(state: state, staleDate: endDate)

        Task {
            await currentActivity?.update(content)
        }
    }

    func stop() {
        let finalState = PomodoroAttributes.ContentState(
            endDate: .now,
            phase: .work,
            completedCount: 0,
            totalCount: 4
        )
        let content = ActivityContent(state: finalState, staleDate: nil)

        Task {
            // End tracked activity
            await currentActivity?.end(content, dismissalPolicy: .immediate)
            currentActivity = nil

            // End any orphaned activities
            for activity in Activity<PomodoroAttributes>.activities {
                await activity.end(content, dismissalPolicy: .immediate)
            }
        }
    }
}
