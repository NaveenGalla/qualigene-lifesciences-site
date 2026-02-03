import Foundation

struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let severity: InsightSeverity
}

enum InsightSeverity: String {
    case good
    case caution
    case warning
}
