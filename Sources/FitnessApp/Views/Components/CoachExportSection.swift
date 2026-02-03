import SwiftUI

struct CoachExportSection: View {
    let csvURL: URL?
    let jsonURL: URL?
    let buildAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export")
                .font(.title2.bold())

            Text("Generate CSV or JSON exports for this athlete’s history, notes, and metrics.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Generate Files") {
                    buildAction()
                }
                .buttonStyle(.bordered)

                if let csvURL {
                    ShareLink(item: csvURL) {
                        Text("Share CSV")
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let jsonURL {
                    ShareLink(item: jsonURL) {
                        Text("Share JSON")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
