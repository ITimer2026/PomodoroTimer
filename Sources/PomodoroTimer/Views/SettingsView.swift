import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        Form {
            Section("时长") {
                Stepper(value: binding(\.workMinutes), in: 1...120) {
                    LabeledContent("专注") {
                        Text("\(app.settings.workMinutes) 分钟")
                            .monospacedDigit()
                    }
                }
            }

            Section {
                Text("倒计时归零后自动停止。再次点击「开始」即可进入下一轮。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 200)
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
