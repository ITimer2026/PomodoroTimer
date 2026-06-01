import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        Form {
            Section("Durations") {
                Stepper(value: binding(\.workMinutes), in: 1...120) {
                    LabeledContent("Focus") {
                        Text("\(app.settings.workMinutes) min")
                            .monospacedDigit()
                    }
                }
                Stepper(value: binding(\.shortBreakMinutes), in: 1...60) {
                    LabeledContent("Short Break") {
                        Text("\(app.settings.shortBreakMinutes) min")
                            .monospacedDigit()
                    }
                }
                Stepper(value: binding(\.longBreakMinutes), in: 1...120) {
                    LabeledContent("Long Break") {
                        Text("\(app.settings.longBreakMinutes) min")
                            .monospacedDigit()
                    }
                }
            }

            Section("Cycle") {
                Stepper(value: binding(\.cyclesBeforeLongBreak), in: 2...10) {
                    LabeledContent("Work sessions before long break") {
                        Text("\(app.settings.cyclesBeforeLongBreak)")
                            .monospacedDigit()
                    }
                }
            }

            Section {
                Text("Changes apply to the next phase. The currently running timer keeps its remaining time.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 360)
    }

    private func binding(_ keyPath: WritableKeyPath<TimerSettings, Int>) -> Binding<Int> {
        Binding(
            get: { app.settings.asSettings[keyPath: keyPath] },
            set: { newValue in
                var s = app.settings.asSettings
                s[keyPath: keyPath] = newValue
                app.settings.update(from: s)
                app.timer.updateSettings(s)
            }
        )
    }
}
