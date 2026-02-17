import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if store.blockedItems.isEmpty {
                    ContentUnavailableView(
                        "Nothing blocked yet",
                        systemImage: "shield",
                        description: Text("Add apps or websites you want to stay away from.")
                    )
                } else {
                    List {
                        ForEach(store.blockedItems) { item in
                            BlockedItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                store.removeBlockedItem(store.blockedItems[index])
                            }
                            screenTime.applyShields()
                        }
                    }
                }
            }
            .navigationTitle("Why Not?")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddBlockedItemView()
            }
        }
    }
}
