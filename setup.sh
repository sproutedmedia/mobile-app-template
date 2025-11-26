#!/bin/bash
# =============================================================================
# Mobile App Template Setup Script
# Customizes the template for your new project
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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header "🚀 Mobile App Template Setup"

# =============================================================================
# Gather Project Information
# =============================================================================

echo "Let's set up your new mobile app project!"
echo ""

# Project name
read -p "Project name (e.g., MyAwesomeApp): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Project name is required${NC}"
    exit 1
fi

# Android package name
DEFAULT_PACKAGE=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
read -p "Android package name (default: $DEFAULT_PACKAGE): " PACKAGE_NAME
PACKAGE_NAME=${PACKAGE_NAME:-$DEFAULT_PACKAGE}

# Author name
read -p "Author name (for file headers): " AUTHOR_NAME
AUTHOR_NAME=${AUTHOR_NAME:-"Developer"}

# Current date
DATE=$(date +"%Y-%m-%d")

echo ""
print_info "Configuration:"
echo "  Project Name: $PROJECT_NAME"
echo "  Package Name: com.$PACKAGE_NAME"
echo "  Author: $AUTHOR_NAME"
echo "  Date: $DATE"
echo ""

read -p "Continue with these settings? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# =============================================================================
# Perform Replacements
# =============================================================================

print_header "Setting up project..."

# Replace placeholders in all files
print_info "Replacing placeholders..."

# Find and replace in all text files
find . -type f \( -name "*.swift" -o -name "*.kt" -o -name "*.xml" -o -name "*.gradle.kts" -o -name "*.toml" -o -name "*.yml" -o -name "*.md" -o -name "*.sh" -o -name ".swiftformat" -o -name ".swiftlint.yml" \) -exec sed -i '' \
    -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{PACKAGE_NAME}}/$PACKAGE_NAME/g" \
    -e "s/{{AUTHOR_NAME}}/$AUTHOR_NAME/g" \
    -e "s/{{DATE}}/$DATE/g" \
    {} \;

print_success "Placeholders replaced"

# Rename iOS directories and files
print_info "Renaming iOS project files..."

if [ -d "ios-app/{{PROJECT_NAME}}" ]; then
    mv "ios-app/{{PROJECT_NAME}}" "ios-app/$PROJECT_NAME"
    print_success "iOS app directory renamed"
fi

# Rename Android package directories
print_info "Renaming Android package directories..."

ANDROID_SRC="android-app/app/src/main/java/com"
if [ -d "$ANDROID_SRC/{{PACKAGE_NAME}}" ]; then
    mv "$ANDROID_SRC/{{PACKAGE_NAME}}" "$ANDROID_SRC/$PACKAGE_NAME"
    print_success "Android package directory renamed"
fi

# Make scripts executable
print_info "Making scripts executable..."
chmod +x scripts/*.sh 2>/dev/null || true
print_success "Scripts are executable"

# =============================================================================
# Clean Up
# =============================================================================

print_info "Cleaning up..."

# Remove this setup script (optional - user can delete manually)
# rm -f setup.sh

# Remove template-specific files
rm -f TEMPLATE-README.md 2>/dev/null || true

print_success "Cleanup complete"

# =============================================================================
# Initialize Git
# =============================================================================

print_header "Git Setup"

if [ ! -d ".git" ]; then
    read -p "Initialize git repository? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        git add .
        git commit -m "Initial commit from mobile-app-template"
        print_success "Git repository initialized"
    fi
else
    print_info "Git repository already exists"
fi

# =============================================================================
# Summary
# =============================================================================

print_header "🎉 Setup Complete!"

cat << EOF

Your project "$PROJECT_NAME" is ready!

📁 Project Structure:
  ios-app/          - iOS app (SwiftUI)
  android-app/      - Android app (Jetpack Compose)
  scripts/          - Development scripts
  docs/             - Documentation

🔧 Next Steps:

  1. Verify your environment:
     ./scripts/verify-dev-environment.sh

  2. Install development tools (if needed):
     ./scripts/install-ios-tools.sh
     ./scripts/install-android-tools.sh

  3. Open in your IDE:
     iOS:     open ios-app/$PROJECT_NAME.xcodeproj
     Android: Open android-app/ in Android Studio

  4. Run linters:
     iOS:     cd ios-app && swiftlint
     Android: cd android-app && ./gradlew ktlintCheck detekt

📚 Documentation:
  - README.md           - Project overview
  - docs/SETUP.md       - Detailed setup guide
  - docs/DEVELOPMENT.md - Development workflow

Happy coding! 🚀

EOF
