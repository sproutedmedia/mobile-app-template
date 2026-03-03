//
//  SettingsViewModelTests.swift
//  {{PROJECT_NAME}}Tests
//
//  Created by {{AUTHOR_NAME}} on {{DATE}}.
//

import XCTest
@testable import {{PROJECT_NAME}}

@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var viewModel = SettingsViewModel()

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        viewModel = SettingsViewModel()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        super.tearDown()
    }

    func testDefaultValues() {
        XCTAssertFalse(viewModel.isDarkMode, "Dark mode should default to false")
        XCTAssertTrue(viewModel.notificationsEnabled, "Notifications should default to true")
    }

    func testToggleDarkMode() {
        viewModel.isDarkMode = true
        XCTAssertTrue(viewModel.isDarkMode)

        viewModel.isDarkMode = false
        XCTAssertFalse(viewModel.isDarkMode)
    }

    func testToggleNotifications() {
        viewModel.notificationsEnabled = false
        XCTAssertFalse(viewModel.notificationsEnabled)

        viewModel.notificationsEnabled = true
        XCTAssertTrue(viewModel.notificationsEnabled)
    }

    func testAppVersionIsNotEmpty() {
        XCTAssertFalse(viewModel.appVersion.isEmpty)
    }

    func testBuildNumberIsNotEmpty() {
        XCTAssertFalse(viewModel.buildNumber.isEmpty)
    }
}
