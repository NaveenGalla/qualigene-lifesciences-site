import SwiftUI

struct CoachUserDetailView: View {
    @StateObject private var viewModel: CoachUserDetailViewModel
    @EnvironmentObject private var dataStore: AppDataStore
    @State private var historyFilter: UserHistoryFilter = .all
    @State private var exportCSVURL: URL?
    @State private var exportJSONURL: URL?
    private let exportService = ExportService()
    private let notificationsManager = NotificationsManager()

    init(user: UserProfile) {
        _viewModel = StateObject(wrappedValue: CoachUserDetailViewModel(user: user))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CoachUserProfileCard(user: viewModel.user)

                if let flag = viewModel.moodFlag {
                    CoachMoodFlagCard(flag: flag)
                }

                CoachAlertsSection(alerts: alerts(using: dataStore.thresholds(for: viewModel.user.id)))

                CoachThresholdsSection(
                    user: viewModel.user,
                    thresholds: dataStore.thresholds(for: viewModel.user.id)
                )
                .environmentObject(dataStore)

                MetricSummaryGrid(summaries: viewModel.summaries)

                MetricChartsSection(samplesByMetric: viewModel.samplesByMetric)

                CoachHistorySection(history: viewModel.history, selectedFilter: $historyFilter)

                CoachNotesSection(user: viewModel.user)
                    .environmentObject(dataStore)

                CoachExportSection(csvURL: exportCSVURL, jsonURL: exportJSONURL) {
                    let notes = dataStore.notes(for: viewModel.user.id)
                    exportCSVURL = exportService.exportCoachData(
                        user: viewModel.user,
                        history: viewModel.history,
                        notes: notes,
                        samplesByMetric: viewModel.samplesByMetric,
                        format: .csv
                    )
                    exportJSONURL = exportService.exportCoachData(
                        user: viewModel.user,
                        history: viewModel.history,
                        notes: notes,
                        samplesByMetric: viewModel.samplesByMetric,
                        format: .json
                    )
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.user.name)
        .task {
            let alerts = alerts(using: dataStore.thresholds(for: viewModel.user.id))
            await notificationsManager.scheduleAlerts(for: viewModel.user.name, alerts: alerts)
        }
    }

    private func alerts(using thresholds: UserThresholds) -> [CoachAlert] {
        var results: [CoachAlert] = []

        let sleep = viewModel.samplesByMetric[.sleep]?.last?.value ?? 0
        if sleep > 0, sleep < thresholds.sleepHours {
            results.append(
                CoachAlert(
                    title: "Sleep below target",
                    detail: String(format: "Latest sleep %.1f hrs (target %.1f hrs).", sleep, thresholds.sleepHours),
                    severity: .warning
                )
            )
        }

        let water = viewModel.samplesByMetric[.water]?.last?.value ?? 0
        if water > 0, water < thresholds.waterOunces {
            results.append(
                CoachAlert(
                    title: "Hydration below target",
                    detail: "Latest water \(Int(water)) oz (target \(Int(thresholds.waterOunces)) oz).",
                    severity: .caution
                )
            )
        }

        let recovery = viewModel.samplesByMetric[.recovery]?.last?.value ?? 0
        if recovery > 0, recovery < thresholds.recoveryMs {
            results.append(
                CoachAlert(
                    title: "Recovery low",
                    detail: "Latest HRV \(Int(recovery)) ms (min \(Int(thresholds.recoveryMs)) ms).",
                    severity: .warning
                )
            )
        }

        let mood = viewModel.samplesByMetric[.mood]?.last?.value ?? 0
        if mood > 0, mood < Double(thresholds.moodScore) {
            results.append(
                CoachAlert(
                    title: "Mood below target",
                    detail: "Latest mood \(Int(mood))/10 (min \(thresholds.moodScore)/10).",
                    severity: .caution
                )
            )
        }

        return results
    }
}
