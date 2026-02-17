import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager

    @State private var currentPending: PendingReason?

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingContainerView()
            } else if let pending = currentPending {
                // Force the user to explain any pending reasons before using the app
                PendingReasonView(pendingReason: pending) {
                    loadNextPending()
                }
            } else {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("My List", systemImage: "shield.fill")
                        }

                    LogView()
                        .tabItem {
                            Label("Log", systemImage: "book.fill")
                        }
                }
            }
        }
        .onAppear {
            // Re-shield any items whose temporary access has expired
            screenTime.reshieldExpiredItems()
            // Reload store data (extensions may have written new pending reasons)
            reloadData()
            loadNextPending()
        }
    }

    private func reloadData() {
        // Re-initialize from shared storage to pick up changes made by extensions
        let fresh = SharedDataStore()
        store.blockedItems = fresh.blockedItems
        store.accessAttempts = fresh.accessAttempts
        store.pendingReasons = fresh.pendingReasons
    }

    private func loadNextPending() {
        currentPending = store.pendingReasons.first
    }
}
