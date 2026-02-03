import SwiftUI

struct HealthConnectCard: View {
    let isAuthorized: Bool
    let isLoading: Bool
    let connectAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connect Apple Health")
                .font(.title2.bold())

            Text(isAuthorized
                 ? "Apple Health is connected. Your live data is loading."
                 : "Connect to Apple Health to sync sleep, workouts, heart rate, recovery, water, and mindful sessions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: connectAction) {
                HStack {
                    Image(systemName: "heart.fill")
                    Text(isLoading ? "Connecting..." : (isAuthorized ? "Refresh Data" : "Connect"))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
