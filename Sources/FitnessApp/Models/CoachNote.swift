import Foundation

struct CoachNote: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let date: Date
    let text: String
    let tags: [String]

    init(userId: UUID, text: String, tags: [String], date: Date = Date(), id: UUID = UUID()) {
        self.userId = userId
        self.text = text
        self.tags = tags
        self.date = date
        self.id = id
    }
}
