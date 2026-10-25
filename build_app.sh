#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "==> Building Release binary..."
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -c release

APP_NAME="SubnetCalc.app"
APP_DIR="$DIR/$APP_NAME"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "==> Creating $APP_NAME structure..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

echo "==> Copying binary..."
cp ".build/out/Products/Release/SubnetCalc" "$MACOS/SubnetCalc"

echo "==> Copying resources..."
if [ -d ".build/out/Products/Release/SubnetCalc_SubnetCalc.bundle" ]; then
    cp -R ".build/out/Products/Release/SubnetCalc_SubnetCalc.bundle" "$RESOURCES/"
    cp -R ".build/out/Products/Release/SubnetCalc_SubnetCalc.bundle" "$MACOS/"
fi

# Copy .lproj localization folders directly into App Resources for macOS system localization
if [ -d "Sources/SubnetCalc/Resources/en.lproj" ]; then
    cp -R "Sources/SubnetCalc/Resources/en.lproj" "$RESOURCES/"
fi
if [ -d "Sources/SubnetCalc/Resources/it.lproj" ]; then
    cp -R "Sources/SubnetCalc/Resources/it.lproj" "$RESOURCES/"
fi

if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "$RESOURCES/AppIcon.icns"
fi

echo "==> Creating Info.plist..."
cat << 'EOF' > "$CONTENTS/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>it</string>
    <key>CFBundleLocalizations</key>
    <array>
        <string>it</string>
        <string>en</string>
    </array>
    <key>CFBundleDisplayName</key>
    <string>SubnetCalc</string>
    <key>CFBundleExecutable</key>
    <string>SubnetCalc</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.budnull.SubnetCalc</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>SubnetCalc</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "APPL????" > "$CONTENTS/PkgInfo"

echo "==> Ad-hoc signing SubnetCalc.app..."
codesign --force --deep --sign - "$APP_DIR"

echo "==> Successfully created $APP_DIR"
