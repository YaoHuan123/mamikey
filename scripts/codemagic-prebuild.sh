#!/usr/bin/env bash
# Codemagic 构建前：同步 Bundle ID、App Group、版本号
set -euo pipefail

ROOT="${CM_BUILD_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
IOS_DIR="$ROOT/ios"
PBXPROJ="$IOS_DIR/MamiKey.xcodeproj/project.pbxproj"
APP_PLIST="$IOS_DIR/MamiKey/Info.plist"
EXT_PLIST="$IOS_DIR/MamiKeyKeyboard/Info.plist"
APP_ENT="$IOS_DIR/MamiKey/MamiKey.entitlements"
EXT_ENT="$IOS_DIR/MamiKeyKeyboard/MamiKeyKeyboard.entitlements"

BUNDLE_ID="${BUNDLE_ID:-io.github.com.YaoHuan123.mamikey}"
BUNDLE_ID_KEYBOARD="${BUNDLE_ID_KEYBOARD:-io.github.YaoHuan123.mamikey.keyboard}"
APP_GROUP="${APP_GROUP:-group.io.github.YaoHuan123.mamikey}"
APP_VERSION="${APP_VERSION:-0.1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-${PROJECT_BUILD_NUMBER:-1}}"

echo "ROOT=$ROOT"
echo "BUNDLE_ID=$BUNDLE_ID"
echo "BUNDLE_ID_KEYBOARD=$BUNDLE_ID_KEYBOARD"
echo "APP_GROUP=$APP_GROUP"
echo "APP_VERSION=$APP_VERSION BUILD_NUMBER=$BUILD_NUMBER"

# Bundle ID（先替换较长的 keyboard，避免子串误伤）
sed -i.bak "s|io.github.YaoHuan123.mamikey.keyboard|${BUNDLE_ID_KEYBOARD}|g" "$PBXPROJ"
sed -i.bak "s|io.github.com.YaoHuan123.mamikey|${BUNDLE_ID}|g" "$PBXPROJ"
rm -f "$PBXPROJ.bak"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$APP_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$APP_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$EXT_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$EXT_PLIST"

for ent in "$APP_ENT" "$EXT_ENT"; do
  /usr/libexec/PlistBuddy -c "Delete :com.apple.security.application-groups" "$ent" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups array" "$ent"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups:0 string $APP_GROUP" "$ent"
done

# 同步 SharedSettings 中的 App Group 常量
SHARED_SETTINGS="$IOS_DIR/MamiKeyShared/Services/SharedSettings.swift"
if [ -f "$SHARED_SETTINGS" ]; then
  sed -i.bak "s|group\\.io\\.github\\.YaoHuan123\\.mamikey|${APP_GROUP}|g" "$SHARED_SETTINGS"
  rm -f "$SHARED_SETTINGS.bak"
fi

echo "Prebuild done."
