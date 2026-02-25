import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager
    @Environment(\.scenePhase) var scenePhase

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
            reloadData()
            loadNextPending()
            styleTabBar()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            // Re-apply shields every time WhyApp comes to the foreground.
            // This is what re-locks a temporarily unshielded app after the
            // user has finished their session and returns here.
            reloadData()
            loadNextPending()
            screenTime.applyShields()
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

            StatsView()
                .tag(2)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
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
