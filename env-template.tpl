# Environment Template - Rename to .env.tpl after setup
# This file contains 1Password references and is safe to commit
#
# Usage:
#   1. Rename this file to .env.tpl
#   2. Update the 1Password references to match your vault items
#   3. Run commands with: op run --env-file=.env.tpl -- your-command

# =============================================================================
# API Keys (update with your 1Password item paths)
# =============================================================================

# Firebase (optional - uncomment if using)
# FIREBASE_API_KEY=op://Development/Firebase-{{PROJECT_NAME}}/api-key

# Analytics (optional - uncomment if using)
# AMPLITUDE_API_KEY=op://Development/Amplitude-{{PROJECT_NAME}}/api-key

# Backend API (optional - uncomment if using)
# API_BASE_URL=https://api.yourservice.com
# API_KEY=op://Development/{{PROJECT_NAME}}-API/api-key

# =============================================================================
# App Store / Play Store (for CI/CD - optional)
# =============================================================================

# iOS - App Store Connect
# ASC_KEY_ID=op://Development/AppStoreConnect/KEY_ID
# ASC_ISSUER_ID=op://Development/AppStoreConnect/ISSUER_ID

# =============================================================================
# Development Settings
# =============================================================================

DEBUG=false
ENVIRONMENT=development

