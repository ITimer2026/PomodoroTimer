import SwiftUI
import Charts

struct ThisYearView: View {
    @Environment(AppState.self) private var app

    private var rows: [(monthStart: Date, count: Int)] {
        let cal = Calendar.current
        let yearInterval = cal.dateInterval(of: .year, for: .now)
        let start = yearInterval?.start ?? cal.startOfDay(for: .now)
        return app.history.monthlyTotals(
            in: DateInterval(start: start, end: Date()),
            calendar: cal
        )
    }

    private var total: Int { rows.reduce(0) { $0 + $1.count } }

    private var yearLabel: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f.string(from: .now)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HistoryHeader(total: total, caption: "\(yearLabel) · 按月")

            if total == 0 {
                HistoryEmpty(message: "今年还没有完成的番茄钟")
            } else {
                chart
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
        }
    }

    private var chart: some View {
        Chart(rows, id: \.monthStart) { row in
            BarMark(
                x: .value("Month", row.monthStart, unit: .month),
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
            AxisMarks(values: rows.map { $0.monthStart }) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let d = value.as(Date.self) {
                        Text(d, format: .dateTime.month(.abbreviated))
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
