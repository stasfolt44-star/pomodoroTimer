import WidgetKit
import SwiftUI

struct HomeEntry: TimelineEntry {
    let date: Date
    let phase: String
    let remainingSeconds: Int
    let completedCount: Int
    let totalCount: Int
}

struct HomeProvider: TimelineProvider {
    func placeholder(in context: Context) -> HomeEntry {
        HomeEntry(date: .now, phase: "Focus", remainingSeconds: 25 * 60, completedCount: 0, totalCount: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (HomeEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HomeEntry>) -> Void) {
        let entry = HomeEntry(date: .now, phase: "Focus", remainingSeconds: 25 * 60, completedCount: 0, totalCount: 4)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60)))
        completion(timeline)
    }
}

struct PomodoroHomeWidget: Widget {
    let kind = "PomodoroHome"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HomeProvider()) { entry in
            HomeWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.05, green: 0.05, blue: 0.05)
                }
        }
        .configurationDisplayName("Pomodoro Timer")
        .description("Quick access to your timer.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HomeWidgetView: View {
    let entry: HomeEntry
    @Environment(\.widgetFamily) var family

    private let accent = Color(red: 1.0, green: 0.42, blue: 0.21)

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    // MARK: - Small

    private var smallView: some View {
        VStack(spacing: 12) {
            Text(entry.phase)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            Text(timeString)
                .font(.system(size: 36, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)

            phaseDots
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Medium

    private var mediumView: some View {
        HStack(spacing: 20) {
            // Ring + timer
            ZStack {
                Circle()
                    .stroke(accent.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(entry.remainingSeconds) / CGFloat(25 * 60))
                    .stroke(accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text(timeString)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .frame(width: 90, height: 90)

            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.phase)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)

                Text("Cycle")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))

                phaseDots
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Shared

    private var phaseDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<entry.totalCount, id: \.self) { i in
                Circle()
                    .fill(i < entry.completedCount ? accent : accent.opacity(0.25))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var timeString: String {
        let m = entry.remainingSeconds / 60
        let s = entry.remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
