#!/bin/bash
# =============================================================================
# Mobile App Template Setup Script
# Customizes the template for your new project
# Supports: macOS, Linux, Windows (Git Bash/WSL)
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

# Convert PROJECT_NAME to PascalCase for Android theme (handles kebab-case, snake_case, etc.)
THEME_NAME=$(echo "$PROJECT_NAME" | sed -E 's/(^|[-_ ])([a-zA-Z])/\U\2/g' | sed 's/[^a-zA-Z0-9]//g')

# Author name
read -p "Author name (for file headers): " AUTHOR_NAME
AUTHOR_NAME=${AUTHOR_NAME:-"Developer"}

# Current date
DATE=$(date +"%Y-%m-%d")

echo ""
print_info "Configuration:"
echo "  Project Name: $PROJECT_NAME"
echo "  Package Name: com.$PACKAGE_NAME"
echo "  Theme Name: ${THEME_NAME}Theme"
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

# Find and replace in all text files (cross-platform)
while IFS= read -r -d '' file; do
    sed_inplace \
        -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PACKAGE_NAME}}/$PACKAGE_NAME/g" \
        -e "s/{{THEME_NAME}}/$THEME_NAME/g" \
        -e "s/{{AUTHOR_NAME}}/$AUTHOR_NAME/g" \
        -e "s/{{DATE}}/$DATE/g" \
        "$file"
done < <(find . -type f \( -name "*.swift" -o -name "*.kt" -o -name "*.xml" -o -name "*.gradle.kts" -o -name "*.toml" -o -name "*.yml" -o -name "*.md" -o -name "*.sh" -o -name ".swiftformat" -o -name ".swiftlint.yml" -o -name ".cursorrules" -o -name "*.json" \) -print0)

print_success "Placeholders replaced"

# Rename iOS directories and files
print_info "Renaming iOS project files..."

if [ -d "ios-app/{{PROJECT_NAME}}" ]; then
    mv "ios-app/{{PROJECT_NAME}}" "ios-app/$PROJECT_NAME"
    print_success "iOS app directory renamed"
fi

if [ -d "ios-app/{{PROJECT_NAME}}Tests" ]; then
    mv "ios-app/{{PROJECT_NAME}}Tests" "ios-app/${PROJECT_NAME}Tests"
    print_success "iOS tests directory renamed"
fi

# Rename Android package directories
print_info "Renaming Android package directories..."

ANDROID_SRC="android-app/app/src/main/java/com"
if [ -d "$ANDROID_SRC/{{PACKAGE_NAME}}" ]; then
    mv "$ANDROID_SRC/{{PACKAGE_NAME}}" "$ANDROID_SRC/$PACKAGE_NAME"
    print_success "Android package directory renamed"
fi

ANDROID_TEST="android-app/app/src/test/java/com"
if [ -d "$ANDROID_TEST/{{PACKAGE_NAME}}" ]; then
    mv "$ANDROID_TEST/{{PACKAGE_NAME}}" "$ANDROID_TEST/$PACKAGE_NAME"
    print_success "Android test package directory renamed"
fi

# Create iOS MVVM directory structure
print_info "Creating iOS MVVM directory structure..."
IOS_SRC="ios-app/$PROJECT_NAME"
mkdir -p "$IOS_SRC/ViewModels"
mkdir -p "$IOS_SRC/Models"
mkdir -p "$IOS_SRC/Services"
mkdir -p "$IOS_SRC/Utilities"
print_success "iOS MVVM directories created"

# Create Android architecture directories
print_info "Creating Android architecture directories..."
ANDROID_PKG="android-app/app/src/main/java/com/$PACKAGE_NAME"
mkdir -p "$ANDROID_PKG/data/repository"
mkdir -p "$ANDROID_PKG/data/models"
mkdir -p "$ANDROID_PKG/domain"
print_success "Android architecture directories created"

# Generate iOS Xcode project
print_info "Generating iOS Xcode project..."
if [ "$OS" = "macos" ] && command -v xcodebuild &> /dev/null; then
    cd ios-app

    # Create project.pbxproj structure
    mkdir -p "$PROJECT_NAME.xcodeproj"

    # Generate a basic Xcode project file
    cat > "$PROJECT_NAME.xcodeproj/project.pbxproj" << 'PBXPROJ_EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		APP_SWIFT /* {{PROJECT_NAME}}App.swift in Sources */ = {isa = PBXBuildFile; fileRef = APP_SWIFT_REF /* {{PROJECT_NAME}}App.swift */; };
		CONTENT_VIEW /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = CONTENT_VIEW_REF /* ContentView.swift */; };
		ASSETS /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = ASSETS_REF /* Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		PRODUCT_REF /* {{PROJECT_NAME}}.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "{{PROJECT_NAME}}.app"; sourceTree = BUILT_PRODUCTS_DIR; };
		APP_SWIFT_REF /* {{PROJECT_NAME}}App.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{{PROJECT_NAME}}App.swift"; sourceTree = "<group>"; };
		CONTENT_VIEW_REF /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		ASSETS_REF /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		FRAMEWORKS_PHASE /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		MAIN_GROUP = {
			isa = PBXGroup;
			children = (
				SOURCE_GROUP /* {{PROJECT_NAME}} */,
				PRODUCTS_GROUP /* Products */,
			);
			sourceTree = "<group>";
		};
		PRODUCTS_GROUP /* Products */ = {
			isa = PBXGroup;
			children = (
				PRODUCT_REF /* {{PROJECT_NAME}}.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		SOURCE_GROUP /* {{PROJECT_NAME}} */ = {
			isa = PBXGroup;
			children = (
				APP_GROUP /* App */,
				VIEWS_GROUP /* Views */,
				VIEWMODELS_GROUP /* ViewModels */,
				MODELS_GROUP /* Models */,
				SERVICES_GROUP /* Services */,
				UTILITIES_GROUP /* Utilities */,
				ASSETS_REF /* Assets.xcassets */,
			);
			path = "{{PROJECT_NAME}}";
			sourceTree = "<group>";
		};
		APP_GROUP /* App */ = {
			isa = PBXGroup;
			children = (
				APP_SWIFT_REF /* {{PROJECT_NAME}}App.swift */,
			);
			path = App;
			sourceTree = "<group>";
		};
		VIEWS_GROUP /* Views */ = {
			isa = PBXGroup;
			children = (
				CONTENT_VIEW_REF /* ContentView.swift */,
			);
			path = Views;
			sourceTree = "<group>";
		};
		VIEWMODELS_GROUP /* ViewModels */ = {
			isa = PBXGroup;
			children = (
			);
			path = ViewModels;
			sourceTree = "<group>";
		};
		MODELS_GROUP /* Models */ = {
			isa = PBXGroup;
			children = (
			);
			path = Models;
			sourceTree = "<group>";
		};
		SERVICES_GROUP /* Services */ = {
			isa = PBXGroup;
			children = (
			);
			path = Services;
			sourceTree = "<group>";
		};
		UTILITIES_GROUP /* Utilities */ = {
			isa = PBXGroup;
			children = (
			);
			path = Utilities;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		NATIVE_TARGET /* {{PROJECT_NAME}} */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = BUILD_CONFIG_LIST /* Build configuration list for PBXNativeTarget "{{PROJECT_NAME}}" */;
			buildPhases = (
				SOURCES_PHASE /* Sources */,
				FRAMEWORKS_PHASE /* Frameworks */,
				RESOURCES_PHASE /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = "{{PROJECT_NAME}}";
			productName = "{{PROJECT_NAME}}";
			productReference = PRODUCT_REF /* {{PROJECT_NAME}}.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		PROJECT_ROOT /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					NATIVE_TARGET = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = PROJECT_CONFIG_LIST /* Build configuration list for PBXProject "{{PROJECT_NAME}}" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = MAIN_GROUP;
			productRefGroup = PRODUCTS_GROUP /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				NATIVE_TARGET /* {{PROJECT_NAME}} */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		RESOURCES_PHASE /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				ASSETS /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		SOURCES_PHASE /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				CONTENT_VIEW /* ContentView.swift in Sources */,
				APP_SWIFT /* {{PROJECT_NAME}}App.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		DEBUG_PROJECT /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		RELEASE_PROJECT /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		DEBUG_TARGET /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.{{PACKAGE_NAME}}.app";
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		RELEASE_TARGET /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.{{PACKAGE_NAME}}.app";
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		PROJECT_CONFIG_LIST /* Build configuration list for PBXProject "{{PROJECT_NAME}}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				DEBUG_PROJECT /* Debug */,
				RELEASE_PROJECT /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		BUILD_CONFIG_LIST /* Build configuration list for PBXNativeTarget "{{PROJECT_NAME}}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				DEBUG_TARGET /* Debug */,
				RELEASE_TARGET /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = PROJECT_ROOT /* Project object */;
}
PBXPROJ_EOF

    # Replace placeholders in the generated project file
    sed_inplace \
        -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PACKAGE_NAME}}/$PACKAGE_NAME/g" \
        "$PROJECT_NAME.xcodeproj/project.pbxproj"

    # Create Assets.xcassets
    mkdir -p "$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset"
    mkdir -p "$PROJECT_NAME/Assets.xcassets/AccentColor.colorset"

    cat > "$PROJECT_NAME/Assets.xcassets/Contents.json" << 'ASSETS_EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
ASSETS_EOF

    cat > "$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'APPICON_EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
APPICON_EOF

    cat > "$PROJECT_NAME/Assets.xcassets/AccentColor.colorset/Contents.json" << 'ACCENT_EOF'
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
ACCENT_EOF

    cd ..
    print_success "iOS Xcode project generated"
else
    print_info "Skipping Xcode project generation (requires macOS with Xcode)"
    echo -e "  ${YELLOW}To create the iOS project manually:${NC}"
    echo "  1. Open Xcode → File → New → Project"
    echo "  2. Select iOS → App → SwiftUI"
    echo "  3. Name it '$PROJECT_NAME' and save in ios-app/"
    echo "  4. Move source files from ios-app/$PROJECT_NAME/ into the project"
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
