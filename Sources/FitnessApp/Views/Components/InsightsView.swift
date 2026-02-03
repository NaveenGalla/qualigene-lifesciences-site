import SwiftUI

struct InsightsView: View {
    let insights: [Insight]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.title2.bold())

            ForEach(insights) { insight in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(color(for: insight.severity))
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.headline)
                        Text(insight.detail)
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

    private func color(for severity: InsightSeverity) -> Color {
        switch severity {
        case .good: return .green
        case .caution: return .orange
        case .warning: return .red
        }
    }
}
