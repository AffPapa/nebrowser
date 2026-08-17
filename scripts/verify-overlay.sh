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
grep -Fq -- '-brand-product-name = NeBrowser' "$branding_dir/locales/en-US/brand.ftl"
grep -Fq 'pref("browser.startup.homepage",            "https://affpapa.org/");' \
  "$source_dir/browser/app/profile/firefox.js"
grep -Fq 'pref("datareporting.policy.dataSubmissionEnabled", false);' \
  "$branding_dir/pref/firefox-branding.js"
grep -Fq 'pref("app.normandy.enabled", false);' \
  "$branding_dir/pref/firefox-branding.js"
grep -Fq 'pref("identity.fxaccounts.enabled", false);' \
  "$branding_dir/pref/firefox-branding.js"
grep -Fq 'pref("browser.ml.chat.enabled", false);' \
  "$branding_dir/pref/firefox-branding.js"
grep -Fq 'pref("screenshots.browser.component.enabled", false);' \
  "$branding_dir/pref/firefox-branding.js"
if grep -Eq 'browser/chrome/devtools@JAREXT@|browser/@PREF_DIR@/debugger\.js' \
  "$source_dir/browser/installer/package-manifest.in"; then
  echo "The full DevTools client is still listed for packaging" >&2
  exit 1
fi
if grep -Fq '<key>CFBundleIconName</key>' \
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

if grep -R -n -E 'Nightly|Mozilla Firefox|Firefox Nightly' \
  "$branding_dir/configure.sh" \
  "$branding_dir/locales/en-US" \
  "$branding_dir/pref" \
  "$branding_dir/content/about-wordmark.svg" \
  "$branding_dir/content/firefox-wordmark.svg"; then
  echo "Mozilla channel branding leaked into a user-facing NeBrowser asset" >&2
  exit 1
fi

xcrun assetutil --info "$branding_dir/Assets.car" | grep -Fq '"Name" : "AppIcon"'
echo "NeBrowser overlay verification passed"
