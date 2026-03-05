import SwiftUI

struct AppTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let background: Color
    let accent: Color
    let text: Color
    let breakBackground: Color
    let breakAccent: Color
    let isPremium: Bool

    func backgroundColor(for phase: PomodoroPhase) -> Color {
        phase == .work ? background : breakBackground
    }

    func accentColor(for phase: PomodoroPhase) -> Color {
        phase == .work ? accent : breakAccent
    }
}

extension AppTheme {
    static let midnight = AppTheme(
        id: "midnight",
        name: "Midnight",
        background: Color(hex: 0x0D0D0D),
        accent: Color(hex: 0xFF6B35),
        text: .white,
        breakBackground: Color(hex: 0x1A1A2E),
        breakAccent: Color(hex: 0xE8A87C),
        isPremium: false
    )

    static let sand = AppTheme(
        id: "sand",
        name: "Sand",
        background: Color(hex: 0xF5F0E8),
        accent: Color(hex: 0xC17D3C),
        text: Color(hex: 0x2C2416),
        breakBackground: Color(hex: 0xFAF7F2),
        breakAccent: Color(hex: 0x8FBC8F),
        isPremium: true
    )

    static let forest = AppTheme(
        id: "forest",
        name: "Forest",
        background: Color(hex: 0x1A2E1A),
        accent: Color(hex: 0x5DBF6E),
        text: Color(hex: 0xE8F5E8),
        breakBackground: Color(hex: 0x2E3D2E),
        breakAccent: Color(hex: 0xA8D8A8),
        isPremium: true
    )

    static let lavender = AppTheme(
        id: "lavender",
        name: "Lavender",
        background: Color(hex: 0x1E1B2E),
        accent: Color(hex: 0xB39DDB),
        text: Color(hex: 0xEDE7F6),
        breakBackground: Color(hex: 0x2D2840),
        breakAccent: Color(hex: 0xCE93D8),
        isPremium: true
    )

    static let all: [AppTheme] = [.midnight, .sand, .forest, .lavender]
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
