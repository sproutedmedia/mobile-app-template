# {{PROJECT_NAME}} - Setup Guide

Complete guide for setting up your development environment.

## Prerequisites

### macOS

- macOS 13.0+ (Ventura or later)
- Homebrew package manager

### iOS Development

- Xcode 15.0+
- iOS 17.0+ SDK
- Apple Developer account (for device testing)

### Android Development

- Android Studio Hedgehog (2023.1.1) or later
- JDK 17
- Android SDK 34+

## Quick Environment Check

Run this script to verify your setup:

```bash
./scripts/verify-dev-environment.sh
```

## Detailed Setup

### 1. Install Homebrew

If you don't have Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. iOS Tools

Run the installation script:

```bash
./scripts/install-ios-tools.sh
```

This installs:
- **SwiftLint** - Code linting
- **SwiftFormat** - Code formatting
- **Fastlane** - Build automation
- **CocoaPods** - Dependency management
- **xcbeautify** - Build output formatting
- **xcodes** - Xcode version management

### 3. Android Tools

Run the installation script:

```bash
./scripts/install-android-tools.sh
```

This installs:
- **OpenJDK 17** - Java Development Kit
- **ADB** - Android Debug Bridge
- **scrcpy** - Device screen mirroring

#### Environment Variables

The install script will offer to add these automatically. If you prefer manual setup, add to `~/.zshrc`:

```bash
# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Java
export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
```

Then reload: `source ~/.zshrc`

### 4. Android Studio Setup

1. Download from https://developer.android.com/studio
2. Open the `android-app/` folder
3. Let Gradle sync complete
4. Configure an emulator or connect a device

### 5. Xcode Setup

1. Install from Mac App Store
2. Open `ios-app/{{PROJECT_NAME}}.xcodeproj`
3. Select your development team
4. Build and run on simulator

## Troubleshooting

### SwiftLint not found

```bash
brew install swiftlint
```

### ADB not in PATH

```bash
brew install --cask android-platform-tools
```

### Gradle build fails

Ensure JAVA_HOME points to JDK 17:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
```

### Android emulator won't start

Check that virtualization is enabled:
- Intel: Hardware acceleration in BIOS
- Apple Silicon: Works natively

## IDE Extensions

### VS Code / Cursor

- Swift (official)
- Kotlin Language
- Gradle for Java

### Xcode

Built-in Swift support. SwiftLint integration via build phase.

### Android Studio

- Kotlin plugin (built-in)
- ktlint plugin
- detekt plugin

## Next Steps

Once setup is complete:

1. Read the [Development Guide](DEVELOPMENT.md)
2. Run the apps on simulators/emulators
3. Start coding!
