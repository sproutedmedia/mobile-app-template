# Secrets Management Guide

This project uses **1Password CLI** for secure secrets management.

## Policy

**All credentials go through 1Password. No hardcoding. No exceptions.**

## Quick Start

### 1. Install 1Password CLI

```bash
brew install --cask 1password-cli
eval $(op signin)
```

### 2. Create Environment Template

Create a `.env.tpl` file in the project root (safe to commit):

```bash
# .env.tpl - Contains 1Password references, not actual secrets

# Firebase
FIREBASE_API_KEY=op://Development/Firebase-{{PROJECT_NAME}}/api-key

# Backend API
API_BASE_URL=https://api.yourservice.com
API_KEY=op://Development/{{PROJECT_NAME}}-API/api-key

# App Store Connect (for fastlane)
ASC_KEY_ID=op://Development/AppStoreConnect/KEY_ID
ASC_ISSUER_ID=op://Development/AppStoreConnect/ISSUER_ID
```

### 3. Run with Secrets

```bash
# Inject secrets and run command
op run --env-file=.env.tpl -- ./scripts/build.sh

# For fastlane
op run --env-file=.env.tpl -- fastlane beta
```

## Creating 1Password Entries

### Firebase

```bash
op item create \
  --category="API Credential" \
  --vault="Development" \
  --title="Firebase-{{PROJECT_NAME}}" \
  --tags="firebase,mobile" \
  --url="https://console.firebase.google.com" \
  api-key="PASTE_API_KEY" \
  project-id="your-project-id"
```

### App Store Connect (iOS)

```bash
op item create \
  --category="API Credential" \
  --vault="Development" \
  --title="AppStoreConnect-{{PROJECT_NAME}}" \
  --tags="apple,ios,appstore" \
  --url="https://appstoreconnect.apple.com/access/api" \
  KEY_ID="XXXXXXXXXX" \
  ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Then attach the .p8 file as a document
```

### Play Store (Android)

```bash
op document create path/to/service-account.json \
  --vault="Development" \
  --title="PlayStore-{{PROJECT_NAME}}" \
  --tags="google,android,playstore"
```

## .gitignore

Ensure your `.gitignore` includes:

```gitignore
# Environment files (real secrets)
.env
.env.local
.env.*.local

# But NOT .env.tpl (1Password references are safe)
!.env.tpl
```

## Code Patterns

### iOS (Swift)

```swift
// Read from environment (set via 1Password injection)
guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
    fatalError("API_KEY not set. Run with: op run --env-file=.env.tpl -- xcodebuild")
}
```

### Android (Kotlin)

```kotlin
// Read from BuildConfig (set via gradle.properties or env)
val apiKey = BuildConfig.API_KEY
```

### Gradle (build.gradle.kts)

```kotlin
// Read from environment or properties
val apiKey: String = System.getenv("API_KEY") 
    ?: project.findProperty("API_KEY")?.toString() 
    ?: error("API_KEY not set")

buildConfigField("String", "API_KEY", "\"$apiKey\"")
```

## CI/CD Integration

### GitHub Actions

```yaml
jobs:
  build:
    steps:
      - name: Configure 1Password
        uses: 1password/load-secrets-action@v2
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          API_KEY: op://Development/{{PROJECT_NAME}}-API/api-key
```

### fastlane

Use the workspace's `fastlane-release` script which handles 1Password integration automatically, or run fastlane with:

```bash
op run --env-file=.env.tpl -- fastlane beta
```

## Related Documentation

- [1Password CLI Documentation](https://developer.1password.com/docs/cli/)
- Workspace: `~/Developer/workbench/docs/security/1password-cli-cheatsheet.md`

