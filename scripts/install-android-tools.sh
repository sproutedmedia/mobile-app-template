#!/bin/bash
# =============================================================================
# Android Development Tools Installation Script
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is required. Install from https://brew.sh${NC}"
    exit 1
fi

print_header "Installing Android Development Tools"

# =============================================================================
# [REQUIRED] Java Development Kit
# =============================================================================
print_info "[REQUIRED] Java Development Kit"

if ! command -v java &> /dev/null; then
    print_info "Installing OpenJDK 17..."
    brew install openjdk@17
else
    print_success "Java already installed: $(java -version 2>&1 | head -1)"
fi

# =============================================================================
# [REQUIRED] ADB & Platform Tools
# =============================================================================
print_info "[REQUIRED] ADB & Platform Tools"

if ! command -v adb &> /dev/null; then
    print_info "Installing Android Platform Tools..."
    brew install --cask android-platform-tools
else
    print_success "ADB already installed"
fi

# =============================================================================
# [OPTIONAL] Enhanced Developer Experience
# =============================================================================
print_info "[OPTIONAL] Enhanced Developer Experience"

if ! command -v scrcpy &> /dev/null; then
    print_info "Installing scrcpy (screen mirroring)..."
    brew install scrcpy
else
    print_success "scrcpy already installed"
fi

# =============================================================================
# [INFO] Code Quality Tools
# =============================================================================
print_info "[INFO] Code Quality Tools"
echo ""
echo "  ktlint and detekt are configured as Gradle plugins in this project."
echo "  They will be automatically downloaded when you build the project."
echo ""
echo "  To run linting:"
echo "    ./gradlew ktlintCheck    - Check Kotlin code style"
echo "    ./gradlew ktlintFormat   - Auto-format Kotlin code"
echo "    ./gradlew detekt         - Run static analysis"
echo ""

# =============================================================================
# Environment Setup
# =============================================================================
print_header "Environment Setup"

SHELL_RC="$HOME/.zshrc"
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

print_info "Checking environment variables..."

# Track what needs to be added
NEEDS_ANDROID_HOME=false
NEEDS_JAVA_HOME=false

# Check ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
    print_warning "ANDROID_HOME not set"
    NEEDS_ANDROID_HOME=true
else
    print_success "ANDROID_HOME is set: $ANDROID_HOME"
fi

# Check JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
    print_warning "JAVA_HOME not set"
    NEEDS_JAVA_HOME=true
else
    print_success "JAVA_HOME is set: $JAVA_HOME"
fi

# Offer to add environment variables automatically
if [ "$NEEDS_ANDROID_HOME" = true ] || [ "$NEEDS_JAVA_HOME" = true ]; then
    echo ""
    read -p "Would you like to add missing environment variables to $SHELL_RC? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> "$SHELL_RC"
        echo "# Android Development Environment (added by install-android-tools.sh)" >> "$SHELL_RC"

        if [ "$NEEDS_ANDROID_HOME" = true ]; then
            echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> "$SHELL_RC"
            echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> "$SHELL_RC"
            echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> "$SHELL_RC"
            print_success "Added ANDROID_HOME to $SHELL_RC"
        fi

        if [ "$NEEDS_JAVA_HOME" = true ]; then
            echo 'export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home")' >> "$SHELL_RC"
            print_success "Added JAVA_HOME to $SHELL_RC"
        fi

        echo ""
        print_info "Environment variables added. Run 'source $SHELL_RC' or restart your terminal."
    else
        echo ""
        echo "To manually add the variables, add these lines to $SHELL_RC:"
        echo ""
        if [ "$NEEDS_ANDROID_HOME" = true ]; then
            echo '  export ANDROID_HOME=$HOME/Library/Android/sdk'
            echo '  export PATH=$PATH:$ANDROID_HOME/emulator'
            echo '  export PATH=$PATH:$ANDROID_HOME/platform-tools'
        fi
        if [ "$NEEDS_JAVA_HOME" = true ]; then
            echo '  export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home")'
        fi
        echo ""
    fi
fi

# =============================================================================
# Summary
# =============================================================================
print_header "Android Tools Installation Complete!"

echo "Installed tools:"
echo "  - Java (OpenJDK 17)"
echo "  - ADB (Android Debug Bridge)"
echo "  - scrcpy (screen mirroring)"
echo ""
echo "Gradle plugins (included in project):"
echo "  - ktlint (Kotlin linting)"
echo "  - detekt (static analysis)"
echo ""
echo "Usage:"
echo "  adb devices              - List connected devices"
echo "  scrcpy                   - Mirror device screen"
echo "  ./gradlew ktlintCheck    - Check code style"
echo "  ./gradlew detekt         - Run static analysis"
