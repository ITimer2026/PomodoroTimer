import Foundation
import Observation

@Observable
final class AppState {
    let timer: TimerEngine
    let history: HistoryStore
    let settings: SettingsStore

    init() {
        let settings = SettingsStore()
        self.settings = settings
        self.history = HistoryStore()
        self.timer = TimerEngine(settings: settings.asSettings)
        self.timer.onWorkSessionComplete = { [weak self] in
            self?.history.recordCompletion()
        }
    }
}
