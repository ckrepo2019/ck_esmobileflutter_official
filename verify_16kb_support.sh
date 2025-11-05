#!/bin/bash

# Script to verify 16 KB page size support configuration
echo "Checking 16 KB page size support configuration..."

# Check if necessary files exist
if [ ! -f "android/app/build.gradle.kts" ]; then
    echo "❌ build.gradle.kts not found"
    exit 1
fi

if [ ! -f "android/app/src/main/cpp/CMakeLists.txt" ]; then
    echo "❌ CMakeLists.txt not found"
    exit 1
fi

if [ ! -f "android/app/src/main/cpp/native-lib.cpp" ]; then
    echo "❌ native-lib.cpp not found"
    exit 1
fi

# Check build.gradle.kts for required configurations
echo "Checking build.gradle.kts configuration..."
if grep -q "abiFilters" android/app/build.gradle.kts; then
    echo "✅ NDK ABI filters configured"
else
    echo "❌ NDK ABI filters not configured"
fi

if grep -q "prefab = true" android/app/build.gradle.kts; then
    echo "✅ Prefab support enabled"
else
    echo "❌ Prefab support not enabled"
fi

if grep -q "cmake" android/app/build.gradle.kts; then
    echo "✅ CMake configuration found"
else
    echo "❌ CMake configuration not found"
fi

# Check AndroidManifest.xml for required configurations
if grep -q "largeHeap" android/app/src/main/AndroidManifest.xml; then
    echo "✅ Large heap enabled"
else
    echo "❌ Large heap not enabled"
fi

if grep -q "vmSafeMode" android/app/src/main/AndroidManifest.xml; then
    echo "✅ VM safe mode enabled"
else
    echo "❌ VM safe mode not enabled"
fi

echo "Configuration check complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter clean' to clean the build cache"
echo "2. Run 'flutter pub get' to get dependencies"
echo "3. Run 'flutter build appbundle --release' to build the app"
echo "4. Test the app on a device with Android 15+ to verify 16 KB page support"
