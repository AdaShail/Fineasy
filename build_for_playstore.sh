#!/bin/bash

echo "🏗️  Building for Play Store..."

# Check if keystore exists
if [ ! -f "android/keystore/release-keystore.jks" ]; then
    echo "Keystore not found!"
    echo "Creating keystore directory..."
    mkdir -p android/keystore
    
    echo ""
    echo "Please run this command to generate a keystore:"
    echo ""
    echo "keytool -genkey -v -keystore android/keystore/release-keystore.jks \\"
    echo "  -keyalg RSA -keysize 2048 -validity 10000 \\"
    echo "  -alias release-key"
    echo ""
    echo "IMPORTANT: Save the passwords securely!"
    exit 1
fi

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    echo "key.properties not found!"
    echo ""
    echo "Please create android/key.properties with:"
    echo ""
    echo "storePassword=your_keystore_password"
    echo "keyPassword=your_key_password"
    echo "keyAlias=release-key"
    echo "storeFile=../keystore/release-keystore.jks"
    echo ""
    exit 1
fi

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build AAB
echo "Building App Bundle (AAB)..."
flutter build appbundle --release

# Check if build succeeded
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo ""
    echo "Build successful!"
    echo ""
    echo "AAB location: build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "AAB size:"
    ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print $5}'
    echo ""
    echo "Next steps:"
    echo "1. Go to https://play.google.com/console"
    echo "2. Create or select your app"
    echo "3. Go to Release → Production"
    echo "4. Upload app-release.aab"
    echo "5. Complete store listing"
    echo "6. Submit for review"
else
    echo ""
    echo "Build failed!"
    echo "Check the error messages above."
    exit 1
fi
