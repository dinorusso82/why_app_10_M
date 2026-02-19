import SwiftUI
import FamilyControls

@main
struct WhyAppApp: App {
    @StateObject private var store: SharedDataStore
    @StateObject private var screenTime: ScreenTimeManager

    init() {
        let sharedStore = SharedDataStore()
        _store = StateObject(wrappedValue: sharedStore)
        _screenTime = StateObject(wrappedValue: ScreenTimeManager(dataStore: sharedStore))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(screenTime)
        }
    }
}
