import SwiftUI
import Charts

struct UserDashboardView: View {
    @StateObject private var viewModel = UserDashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HealthConnectCard(
                        isAuthorized: viewModel.isHealthAuthorized,
                        isLoading: viewModel.isLoading,
                        connectAction: {
                            Task { await viewModel.connectAppleHealth() }
                        }
                    )

                    MoodCheckInCard(
                        latestEntry: viewModel.latestMood(),
                        saveAction: { score in
                            viewModel.saveMood(score: score)
                        }
                    )

                    WaterCheckInCard(
                        latestEntry: viewModel.latestWater(),
                        saveAction: { ounces in
                            viewModel.saveWater(ounces: ounces)
                        }
                    )

                    MetricSummaryGrid(summaries: viewModel.summaries)

                    InsightsView(insights: viewModel.insights)

                    MetricChartsSection(samplesByMetric: viewModel.samplesByMetric)
                }
                .padding()
            }
            .navigationTitle("Your Fitness")
        }
    }
}
