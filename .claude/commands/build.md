# Build Both Platforms

Build the iOS and Android applications.

## Arguments

- `$ARGUMENTS` - Optional: "ios", "android", or "release" (defaults to both platforms, debug builds)

## Instructions

1. Parse the arguments to determine what to build:
   - If empty or "all": build both platforms (debug)
   - If "ios": build iOS only
   - If "android": build Android only
   - If "release": build both platforms in release mode

2. For iOS builds:
   ```bash
   # Debug
   cd ios-app && xcodebuild -scheme {{PROJECT_NAME}} -configuration Debug build 2>&1 | head -50

   # Release
   cd ios-app && xcodebuild -scheme {{PROJECT_NAME}} -configuration Release build 2>&1 | head -50
   ```

3. For Android builds:
   ```bash
   # Debug
   cd android-app && ./gradlew assembleDebug

   # Release
   cd android-app && ./gradlew assembleRelease
   ```

4. Report build success/failure for each platform with any key error messages.
