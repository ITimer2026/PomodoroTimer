import SwiftUI

@main
struct PomodoroTimerApp: App {
    @State private var app = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environment(app)
        } label: {
            Image(systemName: app.timer.phase.symbolName)
        }
        .menuBarExtraStyle(.window)

        Window("History", id: "history") {
            HistoryView()
                .environment(app)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 420, height: 480)

        Settings {
            SettingsView()
                .environment(app)
        }
    }
}
