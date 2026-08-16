#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

release_dir="$project_dir/dist/source"
archive_name="NeBrowser-${NEBROWSER_VERSION}-source-overlay.tar.gz"
archive_path="$release_dir/$archive_name"
mkdir -p "$release_dir"

tar \
  --exclude='./.git' \
  --exclude='./.cache' \
  --exclude='./build' \
  --exclude='./dist' \
  --exclude='*/__pycache__' \
  -czf "$archive_path" \
  -C "$project_dir" .

(
  cd "$release_dir"
  shasum -a 256 "$archive_name" > "$archive_name.sha256"
  shasum -a 256 -c "$archive_name.sha256"
)
tar -tzf "$archive_path" > /dev/null
echo "NeBrowser source overlay archive created: $archive_path"
