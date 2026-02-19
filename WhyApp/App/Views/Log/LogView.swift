import SwiftUI

struct LogView: View {
    @EnvironmentObject var store: SharedDataStore

    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Log")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.whyPrimary)
                    Text(summaryText)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)

            if store.accessAttempts.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.whySurface)
                            .frame(width: 100, height: 100)
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.whyTertiary)
                    }
                    Text("No entries yet")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.whyPrimary)
                    Text("When you try to open a blocked app,\nit'll be logged here.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.accessAttempts) { attempt in
                            LogEntryRow(attempt: attempt)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .whyBackground()
    }

    private var summaryText: String {
        let total = store.accessAttempts.count
        let walkedAway = store.accessAttempts.filter { !$0.proceeded }.count
        if total == 0 { return "Your history will appear here" }
        return "Walked away \(walkedAway) of \(total) time\(total == 1 ? "" : "s")"
    }
}

struct LogEntryRow: View {
    let attempt: AccessAttempt

    var body: some View {
        WhyCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(attempt.proceeded ? Color.whyRose.opacity(0.12) : Color.whySage.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: attempt.proceeded ? "arrow.right.circle" : "xmark.circle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(attempt.proceeded ? Color.whyRose : Color.whySage)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(attempt.blockedItemName)
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.whyPrimary)
                            Text(attempt.timestamp, style: .relative)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(Color.whyTertiary)
                        }
                    }

                    Spacer()

                    WhyTag(
                        text: attempt.proceeded ? "Proceeded" : "Walked Away",
                        color: attempt.proceeded ? .whyRose : .whySage
                    )
                }

                Divider()
                    .background(Color.whyDivider)

                // Why not
                VStack(alignment: .leading, spacing: 4) {
                    Text("WHY NOT")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.whyTertiary)
                        .tracking(0.5)

                    Text("\"\(attempt.whyNot)\"")
                        .font(.system(.caption, design: .rounded))
                        .italic()
                        .foregroundStyle(Color.whySecondary)
                        .lineSpacing(2)
                }

                // Why yes (if proceeded)
                if attempt.proceeded && !attempt.whyYes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("WHY YES")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.whyRose.opacity(0.6))
                            .tracking(0.5)

                        Text("\"\(attempt.whyYes)\"")
                            .font(.system(.caption, design: .rounded))
                            .italic()
                            .foregroundStyle(Color.whyPrimary)
                            .lineSpacing(2)
                    }
                }
            }
        }
    }
}
