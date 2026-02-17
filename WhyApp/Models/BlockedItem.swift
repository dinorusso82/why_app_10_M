import Foundation

struct BlockedItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: Category
    var whyNot: String
    var dateAdded: Date

    enum Category: String, Codable, CaseIterable {
        case website = "Website"
        case app = "App"
    }

    init(id: UUID = UUID(), name: String, category: Category, whyNot: String, dateAdded: Date = Date()) {
        self.id = id
        self.name = name
        self.category = category
        self.whyNot = whyNot
        self.dateAdded = dateAdded
    }
}
