import SwiftUI

@main
struct FitnessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dataStore = AppDataStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataStore)
                .onAppear {
                    BackgroundSyncManager.shared.scheduleAppRefresh()
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BackgroundSyncManager.shared.register()
        return true
    }
}
