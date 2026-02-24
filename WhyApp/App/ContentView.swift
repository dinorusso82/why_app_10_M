import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var currentPending: PendingReason?
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingContainerView()
                    .transition(.opacity)
            } else if let pending = currentPending {
                PendingReasonView(pendingReason: pending) {
                    loadNextPending()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                mainTabs
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: store.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.3), value: currentPending?.id)
        .onAppear {
            screenTime.reshieldExpiredItems()
            screenTime.startReshieldTimer()
            reloadData()
            loadNextPending()
            styleTabBar()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // Pick up any changes made by shield extensions while in background.
                reloadData()
                screenTime.reshieldExpiredItems()
                screenTime.startReshieldTimer()
                loadNextPending()
            case .background:
                screenTime.stopReshieldTimer()
            default:
                break
            }
        }
    }

    @ViewBuilder
    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Image(systemName: "shield.fill")
                    Text("My List")
                }

            LogView()
                .tag(1)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Log")
                }
        }
        .tint(Color.whyWarm)
    }

    private func reloadData() {
        store.reload()
    }

    private func loadNextPending() {
        currentPending = store.pendingReasons.first
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.whyCream)
        appearance.shadowColor = UIColor(Color.whyDivider)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
