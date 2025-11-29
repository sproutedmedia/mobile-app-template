#!/bin/bash
# =============================================================================
# Development Environment Verification Script
# Checks all required and optional tools for mobile development
# Supports: macOS (full), Linux (Android only), Windows WSL (Android only)
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REQUIRED_PASS=0
REQUIRED_FAIL=0
OPTIONAL_PASS=0
OPTIONAL_FAIL=0

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)  OS="macos" ;;
        Linux*)   OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
        *)        OS="unknown" ;;
    esac
}

detect_os

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

check_required() {
    local name=$1
    local check_cmd=$2
    local version_cmd=$3

    if eval "$check_cmd" &> /dev/null; then
        local version=$(eval "$version_cmd" 2>/dev/null | head -1)
        echo -e "  ${GREEN}✅ [REQUIRED] $name${NC} - $version"
        ((REQUIRED_PASS++))
    else
        echo -e "  ${RED}❌ [REQUIRED] $name - NOT INSTALLED${NC}"
        ((REQUIRED_FAIL++))
    fi
}

check_optional() {
    local name=$1
    local check_cmd=$2
    local version_cmd=$3

    if eval "$check_cmd" &> /dev/null; then
        local version=$(eval "$version_cmd" 2>/dev/null | head -1)
        echo -e "  ${GREEN}✅ [OPTIONAL] $name${NC} - $version"
        ((OPTIONAL_PASS++))
    else
        echo -e "  ${YELLOW}⚠️  [OPTIONAL] $name - not installed${NC}"
        ((OPTIONAL_FAIL++))
    fi
}

check_env() {
    local name=$1
    local var_name=$2

    if [ -n "${!var_name}" ]; then
        echo -e "  ${GREEN}✅ $name${NC} = ${!var_name}"
    else
        echo -e "  ${RED}❌ $name - NOT SET${NC}"
        ((REQUIRED_FAIL++))
    fi
}

# =============================================================================
print_header "🔧 Core Development Tools"
# =============================================================================

check_required "Git" "command -v git" "git --version"

if [ "$OS" = "macos" ]; then
    check_required "Homebrew" "command -v brew" "brew --version"
else
    check_optional "Homebrew" "command -v brew" "brew --version"
fi

check_optional "Node.js" "command -v node" "node --version"
check_optional "npm" "command -v npm" "npm --version"

# =============================================================================
print_header "🍎 iOS Development"
# =============================================================================

if [ "$OS" = "macos" ]; then
    check_required "Xcode CLI Tools" "xcode-select -p" "xcode-select --version"
    check_required "SwiftLint" "command -v swiftlint" "swiftlint version"
    check_required "SwiftFormat" "command -v swiftformat" "swiftformat --version"
    check_optional "Fastlane" "command -v fastlane" "fastlane --version"
    check_optional "CocoaPods" "command -v pod" "pod --version"
    check_optional "xcbeautify" "command -v xcbeautify" "xcbeautify --version"
    check_optional "xcodes" "command -v xcodes" "xcodes version"
else
    echo -e "  ${YELLOW}⚠️  iOS development requires macOS${NC}"
    echo -e "  ${YELLOW}   Skipping iOS tool checks on $OS${NC}"
fi

# =============================================================================
print_header "🤖 Android Development"
# =============================================================================

check_required "Java" "command -v java" "java -version 2>&1 | head -1"
check_required "ADB" "command -v adb" "adb --version | head -1"
check_optional "scrcpy" "command -v scrcpy" "scrcpy --version"

echo ""
echo "  Note: ktlint and detekt are Gradle plugins (no standalone install needed)"

# =============================================================================
print_header "🌍 Environment Variables"
# =============================================================================

check_env "ANDROID_HOME" "ANDROID_HOME"
check_env "JAVA_HOME" "JAVA_HOME"

# =============================================================================
print_header "📊 Summary"
# =============================================================================

TOTAL_REQUIRED=$((REQUIRED_PASS + REQUIRED_FAIL))
TOTAL_OPTIONAL=$((OPTIONAL_PASS + OPTIONAL_FAIL))

echo ""
echo -e "  ${GREEN}Required tools:${NC}  $REQUIRED_PASS / $TOTAL_REQUIRED passed"
echo -e "  ${YELLOW}Optional tools:${NC}  $OPTIONAL_PASS / $TOTAL_OPTIONAL installed"
echo ""

if [ $REQUIRED_FAIL -eq 0 ]; then
    echo -e "  ${GREEN}✅ All required tools are installed!${NC}"
    echo ""
    echo "  Your environment is ready for development."
else
    echo -e "  ${RED}❌ $REQUIRED_FAIL required tool(s) missing${NC}"
    echo ""
    echo "  Run the appropriate install script:"
    echo "    ./scripts/install-ios-tools.sh"
    echo "    ./scripts/install-android-tools.sh"
fi

echo ""
