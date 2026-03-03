//
//  SettingsViewModel.swift
//  {{PROJECT_NAME}}
//
//  Created by {{AUTHOR_NAME}} on {{DATE}}.
//

import Foundation
import SwiftUI

/// ViewModel for the Settings screen.
///
/// Uses @AppStorage for automatic persistence to UserDefaults.
/// Changes are instantly saved and survive app restarts.
@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true

    /// App version from the bundle (e.g., "1.0.0").
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    /// Build number from the bundle (e.g., "1").
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
