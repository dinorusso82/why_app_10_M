import SwiftUI

struct BlockedItemRow: View {
    let item: BlockedItem
    var onDelete: (() -> Void)?

    @EnvironmentObject var store: SharedDataStore
    @State private var showingDelete = false

    private var attemptCount: Int {
        store.accessAttempts.filter { $0.blockedItemId == item.id }.count
    }

    private var walkedAwayCount: Int {
        store.accessAttempts.filter { $0.blockedItemId == item.id && !$0.proceeded }.count
    }

    var body: some View {
        WhyCard {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.whySurface)
                            .frame(width: 48, height: 48)
                        Image(systemName: item.isApp ? "app.fill" : "globe")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.whyWarm)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.whyPrimary)
                        Text(item.whyNot)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.whySecondary)
                            .lineLimit(2)
                            .lineSpacing(2)
                    }

                    Spacer()

                    // Attempt stats
                    if attemptCount > 0 {
                        VStack(spacing: 2) {
                            Text("\(attemptCount)")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.whyWarm)
                            Text(attemptCount == 1 ? "attempt" : "attempts")
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.whyTertiary)
                        }
                    }
                }

                // Stats bar (only if there have been attempts)
                if attemptCount > 0 {
                    Divider()
                        .background(Color.whyDivider)
                        .padding(.vertical, 12)

                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.whySage)
                                .frame(width: 8, height: 8)
                            Text("Walked away \(walkedAwayCount)x")
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(Color.whySecondary)
                        }

                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.whyRose)
                                .frame(width: 8, height: 8)
                            Text("Proceeded \(attemptCount - walkedAwayCount)x")
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(Color.whySecondary)
                        }

                        Spacer()
                    }
                }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}
