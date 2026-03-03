# Adopting the Mobile App Template

This guide helps you adopt the template's tooling and conventions into an **existing** project. Each layer is independent — pick what you need.

> **Starting fresh?** Use `setup.sh` instead. This guide is for existing projects that want to adopt specific layers.

## Layers Overview

| Layer | What You Get | Effort |
|-------|-------------|--------|
| [Code Quality](#code-quality) | SwiftLint, SwiftFormat, ktlint, detekt configs | Low |
| [Architecture](#architecture) | MVVM directory conventions | Medium |
| [AI Integration](#ai-integration) | Agent context + slash commands | Low |
| [Security](#security) | Secret detection + credential management | Low |
| [CI/CD](#cicd) | GitHub Actions + Fastlane pipelines | Medium |
| [Dev Tooling](#dev-tooling) | Install + verify scripts | Low |

---

## Code Quality

Consistent linting and formatting across iOS and Android.

### Files to Copy

| File | Destination | Purpose |
|------|-------------|---------|
| `ios-app/.swiftlint.yml` | `<your-ios-dir>/.swiftlint.yml` | SwiftLint rules |
| `ios-app/.swiftformat` | `<your-ios-dir>/.swiftformat` | SwiftFormat config |
| `android-app/config/detekt/` | `<your-android-dir>/config/detekt/` | detekt static analysis config |

### How to Adapt

1. **SwiftLint** — Review disabled rules in `.swiftlint.yml`. Enable or disable rules based on your existing codebase (you may need to disable more rules initially and enable them over time).

2. **SwiftFormat** — The `.swiftformat` file is typically usable as-is. Install with `brew install swiftformat`.

3. **ktlint** — Add the ktlint Gradle plugin to your `android-app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("org.jlleitschuh.gradle.ktlint") version "12.1.2"
   }
   ```

4. **detekt** — Copy `config/detekt/detekt.yml` and add the Gradle plugin:
   ```kotlin
   plugins {
       id("io.gitlab.arturbosch.detekt") version "1.23.7"
   }
   ```

### What to Customize

- Line length limits (default: 120 warning, 150 error)
- Disabled rules — start permissive, tighten over time
- Excluded directories — add generated code paths

---

## Architecture

MVVM directory conventions for both platforms.

### iOS (SwiftUI)

```
<YourApp>/
├── App/                # App entry point, AppDelegate
├── Views/              # SwiftUI views (one per screen)
├── ViewModels/         # ObservableObject view models
├── Models/             # Data models, DTOs
├── Services/           # Business logic, API clients
└── Utilities/          # Extensions, helpers
```

### Android (Jetpack Compose)

```
com/<your-package>/
├── ui/
│   ├── screens/        # Composable screens + ViewModels
│   ├── components/     # Reusable UI components
│   └── theme/          # Material 3 theme
├── data/               # Repositories, data sources, DTOs
└── domain/             # Use cases, domain models
```

### Migration Strategy

1. **Don't refactor everything at once.** Create the target directories and move files gradually.
2. **New code follows the conventions.** Existing code migrates when you touch it.
3. **ViewModels go next to their screens** on Android, in a separate `ViewModels/` directory on iOS.

---

## AI Integration

Project context and slash commands for Claude Code, Cursor, Codex, and Copilot.

### Files to Copy

| File | Destination | Purpose |
|------|-------------|---------|
| `CLAUDE.md` | `CLAUDE.md` (project root) | Universal project context for AI assistants |
| `AGENTS.md` | `AGENTS.md` (project root) | Symlink to CLAUDE.md (for Codex compatibility) |
| `.cursorrules` | `.cursorrules` (project root) | Cursor-specific rules |
| `.github/copilot-instructions.md` | `.github/copilot-instructions.md` | Copilot instructions |
| `.claude/commands/` | `.claude/commands/` | Slash commands |
| `.claude/settings.json` | `.claude/settings.json` | Session hooks |

### Adapting CLAUDE.md

CLAUDE.md is the most important file. Some sections are universal, others need project-specific rewrites.

**Keep verbatim (universal):**
- Security Standards section
- Code Style Guidelines section
- Slash Commands section (if you copy the commands)

**Rewrite for your project:**
- Project name and description (first line + intro paragraph)
- Tech Stack section — match your actual stack
- Project Structure section — reflect your actual directory layout
- Common Commands section — update paths and scheme/target names
- Important Notes section — remove template-specific notes

**Tip:** Run `/adopt` to generate a customized CLAUDE.md automatically.

### Creating AGENTS.md

```bash
ln -s CLAUDE.md AGENTS.md
```

This symlink ensures Codex and future agent systems discover your project context without maintaining a separate file.

---

## Security

Secret detection to prevent accidental credential commits.

### Files to Copy

| File | Destination | Purpose |
|------|-------------|---------|
| `.pre-commit-config.yaml` | `.pre-commit-config.yaml` | Pre-commit hook config |
| `.gitleaks.toml` | `.gitleaks.toml` | Gitleaks secret detection rules |
| `docs/SECRETS.md` | `docs/SECRETS.md` | Credential management documentation |
| `env-template.tpl` | `env-template.tpl` | Example 1Password env template |

### How to Adapt

1. **Install pre-commit:**
   ```bash
   brew install pre-commit
   cd your-project
   pre-commit install
   ```

2. **Customize `.gitleaks.toml`** — Add paths or patterns specific to your project that should be excluded from secret scanning.

3. **Update `docs/SECRETS.md`** — Document which 1Password vault/items your project needs.

4. **Create `.env.tpl` files** — For each service requiring credentials:
   ```
   API_KEY=op://Vault/Item/field
   ```

### What to Customize

- `.gitleaks.toml` allowlist — add known false positives
- `.pre-commit-config.yaml` — add language-specific hooks (e.g., SwiftLint, ktlint)

---

## CI/CD

GitHub Actions workflows and Fastlane deployment pipelines.

### Files to Copy

| File | Destination | Purpose |
|------|-------------|---------|
| `.github/workflows/` | `.github/workflows/` | CI pipelines |
| `.github/PULL_REQUEST_TEMPLATE.md` | `.github/PULL_REQUEST_TEMPLATE.md` | PR checklist |
| `.github/ISSUE_TEMPLATE/` | `.github/ISSUE_TEMPLATE/` | Issue templates |
| `ios-app/fastlane/` | `<your-ios-dir>/fastlane/` | iOS deployment lanes |
| `android-app/fastlane/` | `<your-android-dir>/fastlane/` | Android deployment lanes |
| `.fastlane-config.template` | `.fastlane-config.template` | Credential config template |

### How to Adapt

1. **GitHub Actions** — Update workflow files:
   - Change scheme/target names to match your project
   - Update working directory paths (`working-directory:`)
   - Adjust JDK version if needed (default: 17)

2. **Fastlane** — Update `Appfile` and `Fastfile`:
   - Set your `app_identifier`, `apple_id`, `team_id`
   - Configure signing (match, manual, or automatic)
   - Update lane logic for your deployment targets

3. **PR Template** — Usually usable as-is. Add project-specific checklist items.

4. **Issue Templates** — Run `scripts/customize-issue-templates.sh` to adjust platform options.

### What to Customize

- Workflow triggers (push branches, PR targets)
- Build configurations (Debug/Release, flavors)
- Test destinations (simulator name, device)
- Deployment tracks (TestFlight, Play Console)

---

## Dev Tooling

Setup and verification scripts for development environments.

### Files to Copy

| File | Destination | Purpose |
|------|-------------|---------|
| `scripts/install-ios-tools.sh` | `scripts/install-ios-tools.sh` | Install iOS dev tools |
| `scripts/install-android-tools.sh` | `scripts/install-android-tools.sh` | Install Android dev tools |
| `scripts/verify-dev-environment.sh` | `scripts/verify-dev-environment.sh` | Verify environment |

### How to Adapt

1. **Remove platform scripts you don't need** — iOS-only project? Skip `install-android-tools.sh`.

2. **Update `verify-dev-environment.sh`** — Add checks for project-specific tools (e.g., `firebase-tools`, `cocoapods`).

3. **Add project-specific setup steps** — Database setup, API key configuration, etc.

### What to Customize

- Required tool versions
- Additional Homebrew packages
- Project-specific environment variables

---

## Quick Start

The fastest way to adopt multiple layers at once:

```bash
# From your existing project root
/adopt
```

This interactive command scans your project, identifies what's missing, and copies the relevant files. See the [AI Integration](#ai-integration) section for details.

## Need Help?

- Review the template's `TEMPLATE-README.md` for full feature documentation
- Check `docs/AI-ASSISTANTS.md` for AI assistant workflow playbooks
- Run `/check-env` to verify your development environment after adoption
