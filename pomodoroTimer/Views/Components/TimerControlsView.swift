import SwiftUI

struct TimerControlsView: View {
    let timerState: TimerManager.TimerState
    let accentColor: Color
    let textColor: Color
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 32) {
            // Reset button
            Button(action: {
                HapticManager.tap()
                onReset()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundStyle(textColor.opacity(0.6))
                    .frame(width: 48, height: 48)
            }
            .opacity(timerState == .idle ? 0.3 : 1)
            .disabled(timerState == .idle)

            // Start / Pause button
            Button(action: {
                HapticManager.tap()
                if timerState == .running {
                    onPause()
                } else {
                    onStart()
                }
            }) {
                Image(systemName: timerState == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(timerState == .running ? accentColor : .white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(timerState == .running ? accentColor.opacity(0.15) : accentColor)
                    )
            }

            // Skip button
            Button(action: {
                HapticManager.tap()
                onSkip()
            }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(textColor.opacity(0.6))
                    .frame(width: 48, height: 48)
            }
            .opacity(timerState == .idle ? 0.3 : 1)
            .disabled(timerState == .idle)
        }
    }
}
