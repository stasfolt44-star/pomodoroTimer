import Foundation
import Observation

@Observable
final class TimerSettings {
    var workDuration: Int {
        didSet { UserDefaults.standard.set(workDuration, forKey: "workDuration") }
    }
    var shortBreakDuration: Int {
        didSet { UserDefaults.standard.set(shortBreakDuration, forKey: "shortBreakDuration") }
    }
    var longBreakDuration: Int {
        didSet { UserDefaults.standard.set(longBreakDuration, forKey: "longBreakDuration") }
    }
    var pomodorosUntilLongBreak: Int {
        didSet { UserDefaults.standard.set(pomodorosUntilLongBreak, forKey: "pomodorosUntilLongBreak") }
    }
    var autoStartNextPhase: Bool {
        didSet { UserDefaults.standard.set(autoStartNextPhase, forKey: "autoStartNextPhase") }
    }
    var selectedSound: NotificationSound {
        didSet { UserDefaults.standard.set(selectedSound.rawValue, forKey: "selectedSound") }
    }

    init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: "workDuration") == nil {
            defaults.set(25 * 60, forKey: "workDuration")
            defaults.set(5 * 60, forKey: "shortBreakDuration")
            defaults.set(15 * 60, forKey: "longBreakDuration")
            defaults.set(4, forKey: "pomodorosUntilLongBreak")
            defaults.set(false, forKey: "autoStartNextPhase")
        }

        self.workDuration = defaults.integer(forKey: "workDuration")
        self.shortBreakDuration = defaults.integer(forKey: "shortBreakDuration")
        self.longBreakDuration = defaults.integer(forKey: "longBreakDuration")
        self.pomodorosUntilLongBreak = defaults.integer(forKey: "pomodorosUntilLongBreak")
        self.autoStartNextPhase = defaults.bool(forKey: "autoStartNextPhase")
        if let soundRaw = defaults.string(forKey: "selectedSound"),
           let sound = NotificationSound(rawValue: soundRaw) {
            self.selectedSound = sound
        } else {
            self.selectedSound = .systemDefault
        }
    }

    func duration(for phase: PomodoroPhase) -> Int {
        switch phase {
        case .work: workDuration
        case .shortBreak: shortBreakDuration
        case .longBreak: longBreakDuration
        }
    }
}
