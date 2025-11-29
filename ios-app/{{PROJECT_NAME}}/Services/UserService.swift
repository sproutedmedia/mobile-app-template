import Foundation

/// Protocol defining user service operations
protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> User
    func updateUser(_ user: User) async throws -> User
}

/// Errors that can occur during user service operations
enum UserServiceError: LocalizedError {
    case invalidResponse
    case updateFailed
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Failed to fetch user data"
        case .updateFailed:
            return "Failed to update profile"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

/// Production implementation of UserServiceProtocol
final class UserService: UserServiceProtocol {
    private let baseURL: URL
    private let decoder: JSONDecoder

    init(baseURL: URL = URL(string: "https://api.example.com")!) {
        self.baseURL = baseURL
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func fetchCurrentUser() async throws -> User {
        let url = baseURL.appendingPathComponent("/users/me")
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw UserServiceError.invalidResponse
        }

        return try decoder.decode(User.self, from: data)
    }

    func updateUser(_ user: User) async throws -> User {
        var request = URLRequest(url: baseURL.appendingPathComponent("/users/\(user.id)"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(user)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw UserServiceError.updateFailed
        }

        return try decoder.decode(User.self, from: data)
    }
}
