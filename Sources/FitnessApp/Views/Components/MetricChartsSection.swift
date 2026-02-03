import SwiftUI
import Charts

struct MetricChartsSection: View {
    let samplesByMetric: [MetricType: [MetricSample]]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends")
                .font(.title2.bold())

            ForEach(MetricType.allCases) { metric in
                if let samples = samplesByMetric[metric] {
                    MetricLineChart(title: metric.displayName, unit: metric.unit, samples: samples)
                }
            }
        }
    }
}

struct MetricLineChart: View {
    let title: String
    let unit: String
    let samples: [MetricSample]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Chart(samples) { sample in
                LineMark(
                    x: .value("Date", sample.date),
                    y: .value("Value", sample.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.blue)
            }
            .frame(height: 160)

            if let latest = samples.last?.value {
                Text(String(format: "Latest: %.1f %@", latest, unit))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
