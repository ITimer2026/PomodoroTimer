import Foundation

struct DayRecord: Codable, Identifiable, Hashable {
    let date: String
    var completed: Int

    var id: String { date }

    init(date: String, completed: Int) {
        self.date = date
        self.completed = completed
    }

    init(date: Date, completed: Int, timeZone: TimeZone = .current) {
        self.init(
            date: DayRecord.dateFormatter(for: timeZone).string(from: date),
            completed: completed
        )
    }

    static func todayString(in timeZone: TimeZone = .current) -> String {
        dateFormatter(for: timeZone).string(from: Date())
    }

    private static func dateFormatter(for timeZone: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = timeZone
        f.dateFormat = "yyyy-MM-dd"
        return f
    }
}
