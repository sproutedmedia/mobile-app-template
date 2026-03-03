#!/bin/bash
# =============================================================================
# Template Setup Verification Script
# Checks that setup.sh completed successfully by looking for remaining
# placeholders and verifying directory renames.
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARNINGS=0

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

check_pass() {
    echo -e "  ${GREEN}✅ $1${NC}"
    PASS=$((PASS + 1))
}

check_fail() {
    echo -e "  ${RED}❌ $1${NC}"
    FAIL=$((FAIL + 1))
}

check_warn() {
    echo -e "  ${YELLOW}⚠️  $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# =============================================================================
print_header "🔍 Checking for remaining placeholders"
# =============================================================================

# Files to exclude from placeholder checks:
# - setup.sh (contains placeholders as part of its replacement logic)
# - TEMPLATE-README.md (documents placeholders)
# - *.tpl files (1Password templates use their own references)
# - CHANGELOG.md (version comparison links contain placeholders before setup)
# - CONTRIBUTING.md (contains template placeholders by design)
# - verify-setup.sh (this script references placeholders)
EXCLUDE_PATTERN="setup\.sh|TEMPLATE-README\.md|\.tpl$|CHANGELOG\.md|CONTRIBUTING\.md|verify-setup\.sh"

PLACEHOLDER_FILES=$(grep -rl '{{' . \
    --include="*.swift" \
    --include="*.kt" \
    --include="*.xml" \
    --include="*.gradle.kts" \
    --include="*.toml" \
    --include="*.yml" \
    --include="*.md" \
    --include="*.sh" \
    --include="*.json" \
    --include=".swiftformat" \
    --include=".swiftlint.yml" \
    --include=".cursorrules" \
    2>/dev/null | grep -Ev "$EXCLUDE_PATTERN" || true)

if [ -z "$PLACEHOLDER_FILES" ]; then
    check_pass "No remaining {{ placeholders found in source files"
else
    check_fail "Found remaining {{ placeholders in:"
    while IFS= read -r file; do
        MATCHES=$(grep -n '{{' "$file" 2>/dev/null | head -3 || true)
        echo -e "    ${RED}$file${NC}"
        while IFS= read -r line; do
            [ -n "$line" ] && echo -e "      $line"
        done <<< "$MATCHES"
    done <<< "$PLACEHOLDER_FILES"
fi

# =============================================================================
print_header "🍎 iOS Project Verification"
# =============================================================================

# Check that {{PROJECT_NAME}} directory has been renamed
if [ -d "ios-app/{{PROJECT_NAME}}" ]; then
    check_fail "ios-app/{{PROJECT_NAME}}/ still exists (not renamed by setup.sh)"
else
    # Find the actual project directory (should be something other than template name)
    IOS_DIRS=$(find ios-app -maxdepth 1 -type d ! -name "ios-app" ! -name "fastlane" ! -name "DerivedData" ! -name ".*" 2>/dev/null | head -5)
    if [ -n "$IOS_DIRS" ]; then
        check_pass "iOS app directory renamed"
        echo "$IOS_DIRS" | while read -r dir; do
            echo -e "    Found: $dir"
        done
    else
        check_warn "No iOS app directory found (expected if iOS not set up)"
    fi
fi

# Check pbxproj for remaining placeholders
PBXPROJ=$(find ios-app -name "project.pbxproj" 2>/dev/null | head -1)
if [ -n "$PBXPROJ" ]; then
    if grep -q '{{' "$PBXPROJ" 2>/dev/null; then
        check_fail "project.pbxproj still contains {{ placeholders"
    else
        check_pass "project.pbxproj is clean (no placeholders)"
    fi
else
    check_warn "No .xcodeproj found (expected if iOS not set up or not on macOS)"
fi

# Validate Xcode project if xcodebuild is available
if command -v xcodebuild &> /dev/null; then
    XCODEPROJ=$(find ios-app -name "*.xcodeproj" -maxdepth 1 2>/dev/null | head -1)
    if [ -n "$XCODEPROJ" ]; then
        if xcodebuild -list -project "$XCODEPROJ" &> /dev/null; then
            check_pass "Xcode project is valid (xcodebuild -list succeeds)"
        else
            check_fail "Xcode project is invalid (xcodebuild -list failed)"
        fi
    fi
fi

# =============================================================================
print_header "🤖 Android Project Verification"
# =============================================================================

# Check that {{PACKAGE_NAME}} directory has been renamed
if [ -d "android-app/app/src/main/java/com/{{PACKAGE_NAME}}" ]; then
    check_fail "Android {{PACKAGE_NAME}} package directory still exists (not renamed)"
else
    # Find the actual package directory
    ANDROID_PKG=$(find android-app/app/src/main/java/com -maxdepth 1 -type d ! -name "com" 2>/dev/null | head -5)
    if [ -n "$ANDROID_PKG" ]; then
        check_pass "Android package directory renamed"
        echo "$ANDROID_PKG" | while read -r dir; do
            echo -e "    Found: $dir"
        done
    else
        check_warn "No Android package directory found"
    fi
fi

# Check build.gradle.kts for remaining placeholders
GRADLE_FILES=$(find android-app -name "*.gradle.kts" 2>/dev/null)
if [ -n "$GRADLE_FILES" ]; then
    GRADLE_PLACEHOLDERS=$(echo "$GRADLE_FILES" | xargs grep -l '{{' 2>/dev/null || true)
    if [ -z "$GRADLE_PLACEHOLDERS" ]; then
        check_pass "Gradle build files are clean (no placeholders)"
    else
        check_fail "Gradle build files still contain {{ placeholders:"
        echo "$GRADLE_PLACEHOLDERS" | while read -r file; do
            echo -e "    ${RED}$file${NC}"
        done
    fi
else
    check_warn "No Gradle build files found"
fi

# =============================================================================
print_header "📊 Summary"
# =============================================================================

TOTAL=$((PASS + FAIL))

echo ""
echo -e "  ${GREEN}Passed:${NC}   $PASS / $TOTAL"
if [ $WARNINGS -gt 0 ]; then
    echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
fi
if [ $FAIL -gt 0 ]; then
    echo -e "  ${RED}Failed:${NC}   $FAIL"
fi
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "  ${GREEN}✅ Setup verification passed! Your project is ready.${NC}"
    echo ""
    exit 0
else
    echo -e "  ${RED}❌ Setup verification found $FAIL issue(s).${NC}"
    echo -e "  ${RED}   Re-run setup.sh or fix the issues above manually.${NC}"
    echo ""
    exit 1
fi
