import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @Environment(AppState.self) private var app
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                PhaseIndicatorView(phase: app.timer.phase)
                Spacer()
                Text("Today: \(app.history.countToday())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(format(app.timer.remaining))
                .font(.system(size: 56, weight: .light, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)

            HStack(spacing: 8) {
                Button(action: primaryAction) {
                    Label(app.timer.isRunning ? "Pause" : "Start",
                          systemImage: app.timer.isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)

                Button(action: { app.timer.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .help("Reset current phase")

                Button(action: { app.timer.skip() }) {
                    Image(systemName: "forward.end.fill")
                }
                .help("Skip to next phase")
            }

            Divider()

            HStack {
                Button("Open History…") {
                    openWindow(id: "history")
                    NSApp.activate(ignoringOtherApps: true)
                }
                Spacer()
                Button("Settings…") {
                    if #available(macOS 14, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }
            }
            .controlSize(.small)

            HStack {
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .controlSize(.small)
            }
        }
        .padding(16)
        .frame(width: 260)
    }

    private func primaryAction() {
        if app.timer.isRunning {
            app.timer.pause()
        } else {
            app.timer.start()
        }
    }

    private func format(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
