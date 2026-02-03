import Foundation
import BackgroundTasks

final class BackgroundSyncManager {
    static let shared = BackgroundSyncManager()
    private let taskIdentifier = "com.fitnessapp.sync"

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 30)
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let operation = Task {
            await AppDataStore.performBackgroundSync()
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            operation.cancel()
            task.setTaskCompleted(success: false)
        }
    }
}
