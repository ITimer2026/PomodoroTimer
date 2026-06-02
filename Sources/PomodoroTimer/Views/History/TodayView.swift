import SwiftUI
import Charts

struct TodayView: View {
    @Environment(AppState.self) private var app

    private var rows: [(hour: Int, count: Int)] {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: .now)
        return app.history.hourlyTotals(
            in: DateInterval(start: startOfDay, end: Date()),
            calendar: cal
        )
    }

    private var total: Int { rows.reduce(0) { $0 + $1.count } }

    private let weekdaySymbol = Calendar.current.veryShortStandaloneWeekdaySymbols[
        Calendar.current.component(.weekday, from: .now) - 1
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HistoryHeader(total: total, caption: "今日 \(weekdaySymbol) · 按小时")

            if total == 0 {
                HistoryEmpty(message: "今日还没有完成的番茄钟")
            } else {
                chart
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
        }
    }

    private var chart: some View {
        Chart(rows, id: \.hour) { row in
            BarMark(
                x: .value("Hour", row.hour),
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
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .historyChartStyle()
        .chartXAxis {
            AxisMarks(values: [0, 6, 12, 18]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let h = value.as(Int.self) {
                        Text(String(format: "%02d", h))
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
