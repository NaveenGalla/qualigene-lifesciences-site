import Foundation

enum MetricType: String, CaseIterable, Identifiable, Codable {
    case sleep
    case workout
    case heartRate
    case recovery
    case water
    case mood

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sleep: return "Sleep"
        case .workout: return "Workout"
        case .heartRate: return "Heart Rate"
        case .recovery: return "Recovery"
        case .water: return "Water"
        case .mood: return "Mood"
        }
    }

    var unit: String {
        switch self {
        case .sleep: return "hrs"
        case .workout: return "min"
        case .heartRate: return "bpm"
        case .recovery: return "ms"
        case .water: return "oz"
        case .mood: return "score"
        }
    }
}

struct MetricSample: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct MetricSummary: Codable {
    let type: MetricType
    let latestValue: Double
    let trendPercent: Double
}
