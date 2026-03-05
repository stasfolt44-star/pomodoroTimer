import SwiftUI

struct PhaseIndicatorView: View {
    let completedCount: Int
    let totalCount: Int
    let accentColor: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalCount, id: \.self) { index in
                Circle()
                    .fill(index < completedCount ? accentColor : accentColor.opacity(0.25))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: completedCount)
            }
        }
    }
}
