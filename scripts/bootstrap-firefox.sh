#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

cache_dir="$project_dir/.cache"
archive_path="$cache_dir/firefox-${FIREFOX_VERSION}.source.tar.xz"
source_dir="$cache_dir/firefox-source"

mkdir -p "$cache_dir"

if [[ ! -f "$archive_path" ]]; then
  curl -fL --retry 3 --continue-at - -o "$archive_path" "$FIREFOX_SOURCE_URL"
fi

actual_sha512="$(shasum -a 512 "$archive_path" | awk '{print $1}')"
if [[ "$actual_sha512" != "$FIREFOX_SOURCE_SHA512" ]]; then
  echo "Firefox source SHA-512 mismatch" >&2
  exit 1
fi

if [[ ! -d "$source_dir" ]]; then
  tar -xJf "$archive_path" -C "$cache_dir"
  mv "$cache_dir/firefox-${FIREFOX_VERSION}" "$source_dir"
fi

actual_version="$(tr -d '[:space:]' < "$source_dir/browser/config/version.txt")"
if [[ "$actual_version" != "$FIREFOX_VERSION" ]]; then
  echo "Expected Firefox $FIREFOX_VERSION, found $actual_version" >&2
  exit 1
fi

echo "Firefox source ready: $source_dir"

