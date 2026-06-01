import Foundation
import Observation

@Observable
final class HistoryStore {
    private(set) var sessions: [Session] = []
    private(set) var legacyDayTotals: [DayRecord] = []

    private let sessionsURL: URL
    private let historyURL: URL
    private let timeZone: TimeZone

    init(timeZone: TimeZone = .current) {
        self.timeZone = timeZone
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("PomodoroTimer", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        self.sessionsURL = base.appendingPathComponent("sessions.json")
        self.historyURL = base.appendingPathComponent("history.json")
        load()
    }

    // MARK: - Recording

    func recordCompletion(at date: Date, phase: PomodoroPhase) {
        sessions.append(Session(id: UUID(), startedAt: date, phase: phase))
        sessions.sort { $0.startedAt > $1.startedAt }
        save()
    }

    func resetAll() {
        sessions.removeAll()
        legacyDayTotals.removeAll()
        try? FileManager.default.removeItem(at: sessionsURL)
        try? FileManager.default.removeItem(at: historyURL)
    }

    // MARK: - Today count (used by popover)

    func countToday() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let sessionsToday = sessions.filter {
            $0.phase == .work && Calendar.current.startOfDay(for: $0.startedAt) == today
        }.count
        let legacyKey = DayRecord(date: today, completed: 0, timeZone: timeZone).date
        let legacyToday = legacyDayTotals.first(where: { $0.date == legacyKey })?.completed ?? 0
        return max(sessionsToday, legacyToday)
    }

    // MARK: - Aggregations (work-only)

    private var workSessions: [Session] {
        sessions.filter { $0.phase == .work }
    }

    func dailyTotals(in interval: DateInterval, calendar: Calendar) -> [(date: Date, count: Int)] {
        let bucket: [Date: Int] = Dictionary(grouping: workSessions) { session in
            calendar.startOfDay(for: session.startedAt)
        }.mapValues { $0.count }

        var result: [(Date, Int)] = []
        var day = calendar.startOfDay(for: interval.start)
        let end = calendar.startOfDay(for: interval.end)
        while day <= end {
            result.append((day, bucket[day] ?? 0))
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }

    func weeklyTotals(in interval: DateInterval, calendar: Calendar) -> [(weekStart: Date, count: Int)] {
        var cal = calendar
        cal.firstWeekday = 2 // Monday

        let bucket: [Date: Int] = Dictionary(grouping: workSessions) { session in
            cal.dateInterval(of: .weekOfYear, for: session.startedAt)?.start ?? session.startedAt
        }.mapValues { $0.count }

        var result: [(Date, Int)] = []
        var week = cal.dateInterval(of: .weekOfYear, for: interval.start)?.start ?? interval.start
        let endWeek = cal.dateInterval(of: .weekOfYear, for: interval.end)?.start ?? interval.end
        while week <= endWeek {
            result.append((week, bucket[week] ?? 0))
            guard let next = cal.date(byAdding: .weekOfYear, value: 1, to: week) else { break }
            week = next
        }
        return result
    }

    func monthlyTotals(in interval: DateInterval, calendar: Calendar) -> [(monthStart: Date, count: Int)] {
        let bucket: [Date: Int] = Dictionary(grouping: workSessions) { session in
            calendar.dateInterval(of: .month, for: session.startedAt)?.start ?? session.startedAt
        }.mapValues { $0.count }

        var result: [(Date, Int)] = []
        var month = calendar.dateInterval(of: .month, for: interval.start)?.start ?? interval.start
        let endMonth = calendar.dateInterval(of: .month, for: interval.end)?.start ?? interval.end
        while month <= endMonth {
            result.append((month, bucket[month] ?? 0))
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return result
    }

    /// Returns a fixed 7×24 matrix indexed [weekday-1][hour].
    /// Weekday: 1=Sunday ... 7=Saturday (Gregorian default).
    /// No time window — aggregates all `.work` sessions.
    func hourOfWeekTotals(calendar: Calendar) -> [[Int]] {
        var grid = Array(repeating: Array(repeating: 0, count: 24), count: 7)
        for session in workSessions {
            let weekday = calendar.component(.weekday, from: session.startedAt) - 1 // 0..6
            let hour = calendar.component(.hour, from: session.startedAt)
            guard weekday >= 0, weekday < 7, hour >= 0, hour < 24 else { continue }
            grid[weekday][hour] += 1
        }
        return grid
    }

    /// Hourly totals (0-23) for sessions within a given date interval. Used for "Today" view.
    /// Returns `[(hour: Int, count: Int)]` with zero-fill for missing hours.
    func hourlyTotals(in interval: DateInterval, calendar: Calendar) -> [(hour: Int, count: Int)] {
        let inRange = workSessions.filter { interval.contains($0.startedAt) }
        var bucket = Array(repeating: 0, count: 24)
        for session in inRange {
            let h = calendar.component(.hour, from: session.startedAt)
            if h >= 0 && h < 24 { bucket[h] += 1 }
        }
        return (0..<24).map { (hour: $0, count: bucket[$0]) }
    }

    // MARK: - Persistence

    private func load() {
        // sessions.json (new format)
        if let data = try? Data(contentsOf: sessionsURL) {
            struct Wrapper: Codable { let sessions: [Session] }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let wrapper = try? decoder.decode(Wrapper.self, from: data) {
                self.sessions = wrapper.sessions.sorted { $0.startedAt > $1.startedAt }
            }
        }
        // history.json (v1 format, read-only)
        if let data = try? Data(contentsOf: historyURL) {
            struct Wrapper: Codable { let records: [DayRecord] }
            if let wrapper = try? JSONDecoder().decode(Wrapper.self, from: data) {
                self.legacyDayTotals = wrapper.records
            }
        }
    }

    private func save() {
        struct Wrapper: Codable { let sessions: [Session] }
        let wrapper = Wrapper(sessions: sessions)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(wrapper) else { return }
        try? data.write(to: sessionsURL, options: [.atomic])
    }
}
