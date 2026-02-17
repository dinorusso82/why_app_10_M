import SwiftUI

struct BlockedItemRow: View {
    let item: BlockedItem
    var onAccessAttempt: () -> Void

    @EnvironmentObject var store: DataStore

    private var attemptCount: Int {
        store.attemptsFor(item: item).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.category == .website ? "globe" : "app.fill")
                    .foregroundStyle(.blue)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.headline)

                    Text(item.whyNot)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if attemptCount > 0 {
                    Text("\(attemptCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange)
                        .clipShape(Capsule())
                }
            }

            Button {
                onAccessAttempt()
            } label: {
                Text("I want to use this…")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
