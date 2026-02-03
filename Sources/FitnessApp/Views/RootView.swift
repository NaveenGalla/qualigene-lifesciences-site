import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            UserDashboardView()
                .tabItem {
                    Label("User", systemImage: "person.fill")
                }

            CoachDashboardView()
                .tabItem {
                    Label("Coach", systemImage: "person.2.fill")
                }
        }
    }
}
