#!/usr/bin/env bash
set -Eeuo pipefail

[[ "$(id -u)" -eq 0 ]] || {
  echo "Run as root on the AffPapa origin." >&2
  exit 1
}
[[ $# -eq 1 ]] || {
  echo "Usage: $0 <directory-containing-index-and-icon>" >&2
  exit 2
}

source_dir=$(readlink -f "$1")
live_root="/var/www/hrband"
public_parent="$live_root/public"
live_dir="$public_parent/nebrowser"
backup_root="$live_root/storage/app/codex-backups"
timestamp=$(date -u +%Y%m%dT%H%M%SZ)
backup_dir="$backup_root/nebrowser-page-$timestamp"
install_dir=""
had_live=0

test -f "$source_dir/index.html"
test -f "$source_dir/nebrowser-icon.png"
grep -Fq '<link rel="canonical" href="https://affpapa.org/nebrowser/">' \
  "$source_dir/index.html"
grep -Fq 'https://github.com/AffPapa/nebrowser' "$source_dir/index.html"
file "$source_dir/nebrowser-icon.png" | grep -Fq 'PNG image data'

mkdir -p "$backup_dir"
install_dir=$(mktemp -d "$public_parent/.nebrowser.install.XXXXXX")
install -m 644 -o deploy -g deploy "$source_dir/index.html" "$install_dir/index.html"
install -m 644 -o deploy -g deploy \
  "$source_dir/nebrowser-icon.png" "$install_dir/nebrowser-icon.png"

rollback() {
  local status=$?
  if [[ -n "$install_dir" && -d "$install_dir" ]]; then
    rm -rf -- "$install_dir"
  fi
  if [[ "$had_live" -eq 1 && -d "$backup_dir/live" ]]; then
    rm -rf -- "$live_dir"
    mv "$backup_dir/live" "$live_dir"
  elif [[ "$had_live" -eq 0 ]]; then
    rm -rf -- "$live_dir"
  fi
  echo "NeBrowser page install failed; previous state restored." >&2
  exit "$status"
}
trap rollback ERR

if [[ -d "$live_dir" ]]; then
  had_live=1
  mv "$live_dir" "$backup_dir/live"
fi
mv "$install_dir" "$live_dir"
install_dir=""

served_html=$(mktemp /tmp/nebrowser-page-live.XXXXXX)
curl -fsS --insecure --resolve "affpapa.org:443:127.0.0.1" \
  "https://affpapa.org/nebrowser/" > "$served_html"
cmp -s "$served_html" "$live_dir/index.html"
curl -fsS --insecure --resolve "affpapa.org:443:127.0.0.1" \
  "https://affpapa.org/nebrowser/nebrowser-icon.png" >/dev/null

trap - ERR
echo "PASS: NeBrowser page installed at https://affpapa.org/nebrowser/"
echo "Backup: $backup_dir"
