import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingAddSheet = false
    @State private var selectedItem: BlockedItem?
    @State private var showingIntervention = false

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
                            BlockedItemRow(item: item) {
                                selectedItem = item
                                showingIntervention = true
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                store.removeBlockedItem(store.blockedItems[index])
                            }
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
            .sheet(isPresented: $showingIntervention) {
                if let item = selectedItem {
                    InterventionView(item: item)
                }
            }
        }
    }
}
