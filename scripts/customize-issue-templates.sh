#!/bin/bash
# =============================================================================
# Issue Template Customization Script
# Tailors GitHub issue templates to your project's needs
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect OS for cross-platform compatibility
detect_os() {
    case "$(uname -s)" in
        Darwin*)  OS="macos" ;;
        Linux*)   OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
        *)        OS="unknown" ;;
    esac
}

# Cross-platform sed -i (in-place edit)
sed_inplace() {
    if [ "$OS" = "macos" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

detect_os

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

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if issue templates exist
TEMPLATE_DIR=".github/ISSUE_TEMPLATE"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}Error: Issue templates not found at $TEMPLATE_DIR${NC}"
    echo "Run this script from the project root directory."
    exit 1
fi

print_header "📝 Issue Template Customization"

echo "This script helps you customize the GitHub issue templates for your project."
echo "Templates are located in: $TEMPLATE_DIR/"
echo ""

# =============================================================================
# Backend API Option
# =============================================================================

echo -e "${YELLOW}Question 1 of 3:${NC}"
read -p "Does your project include a backend API? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Removing 'Backend API' option from templates..."

    for template in "$TEMPLATE_DIR"/*.md; do
        if [ -f "$template" ]; then
            sed_inplace '/- \[ \] Backend API/d' "$template"
        fi
    done

    print_success "Backend API option removed"
else
    print_info "Keeping Backend API option"
fi

# =============================================================================
# Additional Platform Options
# =============================================================================

echo ""
echo -e "${YELLOW}Question 2 of 3:${NC}"
read -p "Add 'Web App' as a platform option? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Adding 'Web App' option to templates..."

    for template in "$TEMPLATE_DIR"/*.md; do
        if [ -f "$template" ]; then
            # Add Web App after Android App line (using literal newline for macOS compatibility)
            sed_inplace 's/- \[ \] Android App/- [ ] Android App\
- [ ] Web App/' "$template"
        fi
    done

    print_success "Web App option added"
fi

# =============================================================================
# Default Labels
# =============================================================================

echo ""
echo -e "${YELLOW}Question 3 of 3:${NC}"
echo "Would you like to add platform-specific labels to bug reports?"
echo "  This adds 'ios' or 'android' labels that reporters can select."
read -p "Add platform labels? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Updating bug report labels..."

    BUG_TEMPLATE="$TEMPLATE_DIR/bug_report.md"
    if [ -f "$BUG_TEMPLATE" ]; then
        sed_inplace "s/labels: bug/labels: bug, needs-triage/" "$BUG_TEMPLATE"
        print_success "Bug report labels updated"
    fi
fi

# =============================================================================
# Summary
# =============================================================================

print_header "✅ Customization Complete"

echo "Your issue templates have been customized!"
echo ""
echo "Templates modified:"
for template in "$TEMPLATE_DIR"/*.md; do
    if [ -f "$template" ]; then
        echo "  - $(basename "$template")"
    fi
done
echo ""
echo -e "${BLUE}Tip:${NC} You can further edit these templates directly:"
echo "  $TEMPLATE_DIR/bug_report.md"
echo "  $TEMPLATE_DIR/feature_request.md"
echo "  $TEMPLATE_DIR/task.md"
echo "  $TEMPLATE_DIR/config.yml"
echo ""
