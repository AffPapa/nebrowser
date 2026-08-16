#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
source_dir="$project_dir/.cache/firefox-source"
nebrowser_mozbuild_state="$project_dir/.cache/mozbuild"
nebrowser_cargo_home="$project_dir/.cache/cargo"
nebrowser_rustup_home="$project_dir/.cache/rustup"
nebrowser_pip_cache="$project_dir/.cache/pip"
nebrowser_uv_cache="$project_dir/.cache/uv"
nebrowser_clang_dir="$project_dir/.cache/toolchains/clang"

mkdir -p "$nebrowser_mozbuild_state" "$nebrowser_cargo_home" "$nebrowser_rustup_home" "$nebrowser_pip_cache" "$nebrowser_uv_cache"
export MOZBUILD_STATE_PATH="$nebrowser_mozbuild_state"
export CARGO_HOME="$nebrowser_cargo_home"
export RUSTUP_HOME="$nebrowser_rustup_home"
export PIP_CACHE_DIR="$nebrowser_pip_cache"
export UV_CACHE_DIR="$nebrowser_uv_cache"
export PATH="$nebrowser_clang_dir/bin:$project_dir/.cache/toolchains/cbindgen-0.29.4/bin:$nebrowser_cargo_home/bin:$PATH"
export CC="$nebrowser_clang_dir/bin/clang"
export CXX="$nebrowser_clang_dir/bin/clang++"
export CBINDGEN="$project_dir/.cache/toolchains/cbindgen-0.29.4/bin/cbindgen"
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
export WASI_SYSROOT="$project_dir/.cache/toolchains/sysroot-wasm32-wasi"
export NEBROWSER_GYP_THREAD_POOL=1
export PYTHONPYCACHEPREFIX="$project_dir/.cache/python-pycache"

"$script_dir/bootstrap-firefox.sh"
"$script_dir/bootstrap-toolchains.sh"
"$script_dir/apply-overlay.sh" "$source_dir"
"$script_dir/verify-overlay.sh" "$source_dir"

cd "$source_dir"
./mach build
"$script_dir/verify-config.sh"
./mach package

echo "NeBrowser build and package completed"
