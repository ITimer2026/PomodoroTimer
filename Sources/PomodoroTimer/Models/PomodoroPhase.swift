import Foundation

enum PomodoroPhase: String, Codable, Equatable, CaseIterable, Identifiable {
    case work
    case shortBreak
    case longBreak

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .work: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }

    var symbolName: String {
        switch self {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "leaf.fill"
        }
    }
}
