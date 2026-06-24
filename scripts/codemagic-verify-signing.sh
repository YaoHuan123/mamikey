#!/usr/bin/env bash
# 校验 Codemagic 上的描述文件是否包含 App Groups，且 Bundle ID 正确
set -euo pipefail

BUNDLE_ID="${BUNDLE_ID:-io.github.YaoHuan123.mamikey}"
BUNDLE_ID_KEYBOARD="${BUNDLE_ID_KEYBOARD:-io.github.YaoHuan123.mamikey.keyboard}"
APP_GROUP="${APP_GROUP:-group.io.github.YaoHuan123.mamikey}"
PROFILE_DIR="${HOME}/Library/MobileDevice/Provisioning Profiles"

echo "=== Verify provisioning profiles ==="
echo "Expect main: $BUNDLE_ID"
echo "Expect keyboard: $BUNDLE_ID_KEYBOARD"
echo "Expect App Group: $APP_GROUP"

if [ ! -d "$PROFILE_DIR" ]; then
  echo "ERROR: No provisioning profiles directory. Did xcode-project use-profiles run?" >&2
  exit 1
fi

found_main=0
found_keyboard=0

for profile in "$PROFILE_DIR"/*.mobileprovision; do
  [ -f "$profile" ] || continue
  plist="/tmp/cm_profile_$$.plist"
  security cms -D -i "$profile" > "$plist" 2>/dev/null || continue

  app_id=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:application-identifier" "$plist" 2>/dev/null || echo "")
  name=$(/usr/libexec/PlistBuddy -c "Print :Name" "$plist" 2>/dev/null || echo "unknown")
  has_groups=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.security.application-groups" "$plist" 2>/dev/null || echo "")

  echo ""
  echo "Profile: $name"
  echo "  application-identifier: $app_id"

  if echo "$app_id" | grep -q "$BUNDLE_ID$"; then
    found_main=1
    if [ -z "$has_groups" ] || [ "$has_groups" = "Print: Entry, Does Not Exist" ]; then
      echo "  ERROR: Main app profile missing App Groups entitlement!" >&2
      echo "  → Apple Developer 里给 App ID 开启 App Groups 后，必须重新生成并上传 mamikey-appstore" >&2
      exit 1
    fi
    echo "  App Groups: $has_groups"
    if ! echo "$has_groups" | grep -q "$APP_GROUP"; then
      echo "  ERROR: App Group mismatch. Expected $APP_GROUP" >&2
      exit 1
    fi
  fi

  if echo "$app_id" | grep -q "$BUNDLE_ID_KEYBOARD"; then
    found_keyboard=1
    if [ -z "$has_groups" ] || [ "$has_groups" = "Print: Entry, Does Not Exist" ]; then
      echo "  ERROR: Keyboard profile missing App Groups entitlement!" >&2
      exit 1
    fi
    echo "  App Groups: $has_groups"
  fi

  rm -f "$plist"
done

if [ "$found_main" -eq 0 ]; then
  echo ""
  echo "ERROR: No profile found for $BUNDLE_ID (reference: mamikey-appstore)" >&2
  exit 1
fi

if [ "$found_keyboard" -eq 0 ]; then
  echo ""
  echo "ERROR: No profile found for $BUNDLE_ID_KEYBOARD (reference: mamikey-keyboard-appstore)" >&2
  echo "→ 键盘扩展需要单独上传第二个描述文件到 Codemagic" >&2
  exit 1
fi

echo ""
echo "Profile verification passed."
