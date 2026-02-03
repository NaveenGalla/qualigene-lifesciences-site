import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let score: Int

    init(date: Date, score: Int, id: UUID = UUID()) {
        self.date = date
        self.score = score
        self.id = id
    }
}
