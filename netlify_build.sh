#!/bin/bash

# Exit on error
set -e

echo "🔽 Cloning Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable

echo "📦 Adding Flutter to PATH..."
export PATH="$PATH:$(pwd)/flutter/bin"

echo "🌐 Enabling Flutter Web..."
flutter config --enable-web

echo "📥 Getting Dependencies..."
flutter pub get

echo "🏗️ Building Flutter Web..."
flutter build web

echo "✅ Build Completed!"
