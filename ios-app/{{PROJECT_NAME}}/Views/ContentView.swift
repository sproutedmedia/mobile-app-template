//
//  ContentView.swift
//  {{PROJECT_NAME}}
//
//  Created by {{AUTHOR_NAME}} on {{DATE}}.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "app.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("Welcome to {{PROJECT_NAME}}")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Your app is ready to build!")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("{{PROJECT_NAME}}")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
