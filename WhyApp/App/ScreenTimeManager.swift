import FamilyControls
import ManagedSettings
import SwiftUI

/// Handles Screen Time authorization and shield management.
@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published var isAuthorized = false
    @Published var authorizationError: String?

    private let store = ManagedSettingsStore()
    private let dataStore = SharedDataStore()

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
            authorizationError = nil
        } catch {
            isAuthorized = false
            authorizationError = error.localizedDescription
        }
    }

    // MARK: - Shield Management

    /// Apply shields to all blocked apps and websites.
    func applyShields() {
        let items = dataStore.blockedItems

        var appTokens = Set<ApplicationToken>()
        var webTokens = Set<WebDomainToken>()

        for item in items {
            if let token = item.applicationToken {
                appTokens.insert(token)
            }
            if let token = item.webDomainToken {
                webTokens.insert(token)
            }
        }

        store.shield.applications = appTokens.isEmpty ? nil : appTokens
        store.shield.webDomains = webTokens.isEmpty ? nil : webTokens
    }

    /// Remove shield for a specific item (temporarily).
    func unshield(item: BlockedItem) {
        if let token = item.applicationToken {
            store.shield.applications?.remove(token)
        }
        if let token = item.webDomainToken {
            store.shield.webDomains?.remove(token)
        }
    }

    /// Re-shield any items whose temporary access has expired,
    /// and mark their pending reasons as auto-resolved.
    func reshieldExpiredItems() {
        let expired = dataStore.expiredPendingReasons()
        for reason in expired {
            dataStore.resolvePendingReason(reason, whyYes: "(no reason provided — access expired)", proceeded: true)
        }
        if !expired.isEmpty {
            applyShields()
        }
    }
}
