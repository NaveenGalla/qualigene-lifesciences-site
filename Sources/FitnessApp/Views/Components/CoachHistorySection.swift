import SwiftUI

struct CoachHistorySection: View {
    let history: [UserHistoryEvent]
    @Binding var selectedFilter: UserHistoryFilter

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent History")
                .font(.title2.bold())

            CoachHistoryFilterBar(selectedFilter: $selectedFilter)

            ForEach(filteredHistory) { event in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(color(for: event.type))
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(dateFormatter.string(from: event.date))
                            .font(.caption)
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

    private var filteredHistory: [UserHistoryEvent] {
        switch selectedFilter {
        case .all:
            return history
        case .workout:
            return history.filter { $0.type == .workout }
        case .sleep:
            return history.filter { $0.type == .sleep }
        case .recovery:
            return history.filter { $0.type == .recovery }
        case .hydration:
            return history.filter { $0.type == .hydration }
        case .mood:
            return history.filter { $0.type == .mood }
        }
    }

    private func color(for type: UserHistoryType) -> Color {
        switch type {
        case .workout: return .blue
        case .sleep: return .indigo
        case .recovery: return .green
        case .hydration: return .cyan
        case .mood: return .orange
        }
    }
}

enum UserHistoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case workout = "Workouts"
    case sleep = "Sleep"
    case recovery = "Recovery"
    case hydration = "Hydration"
    case mood = "Mood"

    var id: String { rawValue }
}

struct CoachHistoryFilterBar: View {
    @Binding var selectedFilter: UserHistoryFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(UserHistoryFilter.allCases) { filter in
                    Button(action: { selectedFilter = filter }) {
                        Text(filter.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
