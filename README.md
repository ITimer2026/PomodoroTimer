# PomodoroTimer

A native macOS menu bar Pomodoro timer. No login, no network, no telemetry — all data stays local in `~/Library/Application Support/PomodoroTimer/`.

## Features

- **Work / Short break / Long break** cycle (default 25 / 5 / 15 min, configurable)
- **Menu bar resident** with a popover for Start / Pause / Reset / Skip
- **Today's pomodoro count** + **history window** with daily totals
- **No login, no account, no internet** — all settings in `UserDefaults`, history in local JSON
- **Ad-hoc signed** for personal local use

## Requirements

- macOS 14 (Sonoma) or later
- Swift 5.9+ (Xcode 15+ Command Line Tools, or full Xcode)
- For `swift test` (unit tests): full Xcode is required — Apple Command Line Tools alone do not ship the XCTest swiftmodule

## Build & run

```bash
cd /Users/song/PomodoroTimer
swift build
swift run PomodoroTimer
```

A timer icon appears in the menu bar (top right). Click it to open the popover.

## Quit

Cmd-Q from the popover window, or click **Quit** inside the popover.

## Storage

| What | Where |
| --- | --- |
| Settings (durations, cycle count) | `UserDefaults` (managed by SwiftUI `@AppStorage`) |
| History (daily pomodoro counts) | `~/Library/Application Support/PomodoroTimer/history.json` |

## Layout

```
Sources/PomodoroTimer/
  App/        @main entry, root AppState, scene composition
  Models/     PomodoroPhase, TimerSettings, DayRecord
  Services/   TimerEngine, HistoryStore, SettingsStore
  Views/      MenuBarContentView, HistoryView, SettingsView, PhaseIndicatorView
```

## License

Personal use.
