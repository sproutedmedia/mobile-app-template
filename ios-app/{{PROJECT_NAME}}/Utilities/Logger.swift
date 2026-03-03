//
//  Logger.swift
//  {{PROJECT_NAME}}
//
//  Created by {{AUTHOR_NAME}} on {{DATE}}.
//

import Foundation
import OSLog

/// Structured logging utility using Apple's unified logging system (OSLog).
///
/// Usage:
/// ```swift
/// Log.debug("User tapped button", category: "UI")
/// Log.info("Fetched 42 items", category: "Network")
/// Log.warning("Cache miss", category: "Data")
/// Log.error("Failed to save", category: "Persistence")
/// ```
///
/// View logs in Console.app by filtering on your app's subsystem.
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "{{PACKAGE_NAME}}"

    private static func logger(category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }

    /// Debug-level log. Stripped from release builds.
    static func debug(_ message: String, category: String = "Default") {
        #if DEBUG
        logger(category: category).debug("\(message)")
        #endif
    }

    /// Informational log. Visible in Console.app.
    static func info(_ message: String, category: String = "Default") {
        logger(category: category).info("\(message)")
    }

    /// Warning-level log for unexpected but recoverable situations.
    static func warning(_ message: String, category: String = "Default") {
        logger(category: category).warning("\(message)")
    }

    /// Error-level log for failures that need attention.
    static func error(_ message: String, category: String = "Default") {
        logger(category: category).error("\(message)")
    }
}
