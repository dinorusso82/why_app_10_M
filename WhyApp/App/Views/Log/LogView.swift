import SwiftUI

struct LogView: View {
    @EnvironmentObject var store: SharedDataStore

    var body: some View {
        NavigationStack {
            Group {
                if store.accessAttempts.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "book.closed",
                        description: Text("When you try to open a blocked app, it'll be logged here.")
                    )
                } else {
                    List {
                        ForEach(store.accessAttempts) { attempt in
                            LogEntryRow(attempt: attempt)
                        }
                    }
                }
            }
            .navigationTitle("Log")
        }
    }
}

struct LogEntryRow: View {
    let attempt: AccessAttempt

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(attempt.blockedItemName)
                    .font(.headline)

                Spacer()

                Text(attempt.proceeded ? "Proceeded" : "Walked Away")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(attempt.proceeded ? .red : .green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(attempt.proceeded ? .red.opacity(0.1) : .green.opacity(0.1))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Why not:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(""\(attempt.whyNot)"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            if attempt.proceeded && !attempt.whyYes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Why yes:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                    Text(""\(attempt.whyYes)"")
                        .font(.subheadline)
                        .italic()
                }
            }

            Text(attempt.timestamp, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            + Text(" at ")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            + Text(attempt.timestamp, style: .time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
