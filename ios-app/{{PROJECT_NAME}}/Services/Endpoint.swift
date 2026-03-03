//
//  Endpoint.swift
//  {{PROJECT_NAME}}
//
//  Created by {{AUTHOR_NAME}} on {{DATE}}.
//

import Foundation

/// Type-safe API endpoint definitions.
///
/// Add new endpoints as enum cases:
/// ```swift
/// case posts
/// case post(id: String)
/// case createPost(title: String, body: String)
/// ```
enum Endpoint {
    case users
    case user(id: String)

    // Add your endpoints here:
    // case posts
    // case post(id: String)

    /// Base URL for all API requests. Update this for your API.
    static var baseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://api.example.com/v1")!
    }

    var path: String {
        switch self {
        case .users:
            return "/users"
        case .user(let id):
            return "/users/\(id)"
        }
    }

    var method: String {
        switch self {
        case .users, .user:
            return "GET"
        }
    }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    var body: Data? {
        switch self {
        case .users, .user:
            return nil
        }
    }

    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: Self.baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}
