import Foundation
import SwiftUI

final class SettingsStore {
    @AppStorage("workMinutes") var workMinutes: Int = 25
    @AppStorage("shortBreakMinutes") var shortBreakMinutes: Int = 5
    @AppStorage("longBreakMinutes") var longBreakMinutes: Int = 15
    @AppStorage("cyclesBeforeLongBreak") var cyclesBeforeLongBreak: Int = 4

    var asSettings: TimerSettings {
        TimerSettings(
            workMinutes: workMinutes,
            shortBreakMinutes: shortBreakMinutes,
            longBreakMinutes: longBreakMinutes,
            cyclesBeforeLongBreak: cyclesBeforeLongBreak
        )
    }

    func update(from settings: TimerSettings) {
        workMinutes = settings.workMinutes
        shortBreakMinutes = settings.shortBreakMinutes
        longBreakMinutes = settings.longBreakMinutes
        cyclesBeforeLongBreak = settings.cyclesBeforeLongBreak
    }
}
