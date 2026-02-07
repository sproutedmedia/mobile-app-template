# Mobile App Template - Claude Context

> **Note:** This context file works with Claude Code, Cursor, GitHub Copilot, Codex, and other AI coding assistants. The instructions and patterns documented here are universal.

This is a cross-platform mobile application template for iOS and Android.

## Tech Stack

- **iOS**: SwiftUI with Swift 5.9+, MVVM architecture
- **Android**: Jetpack Compose with Kotlin 2.0+, MVVM architecture

## Project Structure

```
├── ios-app/                    # iOS application (SwiftUI)
│   ├── {{PROJECT_NAME}}/       # Source code
│   │   ├── App/                # App entry point
│   │   ├── Views/              # SwiftUI views
│   │   ├── ViewModels/         # View models
│   │   ├── Models/             # Data models
│   │   ├── Services/           # Business logic, API
│   │   └── Utilities/          # Helpers, extensions
│   ├── .swiftlint.yml          # Linting rules
│   └── .swiftformat            # Formatting rules
├── android-app/                # Android application (Jetpack Compose)
│   ├── app/src/main/java/      # Kotlin source
│   │   └── com/{{PACKAGE_NAME}}/
│   │       ├── ui/screens/     # Compose screens
│   │       ├── ui/components/  # Reusable components
│   │       ├── ui/theme/       # Material Design 3 theme
│   │       ├── data/           # Data layer
│   │       └── domain/         # Business logic
│   └── config/detekt/          # Static analysis config
├── scripts/                    # Development automation
└── docs/                       # Documentation
```

## Common Commands

### Environment Setup
```bash
./scripts/verify-dev-environment.sh   # Check all tools
./scripts/install-ios-tools.sh        # Install iOS tools
./scripts/install-android-tools.sh    # Install Android tools
```

### iOS Development
```bash
# Linting and formatting
cd ios-app && swiftlint                # Check for violations
cd ios-app && swiftformat .            # Auto-format code

# Building
cd ios-app && xcodebuild -scheme {{PROJECT_NAME}} -configuration Debug build

# Testing
cd ios-app && xcodebuild test -scheme {{PROJECT_NAME}} -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Android Development
```bash
# Linting and formatting
cd android-app && ./gradlew ktlintCheck    # Check Kotlin style
cd android-app && ./gradlew ktlintFormat   # Auto-format Kotlin
cd android-app && ./gradlew detekt         # Static analysis

# Building
cd android-app && ./gradlew assembleDebug  # Debug APK
cd android-app && ./gradlew assembleRelease # Release APK

# Testing
cd android-app && ./gradlew test           # Unit tests
cd android-app && ./gradlew check          # All checks
```

### Deployment (Fastlane)

```bash
# Setup (first time only)
cp .fastlane-config.template .fastlane-config
# Edit .fastlane-config with your 1Password vault/item details

# iOS - TestFlight
fastlane-release beta

# iOS - App Store
fastlane-release release

# Android - Internal Track
cd android-app/fastlane && bundle exec fastlane beta

# Android - Production
cd android-app/fastlane && bundle exec fastlane release version_name:X.Y.Z
```

## Code Style Guidelines

- **iOS**: Follow SwiftLint rules in `.swiftlint.yml`, format with SwiftFormat
- **Android**: Follow ktlint conventions, pass detekt static analysis
- **Both**: Use MVVM pattern, keep views/screens thin, business logic in ViewModels

## Slash Commands

This project includes Claude Code slash commands for common tasks:

- `/lint` - Run all linting checks (iOS + Android)
- `/format` - Auto-format all code
- `/build` - Build both platforms
- `/test` - Run all tests
- `/check-env` - Verify development environment
- `/new-screen` - Generate a new screen with proper structure

See `docs/AI-ASSISTANTS.md` for side-by-side guidance that also applies when developers use Codex or similar tools.

## Important Notes

- This is a **template** - placeholders like `{{PROJECT_NAME}}` are replaced by `setup.sh`
- Run `./setup.sh` first to customize the template for a new project
- iOS requires macOS with Xcode 15+
- Android requires JDK 17 and Android SDK 34+

## Security Standards

This project follows workspace security standards:
- All credentials go through 1Password
- No hardcoding secrets, ever
- Use .env.tpl with op:// references

See: ~/Developer/cursor-workspaces/docs/security/
