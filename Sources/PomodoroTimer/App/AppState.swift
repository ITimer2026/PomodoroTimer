import Foundation
import Observation

@Observable
final class AppState {
    let timer: TimerEngine
    let settings: SettingsStore

    init() {
        let settings = SettingsStore()
        self.settings = settings
        self.timer = TimerEngine(settings: settings.asSettings)
    }
}
