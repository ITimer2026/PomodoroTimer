import SwiftUI

struct StandaloneWindowView: View {
    @Environment(AppState.self) private var app
    @Binding var isPinned: Bool
    let onClose: () -> Void
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 0) {
            // Row 1: close + pin button (entire row hidden unless hovering)
            if isHovering {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 14, height: 14)
                            .background(Circle().fill(Color.secondary.opacity(0.2)))
                    }
                    .buttonStyle(.plain)
                    .help("关闭")

                    Spacer()

                    Button(action: { isPinned.toggle() }) {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("置顶")
                }
                .padding(.horizontal, 8)
                .padding(.top, 6)
                .padding(.bottom, 2)
                .transition(.opacity)
            }

            // Row 2: timer on left, buttons on right
            HStack {
                Text(format(app.timer.remaining))
                    .font(.system(size: 22, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Button(action: primaryAction) {
                        Image(systemName: app.timer.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .help(app.timer.isRunning ? "暂停" : "开始")

                    Button(action: { app.timer.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .help("重置")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .frame(width: 160)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
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
