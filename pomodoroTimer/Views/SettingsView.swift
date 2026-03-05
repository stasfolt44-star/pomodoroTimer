import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(TimerSettings.self) var settings
    @Environment(ThemeManager.self) var themeManager
    @Environment(StoreManager.self) var store
    @Environment(TimerManager.self) var timer
    @Environment(\.dismiss) private var dismiss

    @State private var showPaywall = false
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            List {
                Section("Timer") {
                    DurationRow(
                        title: "Focus",
                        seconds: $settings.workDuration
                    )
                    DurationRow(
                        title: "Short Break",
                        seconds: $settings.shortBreakDuration
                    )
                    DurationRow(
                        title: "Long Break",
                        seconds: $settings.longBreakDuration
                    )
                }

                Section("Cycle") {
                    Stepper(
                        "Pomodoros: \(settings.pomodorosUntilLongBreak)",
                        value: $settings.pomodorosUntilLongBreak,
                        in: 2...8
                    )
                    Toggle("Auto-start next phase", isOn: $settings.autoStartNextPhase)
                }

                Section("Sound") {
                    ForEach(NotificationSound.allCases) { sound in
                        SoundRow(
                            sound: sound,
                            isSelected: settings.selectedSound == sound,
                            isPremiumUser: store.isPremium,
                            onSelect: {
                                if sound.isPremium && !store.isPremium {
                                    showPaywall = true
                                } else {
                                    settings.selectedSound = sound
                                    previewSound(sound)
                                }
                            }
                        )
                    }
                }

                Section("Theme") {
                    ForEach(AppTheme.all) { theme in
                        ThemeRow(
                            theme: theme,
                            isSelected: themeManager.currentTheme.id == theme.id,
                            onSelect: {
                                themeManager.currentTheme = theme
                            }
                        )
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func previewSound(_ sound: NotificationSound) {
        audioPlayer?.stop()
        guard let fileName = sound.fileName,
              let url = Bundle.main.url(forResource: fileName, withExtension: "caf") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }
}

// MARK: - Duration Row

private struct DurationRow: View {
    let title: String
    @Binding var seconds: Int

    private var minutes: Int { seconds / 60 }

    var body: some View {
        Stepper(
            "\(title): \(minutes) min",
            value: Binding(
                get: { minutes },
                set: { seconds = $0 * 60 }
            ),
            in: 1...120
        )
    }
}

// MARK: - Sound Row

private struct SoundRow: View {
    let sound: NotificationSound
    let isSelected: Bool
    let isPremiumUser: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "speaker.wave.2.fill" : "speaker.fill")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .frame(width: 24)

                Text(sound.displayName)
                    .foregroundStyle(.primary)

                if sound.isPremium {
                    Text("PRO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.orange))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

// MARK: - Theme Row

private struct ThemeRow: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle().fill(theme.background).frame(width: 20, height: 20)
                    Circle().fill(theme.accent).frame(width: 20, height: 20)
                }

                Text(theme.name)
                    .foregroundStyle(.primary)

                if theme.isPremium {
                    Text("PRO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.orange))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}
