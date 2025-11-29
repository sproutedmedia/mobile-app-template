# Generate New Screen

Create a new screen/view for iOS and/or Android with proper MVVM structure.

## Arguments

- `$ARGUMENTS` - Required: Screen name (e.g., "Settings", "Profile", "UserDetails")

## Instructions

1. Parse the screen name from arguments. If no name provided, ask the user for one.

2. Convert the name to proper conventions:
   - iOS: PascalCase (e.g., "UserDetails" -> "UserDetailsView", "UserDetailsViewModel")
   - Android: PascalCase for classes (e.g., "UserDetailsScreen", "UserDetailsViewModel")

3. Ask the user which platform(s) to generate for: iOS, Android, or both.

4. For iOS, create the following files in `ios-app/{{PROJECT_NAME}}/`:

   **Views/{ScreenName}View.swift:**
   ```swift
   import SwiftUI

   struct {ScreenName}View: View {
       @StateObject private var viewModel = {ScreenName}ViewModel()

       var body: some View {
           VStack {
               Text("{ScreenName}")
           }
           .navigationTitle("{Screen Name}")
       }
   }

   #Preview {
       {ScreenName}View()
   }
   ```

   **ViewModels/{ScreenName}ViewModel.swift:**
   ```swift
   import Foundation

   @MainActor
   class {ScreenName}ViewModel: ObservableObject {
       // Add published properties here

       init() {
           // Initialize
       }
   }
   ```

5. For Android, create the following files in `android-app/app/src/main/java/com/{{PACKAGE_NAME}}/`:

   **ui/screens/{ScreenName}Screen.kt:**
   ```kotlin
   package com.{{PACKAGE_NAME}}.ui.screens

   import androidx.compose.foundation.layout.*
   import androidx.compose.material3.*
   import androidx.compose.runtime.*
   import androidx.compose.ui.Modifier
   import androidx.lifecycle.viewmodel.compose.viewModel

   @Composable
   fun {ScreenName}Screen(
       viewModel: {ScreenName}ViewModel = viewModel()
   ) {
       Column(
           modifier = Modifier.fillMaxSize()
       ) {
           Text("{ScreenName}")
       }
   }
   ```

   **ui/screens/{ScreenName}ViewModel.kt:**
   ```kotlin
   package com.{{PACKAGE_NAME}}.ui.screens

   import androidx.lifecycle.ViewModel
   import kotlinx.coroutines.flow.MutableStateFlow
   import kotlinx.coroutines.flow.StateFlow
   import kotlinx.coroutines.flow.asStateFlow

   class {ScreenName}ViewModel : ViewModel() {
       // Add state flows here
   }
   ```

6. After creating the files, remind the user to:
   - Add navigation to the new screen in their app's navigation graph
   - Run `/lint` to ensure the new code passes all checks
