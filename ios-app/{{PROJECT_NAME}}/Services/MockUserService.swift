import Foundation

/// Mock implementation of UserServiceProtocol for testing and previews
final class MockUserService: UserServiceProtocol {
    var mockUser: User = User(
        id: "mock-123",
        name: "Jane Developer",
        email: "jane@example.com",
        bio: "Mobile developer enthusiast building great apps.",
        avatarURL: URL(string: "https://example.com/avatar.jpg"),
        createdAt: Date()
    )

    var shouldFail = false
    var delay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds

    func fetchCurrentUser() async throws -> User {
        try await Task.sleep(nanoseconds: delay)

        if shouldFail {
            throw UserServiceError.invalidResponse
        }

        return mockUser
    }

    func updateUser(_ user: User) async throws -> User {
        try await Task.sleep(nanoseconds: delay)

        if shouldFail {
            throw UserServiceError.updateFailed
        }

        mockUser = user
        return user
    }
}
