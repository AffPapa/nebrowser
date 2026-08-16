#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

source_dir="${1:-$project_dir/.cache/firefox-source}"
branding_dir="$source_dir/browser/branding/nebrowser"
overlay_dir="$project_dir/overlay/browser/branding/nebrowser"
generated_dir="$project_dir/build/brand-generated"

if [[ ! -f "$source_dir/browser/config/version.txt" ]]; then
  echo "Firefox source is missing; run scripts/bootstrap-firefox.sh" >&2
  exit 1
fi

actual_version="$(tr -d '[:space:]' < "$source_dir/browser/config/version.txt")"
if [[ "$actual_version" != "$FIREFOX_VERSION" ]]; then
  echo "Overlay is pinned to Firefox $FIREFOX_VERSION, found $actual_version" >&2
  exit 1
fi

if [[ ! -d "$branding_dir" ]]; then
  cp -R "$source_dir/browser/branding/unofficial" "$branding_dir"
fi

cp -R "$overlay_dir/." "$branding_dir/"
"$script_dir/generate-brand-assets.sh"

cp "$generated_dir/firefox.icns" "$branding_dir/firefox.icns"
cp "$generated_dir/document.icns" "$branding_dir/document.icns"
cp "$generated_dir/Assets.car" "$branding_dir/Assets.car"
for pixels in 16 22 24 32 48 64 128 256; do
  cp "$generated_dir/default${pixels}.png" "$branding_dir/default${pixels}.png"
done
for asset in about.png about-logo.png about-logo@2x.png about-logo-private.png about-logo-private@2x.png; do
  cp "$generated_dir/$asset" "$branding_dir/content/$asset"
done

python3 "$script_dir/patch-firefox.py" "$source_dir"
cp "$project_dir/mozconfig.nebrowser" "$source_dir/mozconfig"

echo "NeBrowser overlay applied: $source_dir"

