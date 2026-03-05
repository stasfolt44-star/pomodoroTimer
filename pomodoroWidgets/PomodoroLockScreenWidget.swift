import WidgetKit
import SwiftUI

struct LockScreenEntry: TimelineEntry {
    let date: Date
    let phase: String
    let remainingSeconds: Int
    let isRunning: Bool
}

struct LockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScreenEntry {
        LockScreenEntry(date: .now, phase: "Focus", remainingSeconds: 25 * 60, isRunning: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (LockScreenEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScreenEntry>) -> Void) {
        let entry = LockScreenEntry(date: .now, phase: "Focus", remainingSeconds: 25 * 60, isRunning: false)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60)))
        completion(timeline)
    }
}

struct PomodoroLockScreenWidget: Widget {
    let kind = "PomodoroLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pomodoro Timer")
        .description("See your timer status at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

struct LockScreenWidgetView: View {
    let entry: LockScreenEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryInline:
            inlineView
        case .accessoryRectangular:
            rectangularView
        default:
            circularView
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "brain.head.profile")
                    .font(.caption)
                Text(timeString)
                    .font(.system(.caption, design: .rounded))
                    .monospacedDigit()
            }
        }
    }

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "brain.head.profile")
            Text("\(entry.phase) — \(timeString)")
        }
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.phase)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.medium)
            Text(timeString)
                .font(.system(.title2, design: .rounded))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timeString: String {
        let m = entry.remainingSeconds / 60
        let s = entry.remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
