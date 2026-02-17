import SwiftUI

struct BlockedItemRow: View {
    let item: BlockedItem

    @EnvironmentObject var store: SharedDataStore

    private var attemptCount: Int {
        store.accessAttempts.filter { $0.blockedItemId == item.id }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.isApp ? "app.fill" : "globe")
                    .foregroundStyle(.blue)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.whyNot)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
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
        }
        .padding(.vertical, 4)
    }
}
