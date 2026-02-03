import Foundation

struct CoachAlert: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let severity: InsightSeverity
}
