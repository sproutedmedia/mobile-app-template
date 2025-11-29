# GitHub Copilot Instructions - Mobile App Template

## Project Overview

This is a cross-platform mobile application template for iOS and Android using modern frameworks:
- **iOS**: SwiftUI with Swift 5.9+, MVVM architecture
- **Android**: Jetpack Compose with Kotlin 2.0+, MVVM architecture

## Code Generation Guidelines

### For iOS (Swift/SwiftUI)

When generating Swift code:
- Use SwiftUI for all views (not UIKit)
- Follow MVVM pattern with `@StateObject` ViewModels
- Use `@MainActor` annotation on ViewModels
- Prefer Swift concurrency (async/await) over completion handlers
- Use `@Published` properties for observable state
- Include `#Preview` macros for SwiftUI previews

Example view structure:
```swift
struct ExampleView: View {
    @StateObject private var viewModel = ExampleViewModel()

    var body: some View {
        // View content
    }
}

#Preview {
    ExampleView()
}
```

### For Android (Kotlin/Compose)

When generating Kotlin code:
- Use Jetpack Compose for all UI (not XML layouts)
- Follow MVVM pattern with `ViewModel` classes
- Use `StateFlow` for reactive state (not LiveData)
- Use `viewModelScope` for coroutines
- Apply Material Design 3 theming
- Use state hoisting pattern (state up, events down)

Example screen structure:
```kotlin
@Composable
fun ExampleScreen(
    viewModel: ExampleViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    // Screen content
}
```

## File Locations

- iOS views: `ios-app/{{PROJECT_NAME}}/Views/`
- iOS view models: `ios-app/{{PROJECT_NAME}}/ViewModels/`
- iOS models: `ios-app/{{PROJECT_NAME}}/Models/`
- Android screens: `android-app/app/src/main/java/com/{{PACKAGE_NAME}}/ui/screens/`
- Android components: `android-app/app/src/main/java/com/{{PACKAGE_NAME}}/ui/components/`
- Android view models: alongside screens or in `domain/`

## Code Quality

Generated code should pass:
- **iOS**: SwiftLint (`.swiftlint.yml`) and SwiftFormat (`.swiftformat`)
- **Android**: ktlint and detekt (`config/detekt/detekt.yml`)

## Template Placeholders

This is a template. These placeholders are replaced by `setup.sh`:
- `{{PROJECT_NAME}}` - The iOS project/app name
- `{{PACKAGE_NAME}}` - The Android package name
- `{{AUTHOR_NAME}}` - Developer name
- `{{DATE}}` - Setup date

## Additional Resources

- `CLAUDE.md` - Detailed project context and commands
- `docs/AI-ASSISTANTS.md` - Workflow playbooks for AI assistants
- `docs/DEVELOPMENT.md` - Development guide and best practices
