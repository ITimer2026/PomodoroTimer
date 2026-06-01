import SwiftUI
import Charts

struct ThisMonthView: View {
    @Environment(AppState.self) private var app

    private var rows: [(weekStart: Date, count: Int)] {
        let cal = Calendar.current
        var calMon = cal
        calMon.firstWeekday = 2
        let monthInterval = cal.dateInterval(of: .month, for: .now)
        let start = monthInterval?.start ?? cal.startOfDay(for: .now)
        return app.history.weeklyTotals(
            in: DateInterval(start: start, end: Date()),
            calendar: cal
        )
    }

    private var total: Int { rows.reduce(0) { $0 + $1.count } }

    private var monthLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f.string(from: .now)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HistoryHeader(total: total, caption: "\(monthLabel) · by week")

            if total == 0 {
                HistoryEmpty(message: "No pomodoros this month")
            } else {
                chart
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
        }
    }

    private var chart: some View {
        Chart(rows, id: \.weekStart) { row in
            BarMark(
                x: .value("Week", row.weekStart, unit: .weekOfYear),
                y: .value("Pomodoros", row.count),
                width: .ratio(0.5)
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
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: rows.map { $0.weekStart }) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let d = value.as(Date.self) {
                        Text(d, format: .dateTime.month(.abbreviated).day())
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
