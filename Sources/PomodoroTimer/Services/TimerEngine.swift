import Foundation
import Observation

@Observable
final class TimerEngine {
    private(set) var phase: PomodoroPhase = .work
    private(set) var remaining: TimeInterval
    private(set) var isRunning: Bool = false

    var onPhaseComplete: ((PomodoroPhase, Date) -> Void)?

    private var settings: TimerSettings
    private var endDate: Date?
    private var task: Task<Void, Never>?

    init(settings: TimerSettings = .default) {
        self.settings = settings
        self.remaining = settings.duration
    }

    func updateSettings(_ newSettings: TimerSettings) {
        settings = newSettings
        if !isRunning {
            remaining = settings.duration
        }
    }

    func start() {
        guard !isRunning else { return }
        // If the previous run just hit zero, remaining is at full duration (set by tick()).
        // Defensive: if remaining somehow is 0 or negative, reset to full duration.
        if remaining <= 0 {
            remaining = settings.duration
        }
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
        remaining = settings.duration
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
            onPhaseComplete?(phase, Date())
            remaining = settings.duration
            isRunning = false
            endDate = nil
            task?.cancel()
            task = nil
        } else {
            remaining = newRemaining
        }
    }

    var progress: Double {
        let total = settings.duration
        guard total > 0 else { return 0 }
        return max(0, min(1, 1 - remaining / total))
    }
}
