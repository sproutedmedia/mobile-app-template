# Code Review: Mobile App Template

**Review Date:** November 29, 2025  
**Reviewer:** Third-party code review

## Overall Assessment: Strong Foundation with Room for Improvement

This is a well-structured template with thoughtful AI assistant integration. Below are my findings organized by category.

---

## ✅ Strengths

### 1. Multi-AI-Assistant Support
Excellent approach supporting Claude Code, Cursor, Copilot, and Codex. The slash commands in `.claude/commands/` and the session hook in `.claude/settings.json` are particularly well-designed.

### 2. Comprehensive Automation
- Setup script handles cross-platform concerns (macOS, Linux, Windows)
- Verification script checks both required and optional tools
- Install scripts are idempotent and well-structured

### 3. Modern Tech Stack
- Swift 5.9+ with SwiftUI and proper MVVM
- Kotlin 2.0+ with Compose and Material 3
- Version catalog in `libs.versions.toml` (good practice)

### 4. Code Quality Tooling
Strong linting/formatting setup with SwiftLint, SwiftFormat, ktlint, and detekt properly configured.

---

## ⚠️ Issues & Recommendations

### **CRITICAL ISSUES**

#### 1. Missing iOS Xcode Project File
The `setup.sh` script (lines 150-200) attempts to generate an Xcode `.xcodeproj` file, but:
- The template is incomplete (cuts off at line 200)
- No actual `.xcodeproj` exists in the repository
- Users cannot open the iOS project in Xcode without this

**Impact:** iOS development is blocked until setup runs, and the generation logic is complex/fragile.

**Recommendation:** Include a real `.xcodeproj` file in the template with `{{PROJECT_NAME}}` placeholders. Let Xcode manage the project structure—it's more reliable than shell-scripting pbxproj files.

#### 2. Android detekt Config Missing
- `app/build.gradle.kts:58` references `$rootDir/config/detekt/detekt.yml`
- The file isn't in the repository
- Builds will fail when running `./gradlew detekt`

**Fix:** Add `android-app/config/detekt/detekt.yml`:
```yaml
build:
  maxIssues: 0

config:
  validation: true
  warningsAsErrors: false

style:
  MaxLineLength:
    maxLineLength: 120
    excludeCommentStatements: true
```

#### 3. CI Workflows Will Fail
Both GitHub Actions workflows have issues:

**iOS (`.github/workflows/ios.yml:26`):**
- Hardcodes Xcode 15.2 path: `sudo xcode-select -s /Applications/Xcode_15.2.app`
- GitHub Actions runners may not have this exact version
- **Fix:** Use `sudo xcode-select --switch /Applications/Xcode_15.4.app` or detect latest available version

**Android (`.github/workflows/android.yml:51`):**
- References `android-app/app/build/outputs/apk/debug/*.apk`
- Should be relative to working directory: `app/build/outputs/apk/debug/*.apk`

**Fix:** Update path in android.yml line 51.

---

### **HIGH PRIORITY**

#### 4. Incomplete `setup.sh` Script
The script appears truncated at line 200 during the Xcode project generation section.

**Action:** Review the full `setup.sh` to ensure it's complete and functional. The pbxproj generation appears to be cut off mid-file.

#### 5. iOS Project Structure Mismatch
The template claims to create ViewModels/Models/Services directories during setup (lines 136-140), but:
- The actual iOS template only has `App/` and `Views/` directories
- The example code (`ContentView.swift`, `{{PROJECT_NAME}}App.swift`) doesn't demonstrate MVVM
- No actual ViewModel implementations exist

**Recommendation:** Either:
- Include sample ViewModel files (e.g., `ContentViewModel.swift` with actual implementation)
- Or remove MVVM claims from documentation until structure is demonstrated with working code

#### 6. Android Theme Class Name Issue
`MainActivity.kt:7` references `{{PROJECT_NAME}}Theme`, but:
- Package names typically use lowercase (e.g., `myapp`)
- Class names should be PascalCase (e.g., `MyAppTheme`)
- The placeholder replacement creates invalid class names like `my-awesome-appTheme`

**Fix:** Use a separate `{{THEME_NAME}}` placeholder or generate PascalCase programmatically in `setup.sh`:
```bash
# Convert PROJECT_NAME to PascalCase for theme
THEME_NAME=$(echo "$PROJECT_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
```

---

### **MEDIUM PRIORITY**

#### 7. Documentation Inconsistencies

**AGENTS.md vs CLAUDE.md:**
- Both files are nearly identical (90% duplicate content)
- `AGENTS.md` says it's for "Codex CLI" which doesn't exist as a standalone tool
- Confusing which file to read

**Recommendation:** Consolidate into `CLAUDE.md` and add a note at the top:
> "This context file works with Claude Code, Cursor, Codex, and other AI assistants."

Remove or significantly reduce `AGENTS.md` to avoid confusion.

#### 8. Missing Test Infrastructure
- iOS has `ExampleViewModelTests.swift` but no actual ViewModel to test
- Android has `ExampleViewModelTest.kt` but no ViewModel implementation
- Tests will fail out of the box, creating a poor first impression

**Fix:** Either:
- Include working example tests with actual ViewModels
- Or remove placeholder test files and document how to add tests in `docs/DEVELOPMENT.md`

#### 9. SwiftLint Configuration Gaps
`.swiftlint.yml` disables `line_length` entirely (line 6). Modern Swift projects typically enforce reasonable line length limits.

**Recommendation:** Set a reasonable limit:
```yaml
line_length:
  warning: 120
  error: 150
  ignores_comments: true
```

#### 10. No Dependency Management for iOS
The template mentions CocoaPods in documentation but:
- No `Podfile` exists
- No Swift Package Manager setup
- Documentation suggests both but implements neither

**Recommendation:** Choose one approach:
- **Option A (Recommended):** Add SPM dependencies to the generated `.xcodeproj`
- **Option B:** Include a basic `Podfile` template:
```ruby
platform :ios, '17.0'

target '{{PROJECT_NAME}}' do
  use_frameworks!
  
  # Add your pods here
  # pod 'Alamofire', '~> 5.0'
end
```

---

### **LOW PRIORITY / POLISH**

#### 11. Gradle Version Catalog Could Be More Complete
`libs.versions.toml` is basic. Consider adding common dependencies:
```toml
[versions]
coroutines = "1.7.3"
navigation = "2.7.6"
coil = "2.5.0"

[libraries]
kotlinx-coroutines-android = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-android", version.ref = "coroutines" }
androidx-navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigation" }
coil-compose = { group = "io.coil-kt", name = "coil-compose", version.ref = "coil" }
```

#### 12. Missing Pre-commit Hooks
Great CI setup, but no local pre-commit hooks to catch issues before push.

**Add:** `.githooks/pre-commit` script:
```bash
#!/bin/bash
set -e

echo "Running pre-commit checks..."

# Check iOS
if git diff --cached --name-only | grep -q "^ios-app/"; then
    echo "Checking iOS code..."
    cd ios-app && swiftlint --strict && cd ..
fi

# Check Android
if git diff --cached --name-only | grep -q "^android-app/"; then
    echo "Checking Android code..."
    cd android-app && ./gradlew ktlintCheck detekt && cd ..
fi

echo "Pre-commit checks passed!"
```

Then document in README: `git config core.hooksPath .githooks`

#### 13. AI Assistant Playbooks Could Be More Specific
`docs/AI-ASSISTANTS.md` is good but generic. Consider adding:
- **Example prompts** for common tasks:
  - "Add a new login screen with email/password fields following MVVM"
  - "Create a repository for fetching users from https://api.example.com/users"
- **Troubleshooting** common AI mistakes:
  - "AI forgets to update navigation routes"
  - "AI creates ViewModels without @MainActor (iOS) or proper StateFlow (Android)"

#### 14. Environment Variable Setup Could Be Automated
`install-android-tools.sh` prints instructions for `~/.zshrc` but doesn't apply them.

**Enhancement:** Offer to append automatically:
```bash
read -p "Add environment variables to ~/.zshrc? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo '' >> ~/.zshrc
    echo '# Android Development' >> ~/.zshrc
    echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
    echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
    echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
    echo 'Added to ~/.zshrc - please restart your terminal'
fi
```

#### 15. SwiftFormat vs SwiftLint Overlap
Both tools handle some of the same issues (e.g., spacing). The `.swiftformat` is comprehensive, but consider documenting the order:

**Add to `docs/DEVELOPMENT.md`:**
```markdown
## iOS Code Quality Order

Run these commands in sequence:
1. `swiftformat .` - Fixes formatting issues
2. `swiftlint` - Catches logic and style issues

SwiftFormat runs first because it auto-fixes many issues that SwiftLint would otherwise flag.
```

---

## 📊 Summary Scores

| Category | Score | Notes |
|----------|-------|-------|
| **Structure** | 8/10 | Clean, logical organization |
| **Completeness** | 5/10 | Missing critical files (Xcode project, detekt config) |
| **Documentation** | 7/10 | Thorough but some duplication |
| **Automation** | 9/10 | Excellent scripts and AI integration |
| **Code Quality** | 7/10 | Good tooling, but missing implementations |
| **CI/CD** | 6/10 | Present but has issues |

**Overall: 7/10** - Strong concept with execution gaps that will frustrate new users.

---

## 🎯 Recommended Action Plan

### 1. Critical (Do First)
- [ ] Add working iOS `.xcodeproj` file to template
- [ ] Add `android-app/config/detekt/detekt.yml`
- [ ] Fix Android theme placeholder naming (PascalCase)
- [ ] Fix CI workflow paths and Xcode version references
- [ ] Complete/verify `setup.sh` script (appears truncated)

### 2. High Priority
- [ ] Add example ViewModels to demonstrate MVVM properly
- [ ] Consolidate `AGENTS.md` and `CLAUDE.md`
- [ ] Fix or remove placeholder test files

### 3. Medium Priority
- [ ] Add iOS dependency management (SPM or CocoaPods)
- [ ] Fix SwiftLint line length configuration
- [ ] Enhance Android version catalog with common dependencies

### 4. Polish
- [ ] Add pre-commit hooks
- [ ] Enhance AI playbooks with specific examples
- [ ] Automate environment variable setup
- [ ] Document tool execution order

---

## Final Thoughts

This template has **excellent bones**—the automation, cross-platform support, and AI integration are standout features. However, the critical missing pieces (Xcode project, detekt config, working MVVM examples) will prevent users from getting started smoothly.

**Fixing the critical issues will make this production-ready.** The template shows clear expertise in both iOS and Android development, and once the gaps are filled, it will be a valuable resource for bootstrapping mobile projects.

If you'd like deeper analysis on any specific area (e.g., setup script refactoring, example MVVM implementations, or CI/CD improvements), I'm happy to dive in further.
