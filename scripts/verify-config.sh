#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

config_status="${1:-$project_dir/.cache/firefox-source/obj-nebrowser/config.status}"
test -s "$config_status"

rg -q --fixed-strings "'MOZ_APP_NAME': 'nebrowser'" "$config_status"
rg -q --fixed-strings "'MOZ_APP_BASENAME': '$NEBROWSER_NAME'" "$config_status"
rg -q --fixed-strings "'MOZ_APP_DISPLAYNAME': '$NEBROWSER_NAME'" "$config_status"
rg -q --fixed-strings "'MOZ_APP_VENDOR': '$NEBROWSER_VENDOR'" "$config_status"
rg -q --fixed-strings "'MOZ_APP_ID': '{5d43746d-4ca8-48d2-a934-12a85cfe8c6e}'" "$config_status"
rg -q --fixed-strings "'MOZ_MACBUNDLE_ID': '$NEBROWSER_BUNDLE_ID'" "$config_status"

if rg -q "'MOZ_(UPDATER|TELEMETRY_REPORTING|CRASHREPORTER)': True" "$config_status"; then
  echo "A Mozilla-operated product service was enabled in the NeBrowser configuration" >&2
  exit 1
fi

echo "NeBrowser build configuration verification passed"
