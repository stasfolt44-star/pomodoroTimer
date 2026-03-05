import ActivityKit
import Foundation

struct PomodoroAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        var phase: PomodoroPhase
        var completedCount: Int
        var totalCount: Int
    }
}
