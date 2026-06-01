import Foundation

struct Session: Codable, Identifiable, Hashable {
    let id: UUID
    let startedAt: Date
    let phase: PomodoroPhase
}
