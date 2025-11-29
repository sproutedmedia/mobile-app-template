import Foundation

/// Utility functions for input validation
enum ValidationHelpers {
    /// Validates an email address format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    /// Validates that a string is not empty after trimming whitespace
    static func isNotEmpty(_ string: String) -> Bool {
        !string.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Validates minimum length requirement
    static func meetsMinLength(_ string: String, minLength: Int) -> Bool {
        string.count >= minLength
    }

    /// Validates maximum length requirement
    static func meetsMaxLength(_ string: String, maxLength: Int) -> Bool {
        string.count <= maxLength
    }
}
