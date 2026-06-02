import Foundation

enum PomodoroPhase: String, Codable, Equatable, CaseIterable, Identifiable {
    case work

    var id: String { rawValue }

    var displayName: String { "Focus" }
    var symbolName: String { "brain.head.profile" }
}
