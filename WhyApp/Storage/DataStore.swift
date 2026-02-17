import Foundation

class DataStore: ObservableObject {
    @Published var blockedItems: [BlockedItem] = []
    @Published var accessAttempts: [AccessAttempt] = []
    @Published var hasCompletedOnboarding: Bool

    private let itemsKey = "blocked_items"
    private let attemptsKey = "access_attempts"
    private let onboardingKey = "has_completed_onboarding"

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        self.blockedItems = Self.load(key: itemsKey) ?? []
        self.accessAttempts = Self.load(key: attemptsKey) ?? []
    }

    // MARK: - Blocked Items

    func addBlockedItem(_ item: BlockedItem) {
        blockedItems.append(item)
        save(blockedItems, key: itemsKey)
    }

    func removeBlockedItem(_ item: BlockedItem) {
        blockedItems.removeAll { $0.id == item.id }
        save(blockedItems, key: itemsKey)
    }

    func updateBlockedItem(_ item: BlockedItem) {
        if let index = blockedItems.firstIndex(where: { $0.id == item.id }) {
            blockedItems[index] = item
            save(blockedItems, key: itemsKey)
        }
    }

    // MARK: - Access Attempts

    func logAttempt(_ attempt: AccessAttempt) {
        accessAttempts.insert(attempt, at: 0)
        save(accessAttempts, key: attemptsKey)
    }

    func attemptsFor(item: BlockedItem) -> [AccessAttempt] {
        accessAttempts.filter { $0.blockedItemId == item.id }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    // MARK: - Persistence Helpers

    private func save<T: Codable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func load<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
