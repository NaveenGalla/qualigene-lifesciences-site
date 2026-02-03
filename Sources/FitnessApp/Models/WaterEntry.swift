import Foundation

struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let ounces: Double

    init(date: Date, ounces: Double, id: UUID = UUID()) {
        self.date = date
        self.ounces = ounces
        self.id = id
    }
}
