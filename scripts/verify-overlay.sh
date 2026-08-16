#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

source_dir="${1:-$project_dir/.cache/firefox-source}"
branding_dir="$source_dir/browser/branding/nebrowser"

test "$(tr -d '[:space:]' < "$source_dir/browser/config/version.txt")" = "$FIREFOX_VERSION"
test "$(sed -n 's/^MOZ_APP_DISPLAYNAME=//p' "$branding_dir/configure.sh")" = "$NEBROWSER_NAME"
test "$(sed -n 's/^MOZ_MACBUNDLE_ID=//p' "$branding_dir/configure.sh")" = "$NEBROWSER_MACBUNDLE_ID_SUFFIX"
rg -q --fixed-strings -- '-brand-product-name = NeBrowser' "$branding_dir/locales/en-US/brand.ftl"
rg -q --fixed-strings 'pref("browser.startup.homepage",            "https://affpapa.org/");' \
  "$source_dir/browser/app/profile/firefox.js"
rg -q --fixed-strings 'pref("datareporting.policy.dataSubmissionEnabled", false);' \
  "$branding_dir/pref/firefox-branding.js"
rg -q --fixed-strings 'pref("app.normandy.enabled", false);' \
  "$branding_dir/pref/firefox-branding.js"
if rg -q --fixed-strings '<key>CFBundleIconName</key>' \
  "$source_dir/browser/app/macbuild/Contents/Info.plist.in"; then
  echo "CFBundleIconName still overrides the NeBrowser icns fallback" >&2
  exit 1
fi

for asset in firefox.icns document.icns Assets.car default16.png default32.png default128.png; do
  test -s "$branding_dir/$asset"
done
for asset in about-logo.svg about-wordmark.svg firefox-wordmark.svg about-logo.png about-logo@2x.png; do
  test -s "$branding_dir/content/$asset"
done

if rg -n 'Nightly|Mozilla Firefox|Firefox Nightly' \
  "$branding_dir/configure.sh" \
  "$branding_dir/locales/en-US" \
  "$branding_dir/pref" \
  "$branding_dir/content/about-wordmark.svg" \
  "$branding_dir/content/firefox-wordmark.svg"; then
  echo "Mozilla channel branding leaked into a user-facing NeBrowser asset" >&2
  exit 1
fi

xcrun assetutil --info "$branding_dir/Assets.car" | rg -q '"Name" : "AppIcon"'
echo "NeBrowser overlay verification passed"
