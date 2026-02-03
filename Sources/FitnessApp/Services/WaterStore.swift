import Foundation

final class WaterStore {
    private let storageKey = "fitnessapp.water.entries"
    private let calendar = Calendar.current

    func loadEntries() -> [WaterEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        return (try? JSONDecoder().decode([WaterEntry].self, from: data)) ?? []
    }

    func save(ounces: Double, on date: Date = Date()) {
        var entries = loadEntries()
        let day = calendar.startOfDay(for: date)

        if let index = entries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
            entries[index] = WaterEntry(date: day, ounces: ounces, id: entries[index].id)
        } else {
            entries.append(WaterEntry(date: day, ounces: ounces))
        }

        persist(entries)
    }

    func latestEntry() -> WaterEntry? {
        loadEntries().sorted { $0.date > $1.date }.first
    }

    func samples(days: Int = 14) -> [MetricSample] {
        let entries = loadEntries()
        let start = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date())) ?? Date()
        let filtered = entries.filter { $0.date >= start }
        return filtered
            .sorted { $0.date < $1.date }
            .map { MetricSample(date: $0.date, value: $0.ounces) }
    }

    func hasEntries() -> Bool {
        !loadEntries().isEmpty
    }

    private func persist(_ entries: [WaterEntry]) {
        let data = try? JSONEncoder().encode(entries)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
