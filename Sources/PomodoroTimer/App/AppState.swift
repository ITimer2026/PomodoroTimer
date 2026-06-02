import Foundation
import Observation

@Observable
final class AppState {
    let timer: TimerEngine
    let settings: SettingsStore

    var todayCount: Int {
        didSet { saveTodayCount() }
    }

    init() {
        let settings = SettingsStore()
        self.settings = settings
        self.timer = TimerEngine(settings: settings.asSettings)

        // Load today's count
        let savedDate = UserDefaults.standard.string(forKey: "pomodoroDate")
        let today = Self.dateString()
        if savedDate == today {
            self.todayCount = UserDefaults.standard.integer(forKey: "pomodoroTodayCount")
        } else {
            self.todayCount = 0
            UserDefaults.standard.set(today, forKey: "pomodoroDate")
            UserDefaults.standard.set(0, forKey: "pomodoroTodayCount")
        }

        // Listen for timer completion
        timer.onPhaseComplete = { [weak self] phase, _ in
            if phase == .work {
                self?.todayCount += 1
            }
        }
    }

    private func saveTodayCount() {
        UserDefaults.standard.set(todayCount, forKey: "pomodoroTodayCount")
        UserDefaults.standard.set(Self.dateString(), forKey: "pomodoroDate")
    }

    private static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
