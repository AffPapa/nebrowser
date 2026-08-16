#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

app_path="${1:-$project_dir/.cache/firefox-source/obj-nebrowser/dist/nebrowser/NeBrowser.app}"
release_dir="$project_dir/dist/direct"
archive_path="$release_dir/NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-notarized.zip"
dmg_path="$release_dir/NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-notarized.dmg"

if [[ -z "${NEBROWSER_SIGNING_IDENTITY:-}" ]]; then
  echo "Set NEBROWSER_SIGNING_IDENTITY to the Developer ID Application identity" >&2
  exit 1
fi
if [[ -z "${NEBROWSER_NOTARY_PROFILE:-}" ]]; then
  echo "Set NEBROWSER_NOTARY_PROFILE to an existing notarytool Keychain profile" >&2
  exit 1
fi

"$script_dir/verify-package.sh" "$app_path"
mkdir -p "$release_dir"

codesign --force --deep --strict --options runtime --timestamp \
  --sign "$NEBROWSER_SIGNING_IDENTITY" "$app_path"
codesign --verify --deep --strict --verbose=2 "$app_path"

pre_notary_zip="$release_dir/NeBrowser-pre-notary.zip"
ditto -c -k --keepParent "$app_path" "$pre_notary_zip"
xcrun notarytool submit "$pre_notary_zip" \
  --keychain-profile "$NEBROWSER_NOTARY_PROFILE" --wait
xcrun stapler staple "$app_path"
xcrun stapler validate "$app_path"

ditto -c -k --keepParent "$app_path" "$archive_path"
hdiutil create -volname NeBrowser -srcfolder "$app_path" -ov -format UDZO "$dmg_path"
xcrun notarytool submit "$dmg_path" \
  --keychain-profile "$NEBROWSER_NOTARY_PROFILE" --wait
xcrun stapler staple "$dmg_path"
xcrun stapler validate "$dmg_path"

(
  cd "$release_dir"
  shasum -a 256 "$(basename "$archive_path")" > "$(basename "$archive_path.sha256")"
  shasum -a 256 "$(basename "$dmg_path")" > "$(basename "$dmg_path.sha256")"
)

echo "Direct release artifacts created in $release_dir"
