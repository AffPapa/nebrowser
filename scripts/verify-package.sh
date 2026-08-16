#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

source_dir="$project_dir/.cache/firefox-source"
app_path="${1:-$source_dir/obj-nebrowser/dist/nebrowser/NeBrowser.app}"

if [[ ! -d "$app_path" ]]; then
  echo "NeBrowser app not found: $app_path" >&2
  exit 1
fi

info_plist="$app_path/Contents/Info.plist"
bundle_name="$(plutil -extract CFBundleName raw -o - "$info_plist")"
bundle_id="$(plutil -extract CFBundleIdentifier raw -o - "$info_plist")"
bundle_version="$(plutil -extract CFBundleShortVersionString raw -o - "$info_plist")"
executable_name="$(plutil -extract CFBundleExecutable raw -o - "$info_plist")"
executable_path="$app_path/Contents/MacOS/$executable_name"

test "$bundle_name" = "$NEBROWSER_NAME"
test "$bundle_id" = "$NEBROWSER_BUNDLE_ID"
test "$bundle_version" = "$FIREFOX_VERSION"
test -x "$executable_path"
file "$executable_path" | rg -q 'arm64'

test -s "$app_path/Contents/Resources/firefox.icns"
test -s "$app_path/Contents/Resources/Assets.car"
xcrun assetutil --info "$app_path/Contents/Resources/Assets.car" | rg -q '"Name" : "AppIcon"'

if xcrun assetutil --info "$app_path/Contents/Resources/Assets.car" | rg -q 'Nightly|Firefox'; then
  echo "Mozilla artwork name leaked into packaged Assets.car" >&2
  exit 1
fi

browser_archive="$app_path/Contents/Resources/browser/omni.ja"
test -s "$browser_archive"
unzip -p "$browser_archive" defaults/preferences/firefox.js | \
  rg --fixed-strings 'pref("browser.startup.homepage",            "https://affpapa.org/");' > /dev/null
unzip -p "$browser_archive" defaults/preferences/firefox-branding.js | \
  rg --fixed-strings 'pref("datareporting.policy.dataSubmissionEnabled", false);' > /dev/null
unzip -p "$browser_archive" defaults/preferences/firefox-branding.js | \
  rg --fixed-strings 'pref("app.normandy.enabled", false);' > /dev/null

echo "NeBrowser package verification passed: $app_path"
