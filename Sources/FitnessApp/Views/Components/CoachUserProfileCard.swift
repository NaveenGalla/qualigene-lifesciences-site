import SwiftUI

struct CoachUserProfileCard: View {
    let user: UserProfile

    var body: some View {
        HStack(spacing: 16) {
            Text(user.avatarInitials)
                .font(.title2.bold())
                .frame(width: 60, height: 60)
                .background(Circle().fill(.blue))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.title2.bold())
                Text("Age \(user.age)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Active plan: Strength + Recovery")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
