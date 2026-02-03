import SwiftUI

struct CoachUserSelector: View {
    let users: [UserProfile]
    @Binding var selectedUser: UserProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Athletes")
                .font(.title2.bold())

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(users) { user in
                        Button {
                            selectedUser = user
                        } label: {
                            VStack(spacing: 8) {
                                Text(user.avatarInitials)
                                    .font(.headline)
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(.blue))
                                    .foregroundStyle(.white)

                                Text(user.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedUser == user ? Color.blue.opacity(0.15) : .clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
