import SwiftUI

struct CoachUserEditor: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var age: Int
    @State private var initials: String

    let user: UserProfile?

    init(user: UserProfile? = nil) {
        self.user = user
        _name = State(initialValue: user?.name ?? "")
        _age = State(initialValue: user?.age ?? 30)
        _initials = State(initialValue: user?.avatarInitials ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Name", text: $name)
                    Stepper(value: $age, in: 14...90) {
                        Text("Age \(age)")
                    }
                    TextField("Initials", text: $initials)
                        .textInputAutocapitalization(.characters)
                }
            }
            .navigationTitle(user == nil ? "Add Athlete" : "Edit Athlete")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedName.isEmpty else { return }
                        let trimmedInitials = initials.trimmingCharacters(in: .whitespacesAndNewlines)
                        let safeInitials = trimmedInitials.isEmpty
                            ? String(trimmedName.prefix(2)).uppercased()
                            : trimmedInitials.uppercased()

                        if let user {
                            let updated = UserProfile(id: user.id, name: trimmedName, age: age, avatarInitials: safeInitials)
                            dataStore.updateUser(updated)
                        } else {
                            dataStore.addUser(name: trimmedName, age: age, initials: safeInitials)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
