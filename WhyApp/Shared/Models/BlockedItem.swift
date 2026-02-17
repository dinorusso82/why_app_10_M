import Foundation
import ManagedSettings

struct BlockedItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var applicationToken: ApplicationToken?
    var webDomainToken: WebDomainToken?
    var whyNot: String
    var dateAdded: Date

    var isApp: Bool { applicationToken != nil }
    var isWebsite: Bool { webDomainToken != nil }

    init(
        id: UUID = UUID(),
        name: String,
        applicationToken: ApplicationToken? = nil,
        webDomainToken: WebDomainToken? = nil,
        whyNot: String,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.applicationToken = applicationToken
        self.webDomainToken = webDomainToken
        self.whyNot = whyNot
        self.dateAdded = dateAdded
    }
}
