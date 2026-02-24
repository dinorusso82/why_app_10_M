import Foundation
import Combine

/// Shared storage accessible by the main app AND shield extensions via App Group.
class SharedDataStore: ObservableObject {
    private let defaults: UserDefaults

    @Published var blockedItems: [BlockedItem] = []
    @Published var accessAttempts: [AccessAttempt] = []
    @Published var pendingReasons: [PendingReason] = []
    @Published var hasCompletedOnboarding: Bool

    init() {
        self.defaults = UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        self.hasCompletedOnboarding = defaults.bool(forKey: AppConstants.onboardingCompleteKey)
        self.blockedItems = Self.load(from: defaults, key: AppConstants.blockedItemsKey) ?? []
        self.accessAttempts = Self.load(from: defaults, key: AppConstants.accessAttemptsKey) ?? []
        self.pendingReasons = Self.load(from: defaults, key: AppConstants.pendingReasonsKey) ?? []
    }

    // MARK: - Blocked Items

    func addBlockedItem(_ item: BlockedItem) {
        blockedItems.append(item)
        save(blockedItems, key: AppConstants.blockedItemsKey)
    }

    func removeBlockedItem(_ item: BlockedItem) {
        blockedItems.removeAll { $0.id == item.id }
        save(blockedItems, key: AppConstants.blockedItemsKey)
    }

    // MARK: - Access Attempts

    func logAttempt(_ attempt: AccessAttempt) {
        accessAttempts.insert(attempt, at: 0)
        save(accessAttempts, key: AppConstants.accessAttemptsKey)
    }

    // MARK: - Pending Reasons

    func addPendingReason(_ reason: PendingReason) {
        pendingReasons.append(reason)
        save(pendingReasons, key: AppConstants.pendingReasonsKey)
    }

    func resolvePendingReason(_ reason: PendingReason, whyYes: String, proceeded: Bool) {
        // Log the attempt
        let attempt = AccessAttempt(
            blockedItemId: reason.blockedItemId,
            blockedItemName: reason.blockedItemName,
            whyNot: reason.whyNot,
            whyYes: whyYes,
            proceeded: proceeded
        )
        logAttempt(attempt)

        // Remove from pending
        pendingReasons.removeAll { $0.id == reason.id }
        save(pendingReasons, key: AppConstants.pendingReasonsKey)
    }

    func expiredPendingReasons() -> [PendingReason] {
        let cutoff = Date().addingTimeInterval(-AppConstants.unshieldDurationSeconds)
        return pendingReasons.filter { $0.unshieldedAt < cutoff }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: AppConstants.onboardingCompleteKey)
    }

    // MARK: - Reload from Disk

    /// Re-read all data from UserDefaults (picks up changes made by shield extensions).
    func reload() {
        blockedItems = Self.load(from: defaults, key: AppConstants.blockedItemsKey) ?? []
        accessAttempts = Self.load(from: defaults, key: AppConstants.accessAttemptsKey) ?? []
        pendingReasons = Self.load(from: defaults, key: AppConstants.pendingReasonsKey) ?? []
        hasCompletedOnboarding = defaults.bool(forKey: AppConstants.onboardingCompleteKey)
    }

    // MARK: - Persistence

    private func save<T: Codable>(_ value: T, key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            defaults.set(data, forKey: key)
        } catch {
            // Crash in debug so the issue surfaces immediately during development.
            // In release the save is skipped — the next successful save will recover.
            assertionFailure("[SharedDataStore] Encode failed for '\(key)': \(error)")
        }
    }

    private static func load<T: Codable>(from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // Data exists but couldn't be decoded — likely a schema mismatch or corruption.
            // Crash in debug; fall back to nil (empty state) in release.
            assertionFailure("[SharedDataStore] Decode failed for '\(key)': \(error)")
            return nil
        }
    }
}
