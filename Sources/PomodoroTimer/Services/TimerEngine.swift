import Foundation
import Observation

@Observable
final class TimerEngine {
    private(set) var phase: PomodoroPhase = .work
    private(set) var remaining: TimeInterval
    private(set) var isRunning: Bool = false
    private(set) var completedWorkSessions: Int = 0

    var onWorkSessionComplete: (() -> Void)?

    private var settings: TimerSettings
    private var endDate: Date?
    private var task: Task<Void, Never>?

    init(settings: TimerSettings = .default) {
        self.settings = settings
        self.remaining = settings.duration(for: .work)
    }

    func updateSettings(_ newSettings: TimerSettings) {
        let oldWork = settings.workMinutes
        settings = newSettings
        if !isRunning {
            remaining = settings.duration(for: phase)
        }
        if isRunning,
           phase == .work,
           newSettings.workMinutes != oldWork,
           let end = endDate {
            let elapsed = Date().timeIntervalSince(startDateMinusDuration(originalEnd: end, originalDuration: settings.duration(for: .work)))
            remaining = max(0, Double(newSettings.workMinutes) * 60 - elapsed)
            endDate = Date().addingTimeInterval(remaining)
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        endDate = Date().addingTimeInterval(remaining)
        task = Task { [weak self] in await self?.runLoop() }
    }

    func pause() {
        guard isRunning else { return }
        if let end = endDate {
            remaining = max(0, end.timeIntervalSinceNow)
        }
        isRunning = false
        endDate = nil
        task?.cancel()
        task = nil
    }

    func reset() {
        task?.cancel()
        task = nil
        isRunning = false
        endDate = nil
        remaining = settings.duration(for: phase)
    }

    func skip() {
        task?.cancel()
        task = nil
        isRunning = false
        endDate = nil
        advancePhase()
        remaining = settings.duration(for: phase)
    }

    private func runLoop() async {
        while !Task.isCancelled, isRunning {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { break }
            await MainActor.run { self.tick() }
            if !isRunning { break }
        }
    }

    private func tick() {
        guard let end = endDate else { return }
        let newRemaining = end.timeIntervalSinceNow
        if newRemaining <= 0 {
            if phase == .work { onWorkSessionComplete?() }
            advancePhase()
            remaining = settings.duration(for: phase)
            isRunning = false
            endDate = nil
            task?.cancel()
            task = nil
        } else {
            remaining = newRemaining
        }
    }

    private func advancePhase() {
        if phase == .work {
            completedWorkSessions += 1
            phase = (completedWorkSessions % settings.cyclesBeforeLongBreak == 0) ? .longBreak : .shortBreak
        } else {
            phase = .work
            if phase == .work, completedWorkSessions >= settings.cyclesBeforeLongBreak {
                completedWorkSessions = 0
            }
        }
    }

    private func startDateMinusDuration(originalEnd: Date, originalDuration: TimeInterval) -> Date {
        originalEnd.addingTimeInterval(-originalDuration)
    }
}
