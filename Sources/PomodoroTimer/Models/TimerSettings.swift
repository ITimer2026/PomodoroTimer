import Foundation

struct TimerSettings: Codable, Equatable {
    var workMinutes: Int
    var shortBreakMinutes: Int
    var longBreakMinutes: Int
    var cyclesBeforeLongBreak: Int

    static let `default` = TimerSettings(
        workMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 15,
        cyclesBeforeLongBreak: 4
    )

    func duration(for phase: PomodoroPhase) -> TimeInterval {
        let minutes: Int
        switch phase {
        case .work: minutes = workMinutes
        case .shortBreak: minutes = shortBreakMinutes
        case .longBreak: minutes = longBreakMinutes
        }
        return TimeInterval(minutes) * 60
    }
}
