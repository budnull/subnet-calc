#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "==> Step 1: Building SubnetCalc.app release bundle..."
./build_app.sh

APP_NAME="SubnetCalc.app"
DMG_NAME="SubnetCalc.dmg"
VOLUME_NAME="SubnetCalc"
STAGING_DIR="$DIR/dmg_staging"

echo "==> Step 2: Preparing DMG staging directory..."
rm -rf "$STAGING_DIR" "$DMG_NAME"
mkdir -p "$STAGING_DIR"

echo "==> Step 3: Copying $APP_NAME to staging..."
cp -R "$APP_NAME" "$STAGING_DIR/"

echo "==> Step 4: Creating /Applications symlink..."
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Step 5: Creating compressed DMG image..."
hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_NAME"

echo "==> Step 6: Cleaning up staging..."
rm -rf "$STAGING_DIR"

echo "==> Step 7: Signing DMG..."
codesign --force --sign - "$DMG_NAME"

echo "=========================================================="
echo "  🎉 Successfully created: $DIR/$DMG_NAME"
echo "  Size: $(du -sh "$DMG_NAME" | cut -f1)"
echo "=========================================================="
