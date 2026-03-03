# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-03-03

### Added

- **CONTRIBUTING.md** — Contribution guidelines with quick start, branch naming, commit conventions, pre-PR checklist, code review expectations, and links to issue templates (#8)

- **`scripts/verify-setup.sh`** — Post-setup verification script that checks for remaining `{{` placeholders in source files, validates iOS directory renames and Xcode project integrity, and verifies Android package directory renames and Gradle files (#9)

- **`.env.example`** — Documents all environment variables with placeholder values for API config, analytics, Firebase, feature flags, and debug settings. Explains relationship to `env-template.tpl` for 1Password integration (#10)

### Changed

- **`setup.sh`** — Added `verify-setup.sh` as first recommended next step after setup completes
- **`docs/SETUP.md`** — Added "Environment Variables" section covering `.env.example` vs `env-template.tpl`, iOS scheme env vars, Android `local.properties` + `buildConfigField` pattern, and link to `docs/SECRETS.md`
- **`README.md`** — Added `verify-setup.sh` to project structure tree and CONTRIBUTING.md link to documentation section
- **`TEMPLATE-README.md`** — Added `verify-setup.sh` to scripts tree, `CONTRIBUTING.md` and `.env.example` to root file listing
- **Android Release Builds** — Enabled R8 minification (`isMinifyEnabled = true`) and resource shrinking (`isShrinkResources = true`) for release build type. Added baseline ProGuard rules for Kotlin, coroutines, and Jetpack Compose with commented examples for common libraries (Retrofit, Gson, Moshi, Room, Firebase) (#11)

- **Structured Logging** — Added platform-native logging utilities (#15)
  - iOS: `Log` enum wrapping OSLog with debug/info/warning/error levels and category support; debug logs stripped from release builds
  - Android: `AppLogger` wrapping Timber with tag-based logging; initialized in `{{THEME_NAME}}Application`

- **Networking Layer** — Added API client boilerplate with error handling (#14)
  - iOS: `APIClient` actor with async/await, `Endpoint` enum for type-safe API definitions, `APIError` for structured errors
  - Android: Retrofit + OkHttp + Gson setup with `ApiService` interface, `ApiClient` singleton, `NetworkResult` sealed class, debug logging interceptor

- **Settings Screen** — Complete reference feature demonstrating MVVM, navigation, and local persistence (#13)
  - iOS: `SettingsView` + `SettingsViewModel` using `@AppStorage` for persistence, navigation via toolbar gear icon
  - Android: `SettingsScreen` + `SettingsViewModel` using DataStore Preferences, navigation via top bar settings icon
  - Both: Dark mode toggle, notifications toggle, app version display, unit tests

### Dependencies Added

- **Android**: Timber 5.0.1, Retrofit 2.11.0, OkHttp logging 4.12.0, Gson converter, DataStore Preferences 1.1.1, Material Icons Extended

## [1.4.0] - 2026-03-03

### Added

- **AGENTS.md Symlink** — `AGENTS.md` symlinks to `CLAUDE.md`, making the repo discoverable by Codex and future agent systems while keeping a single source of truth

- **Adoption Guide** — `docs/ADOPTION.md` migration playbook for existing projects
  - Six independent layers: Code Quality, Architecture, AI Integration, Security, CI/CD, Dev Tooling
  - Each layer lists files to copy, how to adapt them, and what to customize
  - Includes guidance on adapting CLAUDE.md for existing projects

- **`/adopt` Slash Command** — Agent-assisted adoption flow in `.claude/commands/adopt.md`
  - Multi-select layer picker (or pass layers as arguments)
  - Platform detection (iOS, Android, or both)
  - Scans existing project structure and reports delta
  - Copies and adapts config files for each selected layer
  - Generates customized CLAUDE.md reflecting the actual project

### Changed

- **TEMPLATE-README.md** — Added Codex row to AI assistant table, `/adopt` to slash commands, and adoption section
- **CLAUDE.md** — Added `/adopt` to slash commands list and adoption note in Important Notes

## [1.3.0] - 2025-12-03

### Added

- **Fastlane Deployment** - Pre-configured deployment pipelines for both platforms
  - iOS: `ios-app/fastlane/` with TestFlight (beta) and App Store (release) lanes
  - Android: `android-app/fastlane/` with Play Console internal and production tracks
  - Gemfiles for fastlane dependencies
  - Appfiles with placeholder configuration

- **Secure Credential Management Template** - `.fastlane-config.template` for deployment credential management
  - Documents App Store Connect API keys and Play Console service account setup
  - Supports 1Password CLI (`op`) integration for secure credential injection
  - Never commit credentials to git

### Documentation

- Added deployment instructions to setup process
- Fastlane lanes: `beta`, `release`, `build`, `bump`, `test`

## [1.2.0] - 2025-12-01

### Added

- **GitHub Issue Templates** - Pre-configured templates for streamlined issue tracking
  - `bug_report.md` - Bug reports with platform, severity, and reproduction steps
  - `feature_request.md` - Feature requests with acceptance criteria
  - `task.md` - Task tracking with dependencies
  - `config.yml` - Disables blank issues, links to documentation

- **Issue Template Customization Script** - `scripts/customize-issue-templates.sh`
  - Remove "Backend API" platform option for frontend-only projects
  - Add "Web App" platform option for cross-platform projects
  - Configure default labels (adds `needs-triage` to bug reports)

- **New Placeholder** - `{{GITHUB_OWNER}}` for GitHub username/org in issue template links

### Changed

- **Setup Script** - Now prompts for GitHub username/org to configure issue template documentation links

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
- `{{GITHUB_OWNER}}` - GitHub username/org
- `{{DATE}}` - Setup date

[1.5.0]: https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/releases/tag/v1.5.0
[1.4.0]: https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/releases/tag/v1.4.0
[1.3.0]: https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/releases/tag/v1.3.0
[1.2.0]: https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/releases/tag/v1.2.0
[1.1.1]: https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/releases/tag/v1.1.1
[1.1.0]: https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/releases/tag/v1.1.0
[1.0.0]: https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/releases/tag/v1.0.0
