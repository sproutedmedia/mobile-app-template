# Mobile App Template

A reusable template for cross-platform iOS and Android mobile applications.

## Features

- **iOS**: SwiftUI scaffold with SwiftLint and SwiftFormat configuration
- **Android**: Jetpack Compose scaffold with ktlint and detekt (via Gradle)
- **Scripts**: Development environment setup and verification
- **Documentation**: Templates for project documentation

## Usage

### 1. Clone or Copy This Template

```bash
# Option A: Clone from GitHub (if hosted as template repo)
gh repo create my-new-app --template your-username/mobile-app-template

# Option B: Copy the directory
cp -r mobile-app-template ~/projects/my-new-app
cd ~/projects/my-new-app
```

### 2. Run the Setup Script

```bash
./setup.sh
```

This will:
- Ask for your project name and configuration
- Replace all `{{PLACEHOLDER}}` values
- Rename directories appropriately
- Initialize a git repository (optional)

### 3. Start Developing

```bash
# Verify environment
./scripts/verify-dev-environment.sh

# Install tools if needed
./scripts/install-ios-tools.sh
./scripts/install-android-tools.sh
```

## Template Structure

```
mobile-app-template/
├── ios-app/
│   ├── {{PROJECT_NAME}}/        # Source code (renamed during setup)
│   │   ├── App/                 # App entry point
│   │   ├── Views/               # SwiftUI views
│   │   ├── ViewModels/          # View models (created during setup)
│   │   ├── Models/              # Data models (created during setup)
│   │   ├── Services/            # Business logic (created during setup)
│   │   └── Utilities/           # Helpers (created during setup)
│   ├── {{PROJECT_NAME}}Tests/   # Unit tests
│   ├── .swiftlint.yml
│   └── .swiftformat
├── android-app/
│   ├── app/src/
│   │   ├── main/java/com/{{PACKAGE_NAME}}/
│   │   │   ├── ui/              # Compose screens, components, theme
│   │   │   ├── data/            # Data layer (created during setup)
│   │   │   └── domain/          # Business logic (created during setup)
│   │   └── test/                # Unit tests
│   ├── config/detekt/
│   └── gradle/
├── scripts/
│   ├── install-ios-tools.sh
│   ├── install-android-tools.sh
│   └── verify-dev-environment.sh
├── .github/
│   ├── workflows/               # CI/CD pipelines
│   ├── copilot-instructions.md  # GitHub Copilot config
│   └── PULL_REQUEST_TEMPLATE.md
├── .claude/                     # Claude Code config
│   ├── commands/                # Slash commands
│   └── settings.json            # Session hooks
├── docs/
├── setup.sh                     # Template customization script
├── CLAUDE.md                    # Claude Code context
├── AGENTS.md                    # Codex CLI context
├── .cursorrules                 # Cursor rules
└── README.md
```

## Placeholders

The following placeholders are replaced by `setup.sh`:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{PROJECT_NAME}}` | Project/app name | `MyAwesomeApp` |
| `{{PACKAGE_NAME}}` | Android package | `myawesomeapp` |
| `{{AUTHOR_NAME}}` | Developer name | `John Doe` |
| `{{DATE}}` | Setup date | `2024-01-15` |

## Requirements

- macOS 13.0+
- Homebrew
- Xcode 15+ (for iOS)
- Android Studio (for Android)
- JDK 17

## AI Assistant Integration

This template includes configuration for multiple AI coding assistants:

| Tool | Config File | Description |
|------|-------------|-------------|
| **Claude Code** | `CLAUDE.md`, `.claude/` | Project context, slash commands, session hooks |
| **Codex CLI** | `AGENTS.md` | Project context for OpenAI Codex |
| **Cursor** | `.cursorrules` | Project rules and code style guidelines |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Code generation instructions |

### Claude Code Slash Commands

| Command | Description |
|---------|-------------|
| `/lint` | Run all linting checks (iOS + Android) |
| `/format` | Auto-format all code |
| `/build` | Build both platforms |
| `/test` | Run all tests |
| `/check-env` | Verify development environment |
| `/new-screen` | Generate a new screen with MVVM structure |

### Workflow Playbooks

See `docs/AI-ASSISTANTS.md` for detailed playbooks that work across all AI assistants.

## Customization

Feel free to modify this template:

- Add more starter code in iOS/Android apps
- Customize linter configurations
- Add CI/CD templates (.github/workflows/)
- Add more documentation templates
- Add custom slash commands in `.claude/commands/`

## License

This template is free to use for any project.
