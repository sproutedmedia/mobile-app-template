# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2025-11-30

### Fixed

- **Setup Script** - Fixed directory renaming for test directories
  - iOS: `{{PROJECT_NAME}}Tests` directory now correctly renamed to `${PROJECT_NAME}Tests`
  - Android: `src/test/java/com/{{PACKAGE_NAME}}` directory now correctly renamed

## [1.1.0] - 2025-11-29

### Added

- **MVVM Examples** - Complete User Profile feature demonstrating MVVM on both platforms
  - iOS: User model, UserService protocol, MockUserService, UserProfileViewModel, UserProfileView, EditProfileView
  - Android: User data class, UserRepository, UserRepositoryImpl, FakeUserRepository, UserProfileViewModel, UserProfileScreen, EditProfileDialog
  - Comprehensive unit tests for ViewModels on both platforms

- **Pre-commit Hooks** - Automatic linting before commits
  - `.githooks/pre-commit` script for iOS SwiftLint and Android ktlint checks
  - Documentation in DEVELOPMENT.md for setup

- **iOS Dependencies Guide** - `ios-app/DEPENDENCIES.md` with SPM guidance and recommended packages

- **Enhanced AI Playbooks** - Added to `docs/AI-ASSISTANTS.md`:
  - Example prompts for common tasks
  - Common pitfalls to avoid for iOS, Android, and both platforms

- **New Placeholder** - `{{THEME_NAME}}` for PascalCase theme naming in Android

### Changed

- **CI Workflows** - Fixed reliability issues:
  - iOS: Use default Xcode.app symlink instead of hardcoded version
  - Android: Fixed APK artifact path relative to working directory

- **Android Theme Naming** - Theme now uses `{{THEME_NAME}}Theme` (PascalCase) instead of `{{PROJECT_NAME}}Theme`

- **SwiftLint Configuration** - Enabled `line_length` rule (120 warning, 150 error)

- **Android Dependencies** - Added to version catalog:
  - kotlinx-coroutines-android/test
  - coil-compose for image loading
  - lifecycle-viewmodel-compose

- **Documentation Consolidation** - Merged `AGENTS.md` into `CLAUDE.md` with multi-AI support note

- **Development Docs** - Added pre-commit hook setup and iOS tool execution order

- **Install Scripts** - `install-android-tools.sh` now offers interactive environment variable setup

### Removed

- `AGENTS.md` - Consolidated into `CLAUDE.md`
- Placeholder test files - Replaced with actual ViewModel tests

## [1.0.0] - 2025-11-26

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

[1.1.1]: https://github.com/sproutedmedia/mobile-app-template/releases/tag/v1.1.1
[1.1.0]: https://github.com/sproutedmedia/mobile-app-template/releases/tag/v1.1.0
[1.0.0]: https://github.com/sproutedmedia/mobile-app-template/releases/tag/v1.0.0
