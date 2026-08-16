#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

release_dir="$project_dir/dist/local"
archive_base="NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-local-adhoc"
dmg_base="NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-local-unsigned"
archive_path="$release_dir/$archive_base.zip"
dmg_path="$release_dir/$dmg_base.dmg"

test -s "$archive_path"
test -s "$archive_path.sha256"
test -s "$dmg_path"
test -s "$dmg_path.sha256"
shasum -a 256 -c "$archive_path.sha256"
shasum -a 256 -c "$dmg_path.sha256"
unzip -tq "$archive_path"
hdiutil verify "$dmg_path"

temporary_dir="$(mktemp -d /tmp/nebrowser-local-verify.XXXXXX)"
ditto -x -k "$archive_path" "$temporary_dir"
codesign --verify --deep --strict --verbose=2 "$temporary_dir/NeBrowser.app"
"$script_dir/verify-package.sh" "$temporary_dir/NeBrowser.app"

echo "NeBrowser local QA verification passed"
echo "Temporary verification copy: $temporary_dir/NeBrowser.app"
