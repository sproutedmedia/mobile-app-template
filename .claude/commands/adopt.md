# Adopt Template Into Existing Project

Adopt layers from the mobile app template into an existing project.

## Arguments

- `$ARGUMENTS` - Optional: comma-separated layers to adopt (e.g., "code-quality,security")

## Instructions

1. If `$ARGUMENTS` is provided, parse the comma-separated layer names. Valid layers:
   - `code-quality` — SwiftLint, SwiftFormat, ktlint, detekt configs
   - `architecture` — MVVM directory conventions
   - `ai` — CLAUDE.md, AGENTS.md, .cursorrules, .claude/ commands, .github/copilot-instructions.md
   - `security` — .pre-commit-config.yaml, .gitleaks.toml, docs/SECRETS.md, .env.tpl pattern
   - `cicd` — .github/workflows/, fastlane/, issue templates, PR template
   - `dev-tooling` — scripts/ (install + verify scripts)

   If no arguments provided, ask the user which layers to adopt using a multi-select list showing all six layers with descriptions.

2. Ask the user which platform(s) their project targets: iOS only, Android only, or both.

3. Scan the current project directory to understand its structure:
   - Look for iOS indicators: `.xcodeproj`, `.xcworkspace`, `Package.swift`, `Sources/` with Swift files
   - Look for Android indicators: `build.gradle`, `build.gradle.kts`, `app/src/main/java/`
   - Look for existing config files that might conflict (.swiftlint.yml, .swiftformat, detekt.yml, CLAUDE.md, .pre-commit-config.yaml, etc.)
   - Identify the iOS source directory (e.g., `MyApp/`, `Sources/`, `ios/`)
   - Identify the Android source directory (e.g., `app/`, `android/`)

4. For each selected layer, report what already exists vs what's missing:

   **Code Quality** (skip items for platforms not selected):
   - Check for `.swiftlint.yml` (iOS)
   - Check for `.swiftformat` (iOS)
   - Check for `config/detekt/` (Android)
   - Check for ktlint in `build.gradle`/`build.gradle.kts` (Android)

   **Architecture:**
   - Check for MVVM directories (Views/, ViewModels/, Models/, Services/ for iOS)
   - Check for MVVM directories (ui/screens/, ui/components/, data/, domain/ for Android)
   - Report existing structure and suggest reorganization steps

   **AI Integration:**
   - Check for `CLAUDE.md`
   - Check for `AGENTS.md`
   - Check for `.cursorrules`
   - Check for `.claude/commands/`
   - Check for `.github/copilot-instructions.md`

   **Security:**
   - Check for `.pre-commit-config.yaml`
   - Check for `.gitleaks.toml`
   - Check for `docs/SECRETS.md`
   - Check if `pre-commit` is installed (`which pre-commit`)

   **CI/CD:**
   - Check for `.github/workflows/`
   - Check for `fastlane/` directories
   - Check for `.github/PULL_REQUEST_TEMPLATE.md`
   - Check for `.github/ISSUE_TEMPLATE/`

   **Dev Tooling:**
   - Check for `scripts/` directory
   - Check for install/verify scripts

5. Present the delta to the user: list what will be added, what already exists (skip), and what might need manual adaptation. Ask for confirmation before proceeding.

6. For each confirmed layer, create the missing files:

   **Code Quality:**
   - Copy lint/format configs into the appropriate directories for the user's platform(s)
   - Adapt file paths in configs if the user's directory structure differs from the template

   **Architecture:**
   - Create missing MVVM directories
   - Do NOT move existing files — just create the target structure and tell the user what to migrate

   **AI Integration:**
   - Generate a customized `CLAUDE.md` based on the user's actual project:
     - Use the project name from the directory name or ask the user
     - Detect the tech stack from project files
     - Map the actual directory structure
     - Keep Security Standards and Code Style Guidelines sections verbatim from the template
     - Keep Slash Commands section if copying commands
     - Rewrite Project Structure and Common Commands to match the actual project
   - Create `AGENTS.md` as a symlink to `CLAUDE.md`: `ln -s CLAUDE.md AGENTS.md`
   - Copy `.cursorrules`, adapting project-specific references
   - Copy `.github/copilot-instructions.md`
   - Copy `.claude/commands/` (all slash commands)
   - Copy `.claude/settings.json`

   **Security:**
   - Copy `.pre-commit-config.yaml` and `.gitleaks.toml`
   - Create `docs/SECRETS.md` with project-specific instructions
   - Run `pre-commit install` if pre-commit is available
   - Create an `env-template.tpl` example

   **CI/CD:**
   - Copy workflow files, updating paths and names for the user's project
   - Copy PR template and issue templates
   - If Fastlane: copy lane files, remind user to configure `.fastlane-config`

   **Dev Tooling:**
   - Copy relevant install/verify scripts based on selected platforms
   - Update script paths for the user's project structure

7. Print a summary:

   ```
   ## Adoption Summary

   ### Added
   - [list of files created]

   ### Skipped (already exists)
   - [list of files that already existed]

   ### Next Steps
   - [actionable items the user should do manually]
   ```

   Next steps should include:
   - Review and customize any copied config files
   - Run `/lint` to check current code against new lint rules
   - Run `/check-env` to verify development environment
   - Commit the new config files
   - For CI/CD: update workflow files with project-specific values
   - For Security: run `pre-commit install` if not done automatically
