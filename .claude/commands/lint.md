# Lint All Code

Run all linting checks for both iOS and Android platforms.

## Instructions

1. Run iOS linting with SwiftLint:
   ```bash
   cd ios-app && swiftlint
   ```

2. Run Android linting with ktlint:
   ```bash
   cd android-app && ./gradlew ktlintCheck
   ```

3. Run Android static analysis with detekt:
   ```bash
   cd android-app && ./gradlew detekt
   ```

4. Report a summary of any issues found across both platforms.

5. If there are fixable issues, offer to run the format command to auto-fix them.
