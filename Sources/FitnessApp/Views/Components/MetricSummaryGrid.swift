import SwiftUI

struct MetricSummaryGrid: View {
    let summaries: [MetricSummary]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.title2.bold())

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(summaries, id: \.type.id) { summary in
                    MetricCard(summary: summary)
                }
            }
        }
    }
}

struct MetricCard: View {
    let summary: MetricSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(summary.type.displayName)
                .font(.headline)

            Text(String(format: "%.1f %@", summary.latestValue, summary.type.unit))
                .font(.title3.bold())

            HStack(spacing: 6) {
                Image(systemName: summary.trendPercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text(String(format: "%.0f%%", summary.trendPercent))
            }
            .font(.subheadline)
            .foregroundStyle(summary.trendPercent >= 0 ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
