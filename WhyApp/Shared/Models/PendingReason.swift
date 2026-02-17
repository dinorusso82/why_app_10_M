import Foundation

/// Created when the shield is temporarily lifted.
/// The user must provide a "why yes" reason next time they open WhyApp.
struct PendingReason: Identifiable, Codable {
    let id: UUID
    let blockedItemId: UUID
    let blockedItemName: String
    let whyNot: String
    let unshieldedAt: Date

    init(
        id: UUID = UUID(),
        blockedItemId: UUID,
        blockedItemName: String,
        whyNot: String,
        unshieldedAt: Date = Date()
    ) {
        self.id = id
        self.blockedItemId = blockedItemId
        self.blockedItemName = blockedItemName
        self.whyNot = whyNot
        self.unshieldedAt = unshieldedAt
    }
}
