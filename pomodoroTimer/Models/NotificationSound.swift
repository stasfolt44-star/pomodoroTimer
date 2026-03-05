import UserNotifications

enum NotificationSound: String, CaseIterable, Codable, Identifiable {
    case systemDefault
    case bell
    case chime
    case gong
    case digital
    case softTone
    case ping
    case harp
    case woodblock

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .systemDefault: String(localized: "Default")
        case .bell: String(localized: "Bell")
        case .chime: String(localized: "Chime")
        case .gong: String(localized: "Gong")
        case .digital: String(localized: "Digital")
        case .softTone: String(localized: "Soft Tone")
        case .ping: String(localized: "Ping")
        case .harp: String(localized: "Harp")
        case .woodblock: String(localized: "Woodblock")
        }
    }

    var isPremium: Bool {
        switch self {
        case .systemDefault, .bell, .chime: false
        default: true
        }
    }

    var fileName: String? {
        switch self {
        case .systemDefault: nil
        default: rawValue
        }
    }

    var notificationSound: UNNotificationSound {
        guard let fileName else { return .default }
        return UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(fileName).caf"))
    }
}
