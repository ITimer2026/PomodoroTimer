import SwiftUI
import Charts

enum HistoryTab: String, CaseIterable, Identifiable {
    case today, thisWeek, thisMonth, thisYear
    var id: String { rawValue }
    var label: String {
        switch self {
        case .today: return "今日"
        case .thisWeek: return "本周"
        case .thisMonth: return "本月"
        case .thisYear: return "今年"
        }
    }
}

struct HistoryRootView: View {
    @Environment(AppState.self) private var app
    @State private var tab: HistoryTab = .today
    @State private var showClearConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Picker("View", selection: $tab) {
                ForEach(HistoryTab.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Divider().padding(.top, 12)

            Group {
                switch tab {
                case .today:     TodayView()
                case .thisWeek:  ThisWeekView()
                case .thisMonth: ThisMonthView()
                case .thisYear:  ThisYearView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            footer
        }
        .navigationTitle("历史")
        .confirmationDialog(
            "清除所有历史记录？",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("全部清除", role: .destructive) {
                app.history.resetAll()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("这将永久删除所有记录，无法恢复。")
        }
    }

    private var footer: some View {
        HStack {
            Text("累计：\(app.history.sessions.filter { $0.phase == .work }.count) 次")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("清除历史", role: .destructive) {
                showClearConfirm = true
            }
            .controlSize(.small)
            .disabled(app.history.sessions.isEmpty && app.history.legacyDayTotals.isEmpty)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

/// Shared chrome: large total number + small caption above the chart.
struct HistoryHeader: View {
    let total: Int
    let caption: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(total)")
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(total > 0 ? .primary : .secondary)
                Text("个番茄钟")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

/// Shared empty state.
struct HistoryEmpty: View {
    let message: String
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Modifier that gives all charts a consistent Apple-minimal look.
struct ChartStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .chartPlotStyle { plot in
                plot
                    .background(Color.clear)
                    .padding(.horizontal, 8)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(.quaternary)
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
    }
}

extension View {
    func historyChartStyle() -> some View { modifier(ChartStyleModifier()) }
}
