import Foundation

struct UserThresholds: Identifiable, Codable, Hashable {
    let id: UUID
    var sleepHours: Double
    var waterOunces: Double
    var recoveryMs: Double
    var moodScore: Int

    init(
        id: UUID,
        sleepHours: Double = 7.0,
        waterOunces: Double = 64.0,
        recoveryMs: Double = 60.0,
        moodScore: Int = 6
    ) {
        self.id = id
        self.sleepHours = sleepHours
        self.waterOunces = waterOunces
        self.recoveryMs = recoveryMs
        self.moodScore = moodScore
    }
}
