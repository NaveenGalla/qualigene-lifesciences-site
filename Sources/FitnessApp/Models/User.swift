import Foundation

struct UserProfile: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let age: Int
    let avatarInitials: String
}
