# Building NeBrowser on macOS

## Host requirements

- Apple Silicon Mac
- Current or previous supported macOS release
- Full Xcode selected with `xcode-select`
- Homebrew
- At least 30 GiB of free disk space

## Flow

1. `./scripts/bootstrap-firefox.sh`
2. `./scripts/bootstrap-toolchains.sh`
3. `./scripts/apply-overlay.sh`
4. `./scripts/build-macos.sh`
5. `./scripts/verify-package.sh`
6. `./scripts/package-local.sh`

The bootstrap script checks out the exact upstream tag and commit recorded in
`config/product.env`. The overlay is intentionally small so Firefox security
updates can be adopted with minimal conflicts.

Mozilla toolchains, Rust state and package caches are kept under `.cache/`
rather than the user's home directory.

Managed macOS sessions set `NEBROWSER_GYP_THREAD_POOL=1`, so Firefox's metadata
reader uses threads instead of unavailable Python process semaphores. This only
changes build orchestration and is not compiled into NeBrowser.

The overlay also lets `mach build` continue at normal process priority when a
managed session denies `os.nice`; the compiled browser is unaffected.

Local packages are development artifacts. Public distribution additionally
requires Developer ID signing, Apple notarization, stapling, a published source
snapshot, SHA-256 sidecars and hosted-download verification.
