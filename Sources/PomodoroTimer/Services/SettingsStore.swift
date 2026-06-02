import Foundation
import SwiftUI

final class SettingsStore {
    @AppStorage("workMinutes") var workMinutes: Int = 25

    var asSettings: TimerSettings {
        TimerSettings(workMinutes: workMinutes)
    }

    func update(from settings: TimerSettings) {
        workMinutes = settings.workMinutes
    }
}
