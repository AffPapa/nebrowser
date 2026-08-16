#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

app_path="${1:-$project_dir/.cache/firefox-source/obj-nebrowser/dist/nebrowser/NeBrowser.app}"
screenshot_path="${2:-$project_dir/build/smoke/affpapa-home.png}"
profile_dir="$(mktemp -d /tmp/nebrowser-smoke-profile.XXXXXX)"

"$script_dir/verify-package.sh" "$app_path"
mkdir -p "$(dirname "$screenshot_path")"

executable_name="$(plutil -extract CFBundleExecutable raw -o - "$app_path/Contents/Info.plist")"
executable_path="$app_path/Contents/MacOS/$executable_name"
export MOZ_HEADLESS=1

"$executable_path" --version
"$executable_path" \
  --headless \
  --no-remote \
  --profile "$profile_dir" \
  --window-size 1440,1000 \
  --screenshot "$screenshot_path" \
  "$NEBROWSER_HOME_URL"

file "$screenshot_path" | rg -q 'PNG image data, 1440 x 1000'
echo "NeBrowser smoke test passed: $screenshot_path"
echo "Temporary profile: $profile_dir"
