//
//  SettingsView.swift
//  {{PROJECT_NAME}}
//
//  Created by {{AUTHOR_NAME}} on {{DATE}}.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
            }

            Section("Notifications") {
                Toggle("Push Notifications", isOn: $viewModel.notificationsEnabled)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text(viewModel.buildNumber)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
