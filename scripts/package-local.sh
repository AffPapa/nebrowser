#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

app_path="${1:-$project_dir/.cache/firefox-source/obj-nebrowser/dist/nebrowser/NeBrowser.app}"
release_dir="$project_dir/dist/local"
archive_base="NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-local-adhoc"
dmg_base="NeBrowser-${NEBROWSER_VERSION}-firefox-${FIREFOX_VERSION}-macos-arm64-local-unsigned"
archive_path="$release_dir/$archive_base.zip"
dmg_path="$release_dir/$dmg_base.dmg"
mozilla_dmg="$project_dir/.cache/firefox-source/obj-nebrowser/dist/nebrowser-${FIREFOX_VERSION}.en-US.mac.dmg"

"$script_dir/verify-package.sh" "$app_path"
"$script_dir/verify-config.sh"
mkdir -p "$release_dir"

# Local QA artifacts are sealed ad hoc. This is deliberately not a public
# Developer ID signature and cannot satisfy the Direct Distribution gate.
codesign --force --deep --sign - "$app_path"
codesign --verify --deep --strict --verbose=2 "$app_path"

ditto -c -k --keepParent "$app_path" "$archive_path"
test -s "$mozilla_dmg"
cp "$mozilla_dmg" "$dmg_path"
shasum -a 256 "$archive_path" > "$archive_path.sha256"
shasum -a 256 "$dmg_path" > "$dmg_path.sha256"

"$script_dir/verify-local.sh"
echo "NeBrowser local QA artifacts created in $release_dir"
