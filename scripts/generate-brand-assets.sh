#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
master="$project_dir/assets/brand/nebrowser-icon-master.png"
output_dir="$project_dir/build/brand-generated"
iconset_dir="$output_dir/firefox.iconset"
catalog_dir="$output_dir/NeBrowser.xcassets/AppIcon.appiconset"
actool_output="$output_dir/actool"

mkdir -p "$iconset_dir" "$catalog_dir" "$actool_output"
cp "$project_dir/assets/macos/NeBrowser.xcassets/AppIcon.appiconset/Contents.json" "$catalog_dir/Contents.json"

make_png() {
  local pixels="$1"
  local filename="$2"
  sips --resampleHeightWidth "$pixels" "$pixels" "$master" --out "$iconset_dir/$filename" >/dev/null
  cp "$iconset_dir/$filename" "$catalog_dir/$filename"
}

make_png 16 icon_16x16.png
make_png 32 icon_16x16@2x.png
make_png 32 icon_32x32.png
make_png 64 icon_32x32@2x.png
make_png 128 icon_128x128.png
make_png 256 icon_128x128@2x.png
make_png 256 icon_256x256.png
make_png 512 icon_256x256@2x.png
make_png 512 icon_512x512.png
make_png 1024 icon_512x512@2x.png

for pixels in 16 22 24 32 48 64 128 256; do
  sips --resampleHeightWidth "$pixels" "$pixels" "$master" \
    --out "$output_dir/default${pixels}.png" >/dev/null
done

sips --resampleHeightWidth 192 192 "$master" --out "$output_dir/about-logo.png" >/dev/null
sips --resampleHeightWidth 384 384 "$master" --out "$output_dir/about-logo@2x.png" >/dev/null
cp "$output_dir/about-logo.png" "$output_dir/about-logo-private.png"
cp "$output_dir/about-logo@2x.png" "$output_dir/about-logo-private@2x.png"
sips --resampleHeightWidth 220 220 "$master" --out "$output_dir/about-square.png" >/dev/null
sips --padToHeightWidth 236 300 --padColor 070a10 "$output_dir/about-square.png" \
  --out "$output_dir/about.png" >/dev/null

xcrun actool \
  --compile "$actool_output" \
  --platform macosx \
  --target-device mac \
  --minimum-deployment-target 15.0 \
  --app-icon AppIcon \
  --output-partial-info-plist "$output_dir/AppIcon-partial.plist" \
  "$output_dir/NeBrowser.xcassets" >"$output_dir/actool.stdout" 2>"$output_dir/actool.stderr"

cp "$actool_output/AppIcon.icns" "$output_dir/firefox.icns"
cp "$output_dir/firefox.icns" "$output_dir/document.icns"
cp "$actool_output/Assets.car" "$output_dir/Assets.car"
echo "Brand assets generated: $output_dir"
