import SwiftUI

struct TimerView: View {
    @Environment(TimerManager.self) var timer
    @Environment(ThemeManager.self) var themeManager
    @State private var showSettings = false

    private var theme: AppTheme { themeManager.currentTheme }

    var body: some View {
        let bgColor = theme.backgroundColor(for: timer.currentPhase)
        let accent = theme.accentColor(for: timer.currentPhase)

        ZStack {
            bgColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: timer.currentPhase)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundStyle(theme.text.opacity(0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()

                Text(timer.currentPhase.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(theme.text.opacity(0.6))
                    .animation(.easeInOut(duration: 0.3), value: timer.currentPhase)

                Spacer().frame(height: 24)

                ZStack {
                    RingProgressView(
                        progress: timer.progress,
                        accentColor: accent,
                        lineWidth: 10
                    )

                    VStack(spacing: 8) {
                        Text(timeString(timer.remainingSeconds))
                            .font(.system(size: 64, weight: .light, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(theme.text)
                            .contentTransition(.numericText())

                        Text("\(timer.completedPomodoros + (timer.currentPhase == .work ? 1 : 0))/\(timer.settings.pomodorosUntilLongBreak)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(theme.text.opacity(0.4))
                    }
                }
                .frame(width: 280, height: 280)

                Spacer().frame(height: 20)

                PhaseIndicatorView(
                    completedCount: timer.completedPomodoros,
                    totalCount: timer.settings.pomodorosUntilLongBreak,
                    accentColor: accent
                )

                Spacer()

                TimerControlsView(
                    timerState: timer.state,
                    accentColor: accent,
                    textColor: theme.text,
                    onStart: { timer.start() },
                    onPause: { timer.pause() },
                    onReset: { timer.reset() },
                    onSkip: { timer.skipPhase() }
                )

                Spacer().frame(height: 60)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: Bindable(timer).shouldShowPaywall) {
            PaywallView()
                .interactiveDismissDisabled(false)
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
