import SwiftUI

struct SyncStatusBar: View {
    let state: SyncState
    let lastSyncDate: Date?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color(for: state))
                .frame(width: 10, height: 10)

            Text(labelText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            if let lastSyncDate {
                Text(dateFormatter.string(from: lastSyncDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }

    private var labelText: String {
        switch state {
        case .idle:
            return "Sync idle"
        case .syncing:
            return "Syncing to iCloud"
        case .synced:
            return "Synced"
        case .error:
            return "Sync error"
        }
    }

    private func color(for state: SyncState) -> Color {
        switch state {
        case .idle: return .gray
        case .syncing: return .blue
        case .synced: return .green
        case .error: return .red
        }
    }
}

enum SyncState: String {
    case idle
    case syncing
    case synced
    case error
}
