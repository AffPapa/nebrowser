#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source "$project_dir/config/product.env"

cache_dir="$project_dir/.cache"
cargo_home="$cache_dir/cargo"
rustup_home="$cache_dir/rustup"
download_dir="$cache_dir/downloads"
toolchain_dir="$cache_dir/toolchains"
clang_archive="$download_dir/clang.tar.zst"
wasi_archive="$download_dir/sysroot-wasm32-wasi.tar.zst"
rustup_init="$download_dir/rustup-init"
cbindgen_dir="$toolchain_dir/cbindgen-$CBINDGEN_VERSION"
wasi_sysroot="$toolchain_dir/sysroot-wasm32-wasi"

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "NeBrowser's pinned bootstrap currently supports Apple Silicon macOS only" >&2
  exit 1
fi

mkdir -p "$cargo_home" "$rustup_home" "$download_dir" "$toolchain_dir"
export CARGO_HOME="$cargo_home"
export RUSTUP_HOME="$rustup_home"

if [[ ! -x "$cargo_home/bin/rustc" ]] || [[ "$($cargo_home/bin/rustc --version)" != "rustc $RUST_VERSION "* ]]; then
  curl --fail --location --retry 3 --output "$rustup_init" "$RUSTUP_INIT_URL"
  printf '%s  %s\n' "$RUSTUP_INIT_SHA256" "$rustup_init" | shasum -a 256 --check
  chmod +x "$rustup_init"
  "$rustup_init" -y --no-modify-path \
    --default-host aarch64-apple-darwin \
    --default-toolchain "$RUST_VERSION" \
    --component rustfmt
fi

if [[ ! -x "$toolchain_dir/clang/bin/clang" ]]; then
  curl --fail --location --retry 3 --output "$clang_archive" "$FIREFOX_CLANG_URL"
  printf '%s  %s\n' "$FIREFOX_CLANG_SHA256" "$clang_archive" | shasum -a 256 --check
  tar -xf "$clang_archive" -C "$toolchain_dir"
fi

if [[ ! -x "$toolchain_dir/clang/bin/ld64.lld" ]]; then
  echo "Pinned Mozilla clang archive does not contain ld64.lld" >&2
  exit 1
fi

if [[ ! -f "$wasi_sysroot/include/string.h" ]]; then
  curl --fail --location --retry 3 --output "$wasi_archive" "$FIREFOX_WASI_SYSROOT_URL"
  printf '%s  %s\n' "$FIREFOX_WASI_SYSROOT_SHA256" "$wasi_archive" | shasum -a 256 --check
  tar -xf "$wasi_archive" -C "$toolchain_dir"
fi

if [[ ! -f "$wasi_sysroot/include/string.h" ]]; then
  echo "Pinned WASI sysroot archive does not contain include/string.h" >&2
  exit 1
fi

if [[ ! -x "$cbindgen_dir/bin/cbindgen" ]]; then
  "$cargo_home/bin/cargo" install \
    --git "$CBINDGEN_REPOSITORY" \
    --rev "$CBINDGEN_REVISION" \
    --locked \
    --root "$cbindgen_dir" \
    cbindgen
fi

if [[ "$($cbindgen_dir/bin/cbindgen --version)" != "cbindgen $CBINDGEN_VERSION" ]]; then
  echo "Pinned cbindgen version does not match $CBINDGEN_VERSION" >&2
  exit 1
fi

"$cargo_home/bin/rustc" --version
"$toolchain_dir/clang/bin/clang" --version | sed -n '1p'
"$toolchain_dir/clang/bin/ld64.lld" --version | sed -n '1p'
"$cbindgen_dir/bin/cbindgen" --version
echo "WASI sysroot: $wasi_sysroot"
echo "Pinned NeBrowser toolchains are ready"
