# {{PROJECT_NAME}}

A cross-platform mobile application for iOS and Android.

## Overview

- **iOS**: SwiftUI with Swift 5.9+
- **Android**: Jetpack Compose with Kotlin

## Quick Start

### Prerequisites

Run the verification script to check your environment:

```bash
./scripts/verify-dev-environment.sh
```

### Install Development Tools

```bash
# iOS tools
./scripts/install-ios-tools.sh

# Android tools
./scripts/install-android-tools.sh
```

### Run the Apps

**iOS:**
```bash
open ios-app/{{PROJECT_NAME}}.xcodeproj
# Or from command line:
cd ios-app && xcodebuild -scheme {{PROJECT_NAME}} -destination 'platform=iOS Simulator,name=iPhone 15' build
```

**Android:**
```bash
cd android-app && ./gradlew assembleDebug
# Or open in Android Studio:
# File > Open > android-app/
```

## Project Structure

```
{{PROJECT_NAME}}/
├── ios-app/                    # iOS application
│   ├── {{PROJECT_NAME}}/       # Source code
│   ├── .swiftlint.yml          # SwiftLint config
│   └── .swiftformat            # SwiftFormat config
├── android-app/                # Android application
│   ├── app/                    # Main app module
│   ├── config/detekt/          # Detekt config
│   └── gradle/                 # Gradle wrapper
├── scripts/                    # Development scripts
│   ├── install-ios-tools.sh
│   ├── install-android-tools.sh
│   └── verify-dev-environment.sh
└── docs/                       # Documentation
    ├── SETUP.md
    └── DEVELOPMENT.md
```

## Code Quality

### iOS

```bash
# Lint
cd ios-app && swiftlint

# Format
cd ios-app && swiftformat .
```

### Android

```bash
cd android-app

# Lint Kotlin code
./gradlew ktlintCheck

# Auto-format Kotlin code
./gradlew ktlintFormat

# Run static analysis
./gradlew detekt
```

## Documentation

- [Setup Guide](docs/SETUP.md) - Detailed environment setup
- [Development Guide](docs/DEVELOPMENT.md) - Development workflow and best practices

## License

Copyright {{DATE}} {{AUTHOR_NAME}}. All rights reserved.
