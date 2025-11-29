import Foundation

/// User model representing a user profile
struct User: Codable, Equatable, Identifiable {
    let id: String
    var name: String
    var email: String
    var bio: String
    var avatarURL: URL?
    let createdAt: Date

    static let placeholder = User(
        id: "placeholder",
        name: "",
        email: "",
        bio: "",
        avatarURL: nil,
        createdAt: Date()
    )
}
