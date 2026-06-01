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
        self.timer.onPhaseComplete = { [weak self] phase, endedAt in
            self?.history.recordCompletion(at: endedAt, phase: phase)
        }
    }
}
