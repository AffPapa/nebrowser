# Direct macOS release

NeBrowser follows the same fail-closed Direct Distribution model as NeAntik.
It is not an App Store product.

The public-ready gate requires all of the following:

1. The exact source snapshot URL is published and recorded.
2. The ARM64 app passes package verification.
3. The app is signed with Developer ID and the hardened runtime.
4. Apple notarization succeeds and the ticket is stapled.
5. The final ZIP and DMG pass local signature, stapler, integrity and SHA-256 checks.
6. The AffPapa landing, machine-readable release metadata, CTA, archive and SHA sidecars agree.
7. A fresh hosted download is hashed and opened on a clean macOS account.

Run signing and notarization from the user's normal Terminal if the managed
Codex process cannot access the Keychain profile. Never paste Apple credentials
into chat, source files or logs.

`config/release.json` must remain `publicReady: false` until every local and
hosted check has passed for the exact final artifacts.

Create the source-overlay candidate with `scripts/package-source.sh`. It must
be published together with the exact official Firefox source archive reference
from `docs/SOURCE.md`; record the immutable public URL before changing any
release status.
