import SwiftUI

struct CoachAlertsSection: View {
    let alerts: [CoachAlert]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alerts")
                .font(.title2.bold())

            if alerts.isEmpty {
                Text("No alerts triggered. Thresholds are within targets.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(alerts) { alert in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(color(for: alert.severity))
                            .frame(width: 10, height: 10)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(alert.title)
                                .font(.headline)
                            Text(alert.detail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
        }
    }

    private func color(for severity: InsightSeverity) -> Color {
        switch severity {
        case .good: return .green
        case .caution: return .orange
        case .warning: return .red
        }
    }
}
