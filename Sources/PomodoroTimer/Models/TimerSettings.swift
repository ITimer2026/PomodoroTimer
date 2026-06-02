import Foundation

struct TimerSettings: Codable, Equatable {
    var workMinutes: Int

    static let `default` = TimerSettings(workMinutes: 25)

    var duration: TimeInterval {
        TimeInterval(workMinutes) * 60
    }
}
