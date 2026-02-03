import SwiftUI

struct WaterCheckInCard: View {
    @State private var ounces: Double = 64

    let latestEntry: WaterEntry?
    let saveAction: (Double) -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Water Intake")
                .font(.title2.bold())

            Text("Log today’s water if you drink outside tracked bottles.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Slider(value: $ounces, in: 0...160, step: 4)
                Text("\(Int(ounces)) oz")
                    .font(.headline)
            }

            if let latestEntry {
                Text("Last saved: \(dateFormatter.string(from: latestEntry.date)) — \(Int(latestEntry.ounces)) oz")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: { saveAction(ounces) }) {
                HStack {
                    Image(systemName: "drop.fill")
                    Text("Save Water")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            if let latestEntry {
                ounces = latestEntry.ounces
            }
        }
    }
}
