import Foundation
import Observation

@Observable
final class HistoryStore {
    private(set) var records: [DayRecord] = []

    private let url: URL
    private let timeZone: TimeZone

    init(timeZone: TimeZone = .current) {
        self.timeZone = timeZone
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("PomodoroTimer", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        self.url = base.appendingPathComponent("history.json")
        load()
    }

    func countToday() -> Int {
        let today = DayRecord.todayString(in: timeZone)
        return records.first(where: { $0.date == today })?.completed ?? 0
    }

    func recordCompletion(at date: Date = Date()) {
        let key = DayRecord(date: date, completed: 0, timeZone: timeZone).date
        if let idx = records.firstIndex(where: { $0.date == key }) {
            records[idx].completed += 1
        } else {
            records.append(DayRecord(date: date, completed: 1, timeZone: timeZone))
        }
        records.sort { $0.date > $1.date }
        save()
    }

    func resetAll() {
        records.removeAll()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: url) else { return }
        struct Wrapper: Codable { let records: [DayRecord] }
        if let wrapper = try? JSONDecoder().decode(Wrapper.self, from: data) {
            self.records = wrapper.records.sorted { $0.date > $1.date }
        }
    }

    private func save() {
        struct Wrapper: Codable { let records: [DayRecord] }
        let wrapper = Wrapper(records: records)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(wrapper) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
