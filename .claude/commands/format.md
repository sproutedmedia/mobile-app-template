# Format All Code

Auto-format code for both iOS and Android platforms.

## Instructions

1. Format iOS code with SwiftFormat:
   ```bash
   cd ios-app && swiftformat .
   ```

2. Format Android code with ktlint:
   ```bash
   cd android-app && ./gradlew ktlintFormat
   ```

3. Report what files were modified by the formatters.

4. After formatting, run a quick lint check to verify everything passes.
