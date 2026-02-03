import Foundation
import UserNotifications

final class NotificationsManager {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleAlerts(for userName: String, alerts: [CoachAlert]) async {
        await requestAuthorization()

        let identifiers = alerts.enumerated().map { "alert_\($0.offset)" }
        identifiers.forEach { center.removePendingNotificationRequests(withIdentifiers: [$0]) }

        for (index, alert) in alerts.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "\(userName): \(alert.title)"
            content.body = alert.detail
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 + Double(index), repeats: false)
            let request = UNNotificationRequest(identifier: "alert_\(index)", content: content, trigger: trigger)
            try? await center.add(request)
        }
    }
}
