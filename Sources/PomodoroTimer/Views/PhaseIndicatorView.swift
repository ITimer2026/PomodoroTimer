import SwiftUI

struct PhaseIndicatorView: View {
    let phase: PomodoroPhase

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: phase.symbolName)
            Text(phase.displayName)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(background)
        .foregroundStyle(foreground)
        .clipShape(Capsule())
    }

    private var background: Color {
        switch phase {
        case .work: return Color.red.opacity(0.18)
        case .shortBreak: return Color.green.opacity(0.18)
        case .longBreak: return Color.blue.opacity(0.18)
        }
    }

    private var foreground: Color {
        switch phase {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}
