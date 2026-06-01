import SwiftUI

struct HistoryView: View {
    @Environment(AppState.self) private var app
    @State private var showClearConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Table(app.history.records) {
                TableColumn("Date") { record in
                    Text(record.date)
                        .monospacedDigit()
                }
                TableColumn("Completed") { record in
                    Text("\(record.completed)")
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .frame(minWidth: 320, minHeight: 360)

            Divider()

            HStack {
                Text("Total: \(app.history.records.reduce(0) { $0 + $1.completed }) pomodoros")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear History", role: .destructive) {
                    showClearConfirm = true
                }
                .disabled(app.history.records.isEmpty)
            }
            .padding(12)
        }
        .navigationTitle("History")
        .confirmationDialog(
            "Clear all history?",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("Clear All", role: .destructive) {
                app.history.resetAll()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This permanently removes every recorded day. Cannot be undone.")
        }
    }
}
