import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DataStore

    var body: some View {
        if store.hasCompletedOnboarding {
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
        } else {
            OnboardingContainerView()
        }
    }
}
