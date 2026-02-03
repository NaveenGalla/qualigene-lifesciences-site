import SwiftUI

struct CoachThresholdsSection: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @State private var thresholds: UserThresholds

    init(user: UserProfile, thresholds: UserThresholds) {
        self.user = user
        _thresholds = State(initialValue: thresholds)
    }

    let user: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thresholds")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Sleep Target")
                    .font(.subheadline)
                Slider(value: $thresholds.sleepHours, in: 5...10, step: 0.25)
                Text(String(format: "%.2f hrs", thresholds.sleepHours))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Water Target")
                    .font(.subheadline)
                Slider(value: $thresholds.waterOunces, in: 32...160, step: 4)
                Text("\(Int(thresholds.waterOunces)) oz")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Recovery (HRV) Minimum")
                    .font(.subheadline)
                Slider(value: $thresholds.recoveryMs, in: 30...120, step: 1)
                Text("\(Int(thresholds.recoveryMs)) ms")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Mood Minimum")
                    .font(.subheadline)
                Stepper(value: $thresholds.moodScore, in: 1...10) {
                    Text("\(thresholds.moodScore)/10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button("Save Thresholds") {
                dataStore.updateThresholds(thresholds)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
