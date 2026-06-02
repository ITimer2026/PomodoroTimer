import SwiftUI
import Charts

struct ThisWeekView: View {
    @Environment(AppState.self) private var app

    private var rows: [(date: Date, count: Int)] {
        let cal = Calendar.current
        var calMon = cal
        calMon.firstWeekday = 2
        let weekInterval = calMon.dateInterval(of: .weekOfYear, for: .now)
        let start = weekInterval?.start ?? cal.startOfDay(for: .now)
        return app.history.dailyTotals(
            in: DateInterval(start: start, end: Date()),
            calendar: cal
        )
    }

    private var total: Int { rows.reduce(0) { $0 + $1.count } }

    private let weekdaySymbols = Calendar.current.veryShortStandaloneWeekdaySymbols

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HistoryHeader(total: total, caption: "本周 · 按天")

            if total == 0 {
                HistoryEmpty(message: "本周还没有完成的番茄钟")
            } else {
                chart
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
        }
    }

    private var chart: some View {
        Chart(rows, id: \.date) { row in
            BarMark(
                x: .value("Day", row.date, unit: .day),
                y: .value("Pomodoros", row.count),
                width: .ratio(0.55)
            )
            .cornerRadius(4)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.red.opacity(0.85), Color.red],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .annotation(position: .top, alignment: .center, spacing: 2) {
                if row.count > 0 {
                    Text("\(row.count)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: rows.map { $0.date }) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let d = value.as(Date.self) {
                        let wd = Calendar.current.component(.weekday, from: d)
                        let monFirstIdx = (wd + 5) % 7
                        Text(weekdaySymbols[monFirstIdx])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine().foregroundStyle(.quaternary)
                AxisValueLabel().font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
    }
}
