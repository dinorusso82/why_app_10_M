import Foundation

enum AppConstants {
    /// Change this to match your App Group identifier in Xcode
    static let appGroupID = "group.com.whynot.shared"

    // Shared UserDefaults keys
    static let blockedItemsKey = "blocked_items"
    static let accessAttemptsKey = "access_attempts"
    static let pendingReasonsKey = "pending_reasons"
    static let onboardingCompleteKey = "onboarding_complete"

    /// How long (seconds) an app stays unshielded after the user requests access.
    /// After this, the shield is re-applied on next app launch.
    static let unshieldDurationSeconds: TimeInterval = 15 * 60 // 15 minutes
}
