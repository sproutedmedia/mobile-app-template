# {{PROJECT_NAME}} - AI Assistant Guide

Guidance for using Claude Code or Codex/Cursor-style assistants with this template. Use these tips to keep sessions grounded in project context and to automate common tasks on iOS (SwiftUI) and Android (Jetpack Compose).

## Quick Start

1. **Load project context**
   - Claude Code: open `CLAUDE.md` and the relevant platform folders (`ios-app/` and `android-app/`).
   - Codex-style tools: provide the repo root and mention this file plus `CLAUDE.md` so the assistant learns the stack and commands.
2. **Run a baseline check**
   - Use `/check-env` in Claude or run `./scripts/verify-dev-environment.sh` to confirm required tools before coding.
3. **Pick a workflow**
   - iOS: Xcode + SwiftLint/SwiftFormat.
   - Android: Android Studio + ktlint/detekt.

## Recommended Slash Commands (Claude Code)

Use these built-in commands to automate common chores:

- `/lint` – Run lint for iOS and Android.
- `/format` – Auto-format Swift and Kotlin.
- `/build` – Build both platforms.
- `/test` – Execute all tests.
- `/check-env` – Verify dev tools.
- `/new-screen` – Scaffold a screen with MVVM wiring.

## Playbooks for Claude or Codex

### Add a new screen

1. Run `/new-screen` (Claude) or ask Codex to duplicate an existing screen pattern in `ios-app/{{PROJECT_NAME}}/Views/` and `android-app/app/src/main/java/com/{{PACKAGE_NAME}}/ui/screens/`.
2. Wire view models in `ViewModels/` (iOS) or `ui/screens` + `domain/` (Android).
3. Update navigation in `App/` (iOS) or `MainActivity.kt`/`Navigation` utilities (Android).
4. Format and lint: `/format` then `/lint`.

### Triage a failing build

1. Run `/build` or platform-specific Gradle/xcodebuild commands.
2. Ask the assistant to summarize the first failing target/task.
3. Apply the suggested fix, then rerun `/build` to confirm.

### Code quality loop

1. Start changes in a feature branch.
2. Use `/format` early to keep diffs small.
3. Run `/lint` and `/test` before pushing to CI.
4. Ask the assistant for a brief changelog entry referencing `CHANGELOG.md`.

## Prompting Tips

- **Be explicit about platform**: e.g., “Update the SwiftUI login screen in `ios-app/{{PROJECT_NAME}}/Views/LoginView.swift`.”
- **Limit scope**: include file paths or function names to keep edits focused.
- **Request safety checks**: ask for Swift concurrency notes or Compose state hoisting guidance when relevant.
- **Prefer tool commands**: let the assistant call `/lint`, `/format`, or `/build` instead of running ad-hoc scripts.

## Validation Checklist (for both assistants)

- [ ] Code formatted (SwiftFormat / ktlint).
- [ ] Lint clean (SwiftLint / detekt).
- [ ] Tests pass (`xcodebuild test`, `./gradlew test`).
- [ ] Placeholders replaced after running `./setup.sh`.
- [ ] Screens follow MVVM and keep UI logic thin.

Keep this file handy in AI sessions so both Claude Code and Codex provide consistent, high-signal help.
