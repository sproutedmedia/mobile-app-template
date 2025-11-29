# Check Development Environment

Verify that all required development tools are installed and configured.

## Instructions

1. Run the environment verification script:
   ```bash
   ./scripts/verify-dev-environment.sh
   ```

2. Analyze the output and provide a summary:
   - List all tools that are properly installed with versions
   - Highlight any missing required tools
   - Note any missing optional tools that might be helpful

3. If there are missing tools, suggest running the appropriate install script:
   - `./scripts/install-ios-tools.sh` for iOS tools
   - `./scripts/install-android-tools.sh` for Android tools

4. Check environment variables:
   - Verify ANDROID_HOME is set correctly
   - Verify JAVA_HOME is set correctly

5. Provide actionable next steps if any issues are found.
