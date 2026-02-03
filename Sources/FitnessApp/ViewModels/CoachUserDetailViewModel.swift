import Foundation

@MainActor
final class CoachUserDetailViewModel: ObservableObject {
    @Published var summaries: [MetricSummary] = []
    @Published var samplesByMetric: [MetricType: [MetricSample]] = [:]
    @Published var moodFlag: CoachMoodFlag? = nil
    @Published var history: [UserHistoryEvent] = []

    let user: UserProfile
    private let repository: MockDataRepository

    init(user: UserProfile, repository: MockDataRepository = MockDataRepository()) {
        self.user = user
        self.repository = repository
        load()
    }

    func load() {
        summaries = repository.summaries(user: user)
        MetricType.allCases.forEach { metric in
            samplesByMetric[metric] = repository.samples(for: metric, user: user)
        }
        moodFlag = CoachMoodFlag(from: samplesByMetric[.mood] ?? [])
        history = repository.history(for: user)
    }
}
