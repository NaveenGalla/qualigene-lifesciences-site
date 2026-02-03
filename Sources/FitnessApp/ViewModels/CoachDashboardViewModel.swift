import Foundation

struct CoachMoodFlag {
    let title: String
    let detail: String
    let severity: InsightSeverity

    init?(from samples: [MetricSample]) {
        guard let latest = samples.last?.value else { return nil }
        let lastThree = samples.suffix(3).map { $0.value }
        let average = lastThree.isEmpty ? latest : lastThree.reduce(0, +) / Double(lastThree.count)

        if latest <= 4 || average <= 5 {
            self.title = "Mood alert"
            self.detail = "Latest mood is \(Int(latest))/10 with a 3-day avg of \(String(format: \"%.1f\", average))/10."
            self.severity = .warning
        } else if latest <= 6 {
            self.title = "Mood watch"
            self.detail = "Latest mood is \(Int(latest))/10. Keep an eye on recovery and stress."
            self.severity = .caution
        } else {
            return nil
        }
    }
}
