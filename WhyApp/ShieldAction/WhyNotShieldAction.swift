import ManagedSettings
import ManagedSettingsUI

/// Handles button taps on the shield overlay.
///
/// - Primary ("You're right — close it"): Dismisses the blocked app. Logged as "walked away".
/// - Secondary ("I need to use it…"): Creates a pending reason without lifting the shield.
///   The user must open WhyApp, explain why, and tap "Let me through" to gain access.
///
/// Note: ShieldActionExtension is unavailable in the iOS Simulator — guarded accordingly.
#if !targetEnvironment(simulator)
class WhyNotShieldAction: ShieldActionExtension {

    private let store = SharedDataStore()

    // MARK: - App Actions

    override func handle(
        action: ShieldAction,
        for application: Application,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // "You're right — close it"
            logWalkedAway(appToken: application.token)
            completionHandler(.close)

        case .secondaryButtonPressed:
            // "I need to use it…" — record pending reason; shield stays until reason is given in WhyApp
            if let token = application.token {
                createPendingReason(appToken: token)
            }
            completionHandler(.close)

        @unknown default:
            completionHandler(.close)
        }
    }

    // MARK: - Website Actions

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomain,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            logWalkedAway(webToken: webDomain.token)
            completionHandler(.close)

        case .secondaryButtonPressed:
            // "I need to use it…" — record pending reason; shield stays until reason is given in WhyApp
            if let token = webDomain.token {
                createPendingReason(webToken: token)
            }
            completionHandler(.close)

        @unknown default:
            completionHandler(.close)
        }
    }

    // MARK: - Helpers

    private func logWalkedAway(appToken: ApplicationToken? = nil, webToken: WebDomainToken? = nil) {
        let item: BlockedItem?
        if let appToken {
            item = store.blockedItems.first { $0.applicationToken == appToken }
        } else if let webToken {
            item = store.blockedItems.first { $0.webDomainToken == webToken }
        } else {
            item = nil
        }

        guard let item else { return }

        let attempt = AccessAttempt(
            blockedItemId: item.id,
            blockedItemName: item.name,
            whyNot: item.whyNot,
            whyYes: "",
            proceeded: false
        )
        store.logAttempt(attempt)
    }

    private func createPendingReason(appToken: ApplicationToken? = nil, webToken: WebDomainToken? = nil) {
        let item: BlockedItem?
        if let appToken {
            item = store.blockedItems.first { $0.applicationToken == appToken }
        } else if let webToken {
            item = store.blockedItems.first { $0.webDomainToken == webToken }
        } else {
            item = nil
        }

        guard let item else { return }

        let pending = PendingReason(
            blockedItemId: item.id,
            blockedItemName: item.name,
            whyNot: item.whyNot
        )
        store.addPendingReason(pending)
    }
}
#endif
