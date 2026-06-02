import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @Environment(AppState.self) private var app
    let onOpenStandalone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(format(app.timer.remaining))
                .font(.system(size: 56, weight: .light, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)

            HStack {
                Button(action: { app.timer.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 24, height: 24)
                }
                .help("重置")

                Spacer()

                Button(action: primaryAction) {
                    Image(systemName: app.timer.isRunning ? "pause.fill" : "play.fill")
                        .frame(width: 24, height: 24)
                }
                .keyboardShortcut(.defaultAction)

                Spacer()

                Button(action: onOpenStandalone) {
                    Image(systemName: "macwindow")
                        .frame(width: 24, height: 24)
                }
                .help("窗口化展示")
            }

            Divider()

            Text("今日已经完成 \(app.todayCount) 个番茄")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(
                    app.todayCount > 0
                    ? Color(red: 0.18, green: 0.78, blue: 0.44)
                    : Color.secondary
                )
                .tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .frame(width: 200)
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
