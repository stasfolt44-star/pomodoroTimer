import ActivityKit
import WidgetKit
import SwiftUI

struct PomodoroLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroAttributes.self) { context in
            // Lock Screen / Banner view
            lockScreenView(context: context)
                .activityBackgroundTint(backgroundColor(for: context.state.phase))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.phase.title, systemImage: phaseIcon(context.state.phase))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.completedCount)/\(context.state.totalCount)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(
                        timerInterval: Date.now...context.state.endDate,
                        countsDown: true
                    )
                    .tint(accentColor(for: context.state.phase))
                }
            } compactLeading: {
                Image(systemName: phaseIcon(context.state.phase))
                    .foregroundStyle(accentColor(for: context.state.phase))
            } compactTrailing: {
                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                    .monospacedDigit()
                    .font(.caption)
                    .frame(width: 48)
            } minimal: {
                Image(systemName: phaseIcon(context.state.phase))
                    .foregroundStyle(accentColor(for: context.state.phase))
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<PomodoroAttributes>) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.phase.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.8))

                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(context.state.completedCount)/\(context.state.totalCount)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))

                // Phase dots
                HStack(spacing: 4) {
                    ForEach(0..<context.state.totalCount, id: \.self) { i in
                        Circle()
                            .fill(i < context.state.completedCount ? .white : .white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .padding(16)
    }

    // MARK: - Helpers

    private func phaseIcon(_ phase: PomodoroPhase) -> String {
        switch phase {
        case .work: "brain.head.profile"
        case .shortBreak: "cup.and.saucer"
        case .longBreak: "figure.walk"
        }
    }

    private func backgroundColor(for phase: PomodoroPhase) -> Color {
        switch phase {
        case .work: Color(red: 0.05, green: 0.05, blue: 0.05)
        case .shortBreak: Color(red: 0.1, green: 0.1, blue: 0.18)
        case .longBreak: Color(red: 0.1, green: 0.18, blue: 0.1)
        }
    }

    private func accentColor(for phase: PomodoroPhase) -> Color {
        switch phase {
        case .work: Color(red: 1.0, green: 0.42, blue: 0.21)
        case .shortBreak: Color(red: 0.91, green: 0.66, blue: 0.49)
        case .longBreak: Color(red: 0.36, green: 0.75, blue: 0.43)
        }
    }
}
