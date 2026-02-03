import Foundation

@MainActor
final class UserDashboardViewModel: ObservableObject {
    @Published var summaries: [MetricSummary] = []
    @Published var insights: [Insight] = []
    @Published var samplesByMetric: [MetricType: [MetricSample]] = [:]
    @Published var isHealthAuthorized = false
    @Published var isLoading = false

    private let repository: MockDataRepository
    private let healthService: HealthKitService
    private let moodStore: MoodStore
    private let waterStore: WaterStore

    init(
        repository: MockDataRepository = MockDataRepository(),
        healthService: HealthKitService = HealthKitService(),
        moodStore: MoodStore = MoodStore(),
        waterStore: WaterStore = WaterStore()
    ) {
        self.repository = repository
        self.healthService = healthService
        self.moodStore = moodStore
        self.waterStore = waterStore
        loadFallback()
    }

    func loadFallback() {
        summaries = repository.summaries()
        MetricType.allCases.forEach { metric in
            if metric == .mood {
                samplesByMetric[metric] = moodStore.samples()
            } else if metric == .water, waterStore.hasEntries() {
                samplesByMetric[metric] = waterStore.samples()
            } else {
                samplesByMetric[metric] = repository.samples(for: metric)
            }
        }
        updateInsights()
    }

    func connectAppleHealth() async {
        guard healthService.isAvailable else {
            isHealthAuthorized = false
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await healthService.requestAuthorization()
            isHealthAuthorized = true
            await loadFromHealthKit()
        } catch {
            isHealthAuthorized = false
            loadFallback()
        }
    }

    func loadFromHealthKit() async {
        isLoading = true
        defer { isLoading = false }

        var newSamples: [MetricType: [MetricSample]] = [:]
        for metric in MetricType.allCases {
            if metric == .mood {
                newSamples[metric] = moodStore.samples()
            } else if metric == .water, waterStore.hasEntries() {
                newSamples[metric] = waterStore.samples()
            } else if let samples = try? await healthService.fetchDailySamples(for: metric) {
                newSamples[metric] = samples
            }
        }
        samplesByMetric = newSamples.isEmpty ? samplesByMetric : newSamples

        summaries = MetricType.allCases.map { metric in
            let latest = samplesByMetric[metric]?.last?.value ?? 0
            let trend = Double.random(in: -8...12)
            return MetricSummary(type: metric, latestValue: latest, trendPercent: trend)
        }

        insights = repository.insights() + moodInsights() + waterInsights()
    }

    func saveMood(score: Int) {
        moodStore.save(score: score)
        samplesByMetric[.mood] = moodStore.samples()
        updateSummaries()
        updateInsights()
    }

    func latestMood() -> MoodEntry? {
        moodStore.latestEntry()
    }

    func saveWater(ounces: Double) {
        waterStore.save(ounces: ounces)
        samplesByMetric[.water] = waterStore.samples()
        updateSummaries()
        updateInsights()
    }

    func latestWater() -> WaterEntry? {
        waterStore.latestEntry()
    }

    private func updateSummaries() {
        summaries = MetricType.allCases.map { metric in
            let latest = samplesByMetric[metric]?.last?.value ?? 0
            let trend = Double.random(in: -8...12)
            return MetricSummary(type: metric, latestValue: latest, trendPercent: trend)
        }
    }

    private func updateInsights() {
        insights = repository.insights() + moodInsights() + waterInsights()
    }

    private func moodInsights() -> [Insight] {
        let samples = samplesByMetric[.mood] ?? []
        guard let latest = samples.last?.value else { return [] }
        var results: [Insight] = []

        if latest <= 4 {
            results.append(
                Insight(
                    title: "Low mood today",
                    detail: "Your latest check-in was \(Int(latest))/10. Consider light recovery or stress-reduction.",
                    severity: .warning
                )
            )
        } else if latest <= 6 {
            results.append(
                Insight(
                    title: "Mood trending low",
                    detail: "Your latest check-in was \(Int(latest))/10. A short walk or early night could help.",
                    severity: .caution
                )
            )
        }

        if samples.count >= 3 {
            let recent = samples.suffix(3).map { $0.value }
            let average = recent.reduce(0, +) / Double(recent.count)
            if average <= 5 {
                results.append(
                    Insight(
                        title: "3-day mood dip",
                        detail: "Average mood over the last 3 days is \(String(format: \"%.1f\", average))/10.",
                        severity: .warning
                    )
                )
            }
        }

        return results
    }

    private func waterInsights() -> [Insight] {
        let samples = samplesByMetric[.water] ?? []
        guard let latest = samples.last?.value else { return [] }

        if latest < 64 {
            return [
                Insight(
                    title: "Hydration below target",
                    detail: "You logged \(Int(latest)) oz today. Aim for 64 oz or more.",
                    severity: .caution
                )
            ]
        }
        return []
    }
}
