# Manual macOS QA

Use the ad-hoc ZIP in `dist/local/` for local QA. It is not a public release.

1. Verify its `.sha256` sidecar with `shasum -a 256 -c <sidecar>`.
2. Extract the ZIP and open `NeBrowser.app` in a normal logged-in macOS session.
3. Confirm the Dock/Finder icon is the dark blue ribbon-N icon.
4. Confirm the first window opens `https://affpapa.org/`.
5. Confirm **NeBrowser > About NeBrowser** shows NeBrowser and version 153.0.4.
6. Open a second window, private window, downloads, history, settings and one
   WebExtension to confirm the standard Firefox surfaces remain functional.
7. Quit and reopen; confirm the profile is stored under the NeBrowser identity
   and does not replace an installed Firefox profile.

Public QA starts only after `scripts/release-direct.sh` has produced a
Developer ID signed, notarized and stapled candidate. At that stage also run
`scripts/verify-direct-local.sh`, Gatekeeper assessment and a fresh hosted
download/hash comparison.
