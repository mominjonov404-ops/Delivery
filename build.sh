#!/bin/bash
set -e

echo "================================"
echo "  Yetkazma APK Builder"
echo "================================"

# Check Flutter
if ! command -v flutter &> /dev/null; then
  echo "Flutter topilmadi. O'rnatilmoqda..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 ~/flutter
  export PATH="$PATH:$HOME/flutter/bin"
  echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
fi

# Check Android SDK
if [ -z "$ANDROID_SDK_ROOT" ]; then
  if [ ! -d "$HOME/android-sdk/cmdline-tools/latest" ]; then
    echo "Android SDK o'rnatilmoqda..."
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdtools.zip
    unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools-tmp
    mkdir -p ~/android-sdk/cmdline-tools/latest
    mv /tmp/cmdtools-tmp/cmdline-tools/* ~/android-sdk/cmdline-tools/latest/
    rm -rf /tmp/cmdtools.zip /tmp/cmdtools-tmp
  fi
  export ANDROID_SDK_ROOT=$HOME/android-sdk
  export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"
  echo 'export ANDROID_SDK_ROOT=$HOME/android-sdk' >> ~/.bashrc
  echo 'export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"' >> ~/.bashrc
fi

# Accept licenses + install build tools
yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" --sdk_root=$ANDROID_SDK_ROOT

# Flutter setup
flutter config --android-sdk $ANDROID_SDK_ROOT
flutter pub get

# Get Supabase keys
if [ -z "$SUPABASE_URL" ]; then
  read -p "Supabase URL kiriting: " SUPABASE_URL
fi
if [ -z "$SUPABASE_ANON_KEY" ]; then
  read -p "Supabase Anon Key kiriting: " SUPABASE_ANON_KEY
fi

echo ""
echo "APK build boshlanmoqda..."
flutter build apk --debug \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ -f "$APK_PATH" ]; then
  echo ""
  echo "================================"
  echo "  APK TAYYOR!"
  echo "  $APK_PATH"
  echo "================================"
else
  echo "APK topilmadi. Xato bo'ldi."
  exit 1
fi
