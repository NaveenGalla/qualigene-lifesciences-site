import SwiftUI

struct MoodCheckInCard: View {
    @State private var moodScore: Double = 7

    let latestEntry: MoodEntry?
    let saveAction: (Int) -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Check-in")
                .font(.title2.bold())

            Text("Rate how you feel today. This helps your coach track recovery and stress.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Slider(value: $moodScore, in: 1...10, step: 1)
                Text("\(Int(moodScore))/10")
                    .font(.headline)
            }

            if let latestEntry {
                Text("Last saved: \(dateFormatter.string(from: latestEntry.date)) — \(latestEntry.score)/10")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: { saveAction(Int(moodScore)) }) {
                HStack {
                    Image(systemName: "face.smiling")
                    Text("Save Mood")
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
                moodScore = Double(latestEntry.score)
            }
        }
    }
}
