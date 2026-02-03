import SwiftUI

struct CoachDashboardView: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @State private var showAddUser = false
    @State private var selectedUser: UserProfile? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                SyncStatusBar(state: dataStore.syncState, lastSyncDate: dataStore.lastSyncDate)
                    .padding(.horizontal)

                List(dataStore.users) { user in
                    NavigationLink {
                        CoachUserDetailView(user: user)
                    } label: {
                        CoachUserRow(user: user)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            dataStore.deleteUser(user)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            showAddUser = true
                            selectedUser = user
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Coach Panel")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedUser = nil
                        showAddUser = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddUser) {
                CoachUserEditor(user: selectedUser)
                    .environmentObject(dataStore)
            }
        }
    }
}

struct CoachUserRow: View {
    let user: UserProfile

    var body: some View {
        HStack(spacing: 12) {
            Text(user.avatarInitials)
                .font(.headline)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.blue))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text("Age \(user.age)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
