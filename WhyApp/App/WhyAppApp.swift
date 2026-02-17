import SwiftUI
import FamilyControls

@main
struct WhyAppApp: App {
    @StateObject private var store = SharedDataStore()
    @StateObject private var screenTime = ScreenTimeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(screenTime)
        }
    }
}
