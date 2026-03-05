import ActivityKit
import SwiftUI

enum PomodoroPhase: String, Codable, CaseIterable {
    case work
    case shortBreak
    case longBreak

    var title: String {
        switch self {
        case .work: "Focus"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        }
    }

    var defaultDuration: Int {
        switch self {
        case .work: 25 * 60
        case .shortBreak: 5 * 60
        case .longBreak: 15 * 60
        }
    }
}

struct PomodoroAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        var phase: PomodoroPhase
        var completedCount: Int
        var totalCount: Int
    }
}
