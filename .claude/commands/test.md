# Run All Tests

Run unit tests for both iOS and Android platforms.

## Arguments

- `$ARGUMENTS` - Optional: "ios" or "android" (defaults to both platforms)

## Instructions

1. Parse the arguments to determine what to test:
   - If empty or "all": test both platforms
   - If "ios": test iOS only
   - If "android": test Android only

2. For iOS tests:
   ```bash
   cd ios-app && xcodebuild test -scheme {{PROJECT_NAME}} -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tail -30
   ```
   Note: This requires Xcode and an available iOS Simulator.

3. For Android tests:
   ```bash
   cd android-app && ./gradlew test
   ```

4. Report test results summary:
   - Number of tests passed/failed
   - Any failing test names and error messages
   - Overall pass/fail status for each platform
