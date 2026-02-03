import Foundation

final class MockDataRepository {
    private let calendar = Calendar.current

    func users() -> [UserProfile] {
        [
            UserProfile(id: UUID(), name: "Avery", age: 28, avatarInitials: "AV"),
            UserProfile(id: UUID(), name: "Jordan", age: 34, avatarInitials: "JD"),
            UserProfile(id: UUID(), name: "Riley", age: 41, avatarInitials: "RL")
        ]
    }

    func samples(for type: MetricType, days: Int = 14) -> [MetricSample] {
        samples(for: type, user: nil, days: days)
    }

    func samples(for type: MetricType, user: UserProfile?, days: Int = 14) -> [MetricSample] {
        (0..<days).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let base: Double
            switch type {
            case .sleep: base = 7.2
            case .workout: base = 48
            case .heartRate: base = 64
            case .recovery: base = 72
            case .water: base = 88
            case .mood:
                if let user {
                    base = 5.8 + Double(abs(user.name.hashValue % 6)) / 2
                } else {
                    base = 7.4
                }
            }
            let variance = Double.random(in: -0.8...0.8)
            return MetricSample(date: date, value: max(0, base + variance * 10))
        }.sorted { $0.date < $1.date }
    }

    func summaries(user: UserProfile? = nil) -> [MetricSummary] {
        MetricType.allCases.map { type in
            let latest = samples(for: type, user: user).last?.value ?? 0
            let trend = Double.random(in: -8...12)
            return MetricSummary(type: type, latestValue: latest, trendPercent: trend)
        }
    }

    func history(for user: UserProfile) -> [UserHistoryEvent] {
        let today = calendar.startOfDay(for: Date())
        let seed = abs(user.name.hashValue % 6)
        return [
            UserHistoryEvent(
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                title: "Strength session",
                detail: "Completed \(45 + seed) min. HR avg 132 bpm.",
                type: .workout
            ),
            UserHistoryEvent(
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                title: "Sleep quality",
                detail: "Slept 7h \(10 + seed)m with deep sleep 1h 20m.",
                type: .sleep
            ),
            UserHistoryEvent(
                date: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                title: "Recovery check",
                detail: "HRV improved to \(60 + seed) ms.",
                type: .recovery
            ),
            UserHistoryEvent(
                date: calendar.date(byAdding: .day, value: -4, to: today) ?? today,
                title: "Hydration log",
                detail: "Logged \(64 + seed * 4) oz for the day.",
                type: .hydration
            ),
            UserHistoryEvent(
                date: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                title: "Mood check-in",
                detail: "Mood score \(6 + seed % 4)/10.",
                type: .mood
            )
        ]
    }

    func insights() -> [Insight] {
        [
            Insight(title: "Recovery trending up", detail: "Your 7-day recovery score improved 6%.", severity: .good),
            Insight(title: "Hydration dip", detail: "Water intake fell below goal on 3 of 5 days.", severity: .caution),
            Insight(title: "Sleep debt", detail: "Average sleep is 6h 12m, aim for 7h+.", severity: .warning)
        ]
    }
}
