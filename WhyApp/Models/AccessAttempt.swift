import Foundation

struct AccessAttempt: Identifiable, Codable {
    let id: UUID
    let blockedItemId: UUID
    let blockedItemName: String
    let whyNot: String
    let whyYes: String
    let timestamp: Date
    let proceeded: Bool

    init(id: UUID = UUID(), blockedItemId: UUID, blockedItemName: String, whyNot: String, whyYes: String, timestamp: Date = Date(), proceeded: Bool) {
        self.id = id
        self.blockedItemId = blockedItemId
        self.blockedItemName = blockedItemName
        self.whyNot = whyNot
        self.whyYes = whyYes
        self.timestamp = timestamp
        self.proceeded = proceeded
    }
}
