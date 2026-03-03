# {{PROJECT_NAME}} - Development Guide

Best practices and workflows for developing this app.

## Git Workflow

### Branch Naming

```
feature/description    - New features
fix/description        - Bug fixes
refactor/description   - Code refactoring
docs/description       - Documentation updates
```

### Commit Messages

Use conventional commits:

```
feat: add user authentication
fix: resolve crash on startup
refactor: extract network layer
docs: update setup guide
```

## Pre-commit Hooks

This project includes pre-commit hooks to catch issues before they reach CI.

### Setup

Run once after cloning:

```bash
git config core.hooksPath .githooks
```

The hooks will automatically:
- Run SwiftLint on staged iOS Swift files
- Run ktlint on staged Android Kotlin files

### Bypassing Hooks (Emergency Only)

```bash
git commit --no-verify -m "your message"
```

## Code Style

### iOS (Swift)

We use **SwiftLint** and **SwiftFormat** for code quality.

**Important:** Run tools in this order for best results:
1. `swiftformat .` - Auto-fixes formatting issues
2. `swiftlint` - Catches remaining style/logic issues

SwiftFormat runs first because it auto-fixes many issues that SwiftLint would otherwise flag.

```bash
# Auto-fix formatting first
cd ios-app && swiftformat .

# Then check for remaining issues
cd ios-app && swiftlint
```

Configuration files:
- `.swiftlint.yml` - Linting rules
- `.swiftformat` - Formatting rules

### Android (Kotlin)

We use **ktlint** and **detekt** (via Gradle plugins).

```bash
cd android-app

# Check code style
./gradlew ktlintCheck

# Auto-format
./gradlew ktlintFormat

# Static analysis
./gradlew detekt
```

Configuration files:
- `gradle/libs.versions.toml` - Plugin versions
- `config/detekt/detekt.yml` - Detekt rules

## Project Architecture

### iOS

```
{{PROJECT_NAME}}/
├── App/              # App entry point
├── Views/            # SwiftUI views (ContentView, SettingsView)
├── ViewModels/       # View models (SettingsViewModel)
├── Models/           # Data models (User)
├── Services/         # API client, endpoints, business logic
└── Utilities/        # Helpers, extensions, logging
```

### Android

```
app/src/main/java/com/{{PACKAGE_NAME}}/
├── {{THEME_NAME}}Application.kt  # Application class (logger init)
├── MainActivity.kt               # Entry point
├── ui/
│   ├── screens/                   # Compose screens
│   │   ├── MainScreen.kt
│   │   ├── profile/               # User profile feature
│   │   └── settings/              # Settings feature
│   ├── components/                # Reusable components
│   └── theme/                     # Theme, colors, typography
├── data/
│   ├── model/                     # Data models
│   ├── remote/                    # Networking (Retrofit)
│   └── repository/                # Data repositories
├── domain/                        # Business logic
└── utilities/                     # Logging
```

## Building

### iOS

```bash
# Debug build
cd ios-app
xcodebuild -scheme {{PROJECT_NAME}} -configuration Debug build

# Release build
xcodebuild -scheme {{PROJECT_NAME}} -configuration Release build

# With xcbeautify (prettier output)
xcodebuild -scheme {{PROJECT_NAME}} build | xcbeautify
```

### Android

```bash
cd android-app

# Debug APK
./gradlew assembleDebug

# Release APK
./gradlew assembleRelease

# Run all checks
./gradlew check
```

## Testing

### iOS

Test files location: `ios-app/{{PROJECT_NAME}}Tests/`

```bash
# Run unit tests
xcodebuild test -scheme {{PROJECT_NAME}} -destination 'platform=iOS Simulator,name=iPhone 15'

# With xcbeautify
xcodebuild test -scheme {{PROJECT_NAME}} -destination 'platform=iOS Simulator,name=iPhone 15' | xcbeautify
```

### Android

Test files location: `android-app/app/src/test/java/com/{{PACKAGE_NAME}}/`

```bash
cd android-app

# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest
```

## Logging

### iOS (OSLog)

Use the `Log` utility instead of `print()` for structured, filterable logging:

```swift
Log.debug("User tapped button", category: "UI")
Log.info("Fetched 42 items", category: "Network")
Log.warning("Cache miss", category: "Data")
Log.error("Failed to save", category: "Persistence")
```

- Debug logs are **stripped from release builds** (`#if DEBUG`)
- View logs in Console.app, filter by subsystem or category
- See `Utilities/Logger.swift`

### Android (Timber)

Use `AppLogger` instead of `Log.d()` for automatic tag management:

```kotlin
AppLogger.d("Network", "Request started: GET /users")
AppLogger.i("Auth", "User logged in")
AppLogger.w("Cache", "Cache miss for key: user_profile")
AppLogger.e("Database", "Failed to write", exception)
```

- Debug tree auto-strips in release builds
- Add a crash-reporting tree (e.g., Crashlytics) for production
- Initialized in `{{THEME_NAME}}Application.onCreate()`
- See `utilities/AppLogger.kt`

## Networking

### iOS (URLSession + async/await)

Use `APIClient` and `Endpoint` for type-safe API calls:

```swift
// Define endpoints in Endpoint.swift
case users
case user(id: String)

// Make requests
let users: [User] = try await APIClient.shared.request(.users)
```

- Automatic JSON decoding with snake_case conversion
- Structured error handling via `APIError`
- Logging integrated via `Log` utility
- See `Services/APIClient.swift` and `Services/Endpoint.swift`

### Android (Retrofit)

Use `ApiClient.service` for API calls:

```kotlin
// Define endpoints in ApiService.kt
@GET("users")
suspend fun getUsers(): List<User>

// Make requests
val users = ApiClient.service.getUsers()
```

- OkHttp logging interceptor (debug builds only)
- Gson for JSON serialization
- `NetworkResult` sealed class for loading/success/error states
- See `data/remote/` package

## Debugging

### iOS

1. Set breakpoints in Xcode
2. Use `Log.debug()` for structured logging (see Logging section above)
3. Use Instruments for performance profiling

### Android

1. Set breakpoints in Android Studio
2. Use `AppLogger.d()` for structured logging (see Logging section above)
3. Use Android Profiler for performance

### Screen Mirroring (Android)

```bash
scrcpy                    # Mirror connected device
scrcpy --record file.mp4  # Record screen
```

## CI/CD

### GitHub Actions

This project includes GitHub Actions workflows in `.github/workflows/`:

- **android.yml** - Runs ktlint, detekt, tests, and builds APK on push/PR
- **ios.yml** - Runs SwiftLint, SwiftFormat, tests, and builds on push/PR

Workflows run automatically when changes are pushed to relevant paths.

### Recommended Release Setup

**iOS:**
- Fastlane for automation
- TestFlight for beta distribution
- App Store Connect for release

**Android:**
- Gradle for builds
- Firebase App Distribution for beta
- Google Play Console for release

## Troubleshooting

### iOS build fails with signing error

1. Open Xcode
2. Select project → Signing & Capabilities
3. Select your team
4. Enable "Automatically manage signing"

### Android Gradle sync fails

```bash
cd android-app
./gradlew --stop           # Stop Gradle daemon
./gradlew clean            # Clean build
./gradlew build            # Rebuild
```

### SwiftLint warnings in generated code

Add to `.swiftlint.yml`:

```yaml
excluded:
  - DerivedData
  - Pods
```

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Kotlin Documentation](https://kotlinlang.org/docs/home.html)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
