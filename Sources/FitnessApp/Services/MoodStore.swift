import Foundation

final class MoodStore {
    private let storageKey = "fitnessapp.mood.entries"
    private let calendar = Calendar.current

    func loadEntries() -> [MoodEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        return (try? JSONDecoder().decode([MoodEntry].self, from: data)) ?? []
    }

    func save(score: Int, on date: Date = Date()) {
        var entries = loadEntries()
        let day = calendar.startOfDay(for: date)

        if let index = entries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
            entries[index] = MoodEntry(date: day, score: score, id: entries[index].id)
        } else {
            entries.append(MoodEntry(date: day, score: score))
        }

        persist(entries)
    }

    func latestEntry() -> MoodEntry? {
        loadEntries().sorted { $0.date > $1.date }.first
    }

    func samples(days: Int = 14) -> [MetricSample] {
        let entries = loadEntries()
        let start = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date())) ?? Date()
        let filtered = entries.filter { $0.date >= start }
        return filtered
            .sorted { $0.date < $1.date }
            .map { MetricSample(date: $0.date, value: Double($0.score)) }
    }

    private func persist(_ entries: [MoodEntry]) {
        let data = try? JSONEncoder().encode(entries)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
