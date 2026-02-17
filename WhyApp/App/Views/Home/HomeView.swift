import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager
    @State private var showingAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Why Not?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.whyPrimary)
                    Text("\(store.blockedItems.count) item\(store.blockedItems.count == 1 ? "" : "s") blocked")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                }

                Spacer()

                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.whyWarm)
                        .frame(width: 40, height: 40)
                        .background(Color.whyWarm.opacity(0.12))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)

            if store.blockedItems.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.whySurface)
                            .frame(width: 100, height: 100)
                        Image(systemName: "shield")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.whyTertiary)
                    }
                    Text("Nothing blocked yet")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.whyPrimary)
                    Text("Add apps or websites you\nwant to stay away from.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    WhyButton(title: "Add Your First Item") {
                        showingAddSheet = true
                    }
                    .padding(.horizontal, 48)
                    .padding(.top, 8)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.blockedItems) { item in
                            BlockedItemRow(
                                item: item,
                                onDelete: {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        store.removeBlockedItem(item)
                                        screenTime.applyShields()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .whyBackground()
        .sheet(isPresented: $showingAddSheet) {
            AddBlockedItemView()
        }
    }
}
