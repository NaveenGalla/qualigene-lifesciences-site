import Foundation

struct UserHistoryEvent: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let detail: String
    let type: UserHistoryType

    init(date: Date, title: String, detail: String, type: UserHistoryType, id: UUID = UUID()) {
        self.date = date
        self.title = title
        self.detail = detail
        self.type = type
        self.id = id
    }
}

enum UserHistoryType: String, Codable {
    case workout
    case sleep
    case recovery
    case hydration
    case mood
}
