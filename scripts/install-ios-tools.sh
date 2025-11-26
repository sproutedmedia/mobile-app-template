#!/bin/bash
# =============================================================================
# iOS Development Tools Installation Script
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

print_header "Installing iOS Development Tools"

# =============================================================================
# [REQUIRED] Code Quality Tools
# =============================================================================
print_info "[REQUIRED] Code Quality Tools"

if ! command -v swiftlint &> /dev/null; then
    print_info "Installing SwiftLint..."
    brew install swiftlint
else
    print_success "SwiftLint already installed"
fi

if ! command -v swiftformat &> /dev/null; then
    print_info "Installing SwiftFormat..."
    brew install swiftformat
else
    print_success "SwiftFormat already installed"
fi

# =============================================================================
# [OPTIONAL] Build & Deployment Tools
# =============================================================================
print_info "[OPTIONAL] Build & Deployment Tools"

if ! command -v fastlane &> /dev/null; then
    print_info "Installing Fastlane..."
    brew install fastlane
else
    print_success "Fastlane already installed"
fi

if ! command -v pod &> /dev/null; then
    print_info "Installing CocoaPods (via Homebrew)..."
    brew install cocoapods
else
    print_success "CocoaPods already installed"
fi

# =============================================================================
# [OPTIONAL] Enhanced Developer Experience
# =============================================================================
print_info "[OPTIONAL] Enhanced Developer Experience"

if ! command -v xcbeautify &> /dev/null; then
    print_info "Installing xcbeautify..."
    brew install xcbeautify
else
    print_success "xcbeautify already installed"
fi

if ! command -v xcodes &> /dev/null; then
    print_info "Installing xcodes..."
    brew install xcodesorg/made/xcodes
else
    print_success "xcodes already installed"
fi

# =============================================================================
# Summary
# =============================================================================
print_header "iOS Tools Installation Complete!"

echo "Installed tools:"
echo "  - SwiftLint (code linting)"
echo "  - SwiftFormat (code formatting)"
echo "  - Fastlane (automation)"
echo "  - CocoaPods (dependency management)"
echo "  - xcbeautify (build output formatting)"
echo "  - xcodes (Xcode version management)"
echo ""
echo "Usage:"
echo "  swiftlint              - Lint Swift code"
echo "  swiftformat .          - Format Swift code"
echo "  fastlane [lane]        - Run automation lane"
echo "  pod install            - Install CocoaPods dependencies"
