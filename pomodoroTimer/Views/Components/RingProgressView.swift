import SwiftUI

struct RingProgressView: View {
    let progress: Double
    let accentColor: Color
    let lineWidth: CGFloat

    init(progress: Double, accentColor: Color, lineWidth: CGFloat = 12) {
        self.progress = progress
        self.accentColor = accentColor
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    accentColor.opacity(0.15),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
}
