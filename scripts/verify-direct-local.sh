#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

release_dir="$project_dir/dist/direct"
archive_path="$release_dir/NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-notarized.zip"
dmg_path="$release_dir/NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-notarized.dmg"

test -s "$archive_path"
test -s "$archive_path.sha256"
test -s "$dmg_path"
test -s "$dmg_path.sha256"

(
  cd "$release_dir"
  shasum -a 256 -c "$(basename "$archive_path.sha256")"
  shasum -a 256 -c "$(basename "$dmg_path.sha256")"
)
unzip -tq "$archive_path"
hdiutil verify "$dmg_path"
xcrun stapler validate "$dmg_path"

temporary_dir="$(mktemp -d /tmp/nebrowser-release-verify.XXXXXX)"
ditto -x -k "$archive_path" "$temporary_dir"
codesign --verify --deep --strict --verbose=2 "$temporary_dir/NeBrowser.app"
xcrun stapler validate "$temporary_dir/NeBrowser.app"
spctl --assess --type execute --verbose=4 "$temporary_dir/NeBrowser.app"
"$script_dir/verify-package.sh" "$temporary_dir/NeBrowser.app"

echo "NeBrowser Direct local verification passed"
