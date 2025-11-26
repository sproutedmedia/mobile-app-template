# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-26

### Added

- **iOS Scaffold**
  - SwiftUI app structure with `App/` and `Views/` directories
  - `.swiftlint.yml` configuration for code linting
  - `.swiftformat` configuration for code formatting

- **Android Scaffold**
  - Jetpack Compose app with Material 3
  - MVVM architecture with `ui/screens/` and `ui/theme/`
  - Gradle version catalog (`libs.versions.toml`)
  - ktlint plugin for Kotlin linting
  - detekt plugin for static analysis with custom config

- **Development Scripts**
  - `install-ios-tools.sh` - Install iOS development tools via Homebrew
  - `install-android-tools.sh` - Install Android development tools
  - `verify-dev-environment.sh` - Check all required/optional tools

- **Documentation**
  - `README.md` - Project overview (customized per project)
  - `docs/SETUP.md` - Detailed environment setup guide
  - `docs/DEVELOPMENT.md` - Development workflow and best practices
  - `TEMPLATE-README.md` - How to use this template

- **Project Setup**
  - `setup.sh` - Interactive script to customize template placeholders
  - `.gitignore` - Comprehensive ignore file for iOS/Android/IDE files
  - `.github/PULL_REQUEST_TEMPLATE.md` - PR template

### Placeholders

The following placeholders are replaced by `setup.sh`:
- `{{PROJECT_NAME}}` - Project/app name
- `{{PACKAGE_NAME}}` - Android package name
- `{{AUTHOR_NAME}}` - Developer name
- `{{DATE}}` - Setup date

[1.0.0]: https://github.com/sproutedmedia/mobile-app-template/releases/tag/v1.0.0
