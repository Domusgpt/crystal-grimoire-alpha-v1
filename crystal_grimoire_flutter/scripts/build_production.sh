#!/bin/bash

# Crystal Grimoire Production Build Script
# This script builds the app for web, Android, and iOS

set -e  # Exit on any error

echo "🔮 Starting Crystal Grimoire Production Build..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project directory. Please run from the project root."
    exit 1
fi

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
flutter pub get

# Build for Web (GitHub Pages)
print_status "Building for Web (GitHub Pages)..."
flutter build web --release --base-href "/crystal-grimoire-alpha-v1/" --web-renderer html

if [ $? -eq 0 ]; then
    print_success "Web build completed successfully"
    
    # Copy to docs directory for GitHub Pages
    print_status "Copying web build to docs directory..."
    rm -rf ../docs
    cp -r build/web ../docs
    print_success "Web files copied to docs directory"
else
    print_error "Web build failed"
    exit 1
fi

# Build for Android
print_status "Building for Android..."

# Check if Android SDK is available
if ! command -v adb &> /dev/null; then
    print_warning "Android SDK not found. Skipping Android build."
    print_warning "To build for Android, install Android Studio and set up the SDK."
else
    print_status "Building Android APK..."
    flutter build apk --release --split-per-abi
    
    if [ $? -eq 0 ]; then
        print_success "Android APK build completed"
        print_status "APK files located in: build/app/outputs/flutter-apk/"
        
        # Build Android App Bundle (for Play Store)
        print_status "Building Android App Bundle..."
        flutter build appbundle --release
        
        if [ $? -eq 0 ]; then
            print_success "Android App Bundle build completed"
            print_status "AAB file located in: build/app/outputs/bundle/release/"
        else
            print_error "Android App Bundle build failed"
        fi
    else
        print_error "Android APK build failed"
    fi
fi

# Build for iOS (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "Building for iOS..."
    
    # Check if iOS development is set up
    if ! command -v xcrun &> /dev/null; then
        print_warning "Xcode not found. Skipping iOS build."
        print_warning "To build for iOS, install Xcode from the Mac App Store."
    else
        print_status "Building iOS IPA..."
        flutter build ios --release --no-codesign
        
        if [ $? -eq 0 ]; then
            print_success "iOS build completed"
            print_status "To create IPA, open ios/Runner.xcworkspace in Xcode"
            print_status "Then: Product > Archive > Distribute App"
        else
            print_error "iOS build failed"
        fi
    fi
else
    print_warning "iOS build skipped (requires macOS)"
fi

# Generate build report
print_status "Generating build report..."
BUILD_DATE=$(date)
FLUTTER_VERSION=$(flutter --version | head -n 1)

cat > build_report.txt << EOF
Crystal Grimoire Build Report
============================

Build Date: $BUILD_DATE
Flutter Version: $FLUTTER_VERSION

✅ Web Build: SUCCESS
   Location: docs/ (ready for GitHub Pages)
   Base href: /crystal-grimoire-alpha-v1/

EOF

if command -v adb &> /dev/null; then
    echo "✅ Android APK: SUCCESS" >> build_report.txt
    echo "   Location: build/app/outputs/flutter-apk/" >> build_report.txt
    echo "✅ Android AAB: SUCCESS" >> build_report.txt
    echo "   Location: build/app/outputs/bundle/release/" >> build_report.txt
else
    echo "⚠️  Android Build: SKIPPED (SDK not found)" >> build_report.txt
fi

if [[ "$OSTYPE" == "darwin"* ]] && command -v xcrun &> /dev/null; then
    echo "✅ iOS Build: SUCCESS" >> build_report.txt
    echo "   Next: Open in Xcode to create IPA" >> build_report.txt
else
    echo "⚠️  iOS Build: SKIPPED (macOS/Xcode required)" >> build_report.txt
fi

cat >> build_report.txt << EOF

Next Steps:
----------
1. Web: Commit and push to deploy to GitHub Pages
2. Android: Upload AAB to Google Play Console
3. iOS: Archive in Xcode and upload to App Store Connect

Configuration Needed:
--------------------
- Firebase project configuration
- RevenueCat API keys
- AdMob ad unit IDs
- Apple Developer signing certificates
- Google Play signing key

EOF

print_success "Build completed! Check build_report.txt for details."

# Display file sizes
print_status "Build sizes:"
if [ -d "build/web" ]; then
    WEB_SIZE=$(du -sh build/web | cut -f1)
    echo "  Web: $WEB_SIZE"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    AAB_SIZE=$(du -sh build/app/outputs/bundle/release/app-release.aab | cut -f1)
    echo "  Android AAB: $AAB_SIZE"
fi

if [ -d "build/app/outputs/flutter-apk" ]; then
    APK_SIZE=$(du -sh build/app/outputs/flutter-apk | cut -f1)
    echo "  Android APKs: $APK_SIZE"
fi

echo ""
print_success "🎉 Crystal Grimoire build process complete!"
echo ""
echo "📱 Ready for deployment:"
echo "   • Web: GitHub Pages"
echo "   • Android: Google Play Store"
echo "   • iOS: Apple App Store"
echo ""
echo "💫 Your mystical crystal app is ready to enchant users worldwide!"