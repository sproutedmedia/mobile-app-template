//
//  APIClient.swift
//  {{PROJECT_NAME}}
//
//  Created by {{AUTHOR_NAME}} on {{DATE}}.
//

import Foundation

/// Generic API client for making network requests.
///
/// Uses Swift concurrency (async/await) with URLSession.
///
/// Usage:
/// ```swift
/// let users: [User] = try await APIClient.shared.request(.users)
/// let user: User = try await APIClient.shared.request(.user(id: "123"))
/// ```
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// Perform a request and decode the response.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.urlRequest()

        Log.debug("API \(endpoint.method) \(endpoint.path)", category: "Network")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            Log.error("API error \(httpResponse.statusCode) for \(endpoint.path)", category: "Network")
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Log.error("Decoding failed: \(error.localizedDescription)", category: "Network")
            throw APIError.decodingError(error)
        }
    }

    /// Perform a request with no response body (e.g., DELETE).
    func request(_ endpoint: Endpoint) async throws {
        let request = try endpoint.urlRequest()

        Log.debug("API \(endpoint.method) \(endpoint.path)", category: "Network")

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: nil)
        }
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode, _):
            return "HTTP error \(statusCode)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
