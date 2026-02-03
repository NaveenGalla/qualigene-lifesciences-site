import Foundation

enum ExportFormat {
    case csv
    case json
}

final class ExportService {
    func exportCoachData(
        user: UserProfile,
        history: [UserHistoryEvent],
        notes: [CoachNote],
        samplesByMetric: [MetricType: [MetricSample]],
        format: ExportFormat
    ) -> URL? {
        let payload = CoachExportPayload(
            user: user,
            history: history,
            notes: notes,
            metrics: samplesByMetric
        )

        switch format {
        case .json:
            return writeJSON(payload)
        case .csv:
            return writeCSV(payload)
        }
    }

    private func writeJSON(_ payload: CoachExportPayload) -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(payload) else { return nil }
        return writeFile(data: data, name: "coach_export.json")
    }

    private func writeCSV(_ payload: CoachExportPayload) -> URL? {
        var lines: [String] = []
        lines.append("User,Date,Category,Detail")

        let dateFormatter = ISO8601DateFormatter()

        payload.history.forEach { event in
            let date = dateFormatter.string(from: event.date)
            lines.append("\(payload.user.name),\(date),History,\(sanitize(event.title)): \(sanitize(event.detail))")
        }

        payload.notes.forEach { note in
            let date = dateFormatter.string(from: note.date)
            let tags = note.tags.joined(separator: ";")
            lines.append("\(payload.user.name),\(date),Note,\(sanitize(note.text)) [\(tags)]")
        }

        payload.metrics.forEach { metric, samples in
            samples.forEach { sample in
                let date = dateFormatter.string(from: sample.date)
                lines.append("\(payload.user.name),\(date),\(metric.displayName),\(sample.value)")
            }
        }

        let csv = lines.joined(separator: "\n")
        return writeFile(data: Data(csv.utf8), name: "coach_export.csv")
    }

    private func writeFile(data: Data, name: String) -> URL? {
        let folder = FileManager.default.temporaryDirectory
        let url = folder.appendingPathComponent(name)
        try? data.write(to: url, options: [.atomic])
        return url
    }

    private func sanitize(_ text: String) -> String {
        text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: ",", with: " ")
    }
}

private struct CoachExportPayload: Codable {
    let user: UserProfile
    let history: [UserHistoryEvent]
    let notes: [CoachNote]
    let metrics: [MetricType: [MetricSample]]
}
