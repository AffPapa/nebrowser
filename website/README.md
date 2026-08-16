# NeBrowser landing page

`index.html` and `nebrowser-icon.png` are the deployable static surface for
`https://affpapa.org/nebrowser/`.

The page intentionally references only immutable product metadata and GitHub
Release asset names. Switch the AffPapa production buttons to stable only
after both `notarized.dmg` and `notarized.zip` exist in the latest non-draft
GitHub Release and their hosted bytes pass `docs/RELEASING.md`.

Until the stable release exists, the page explicitly labels and links the
unsigned technical preview. GitHub Pages is the public fallback; the same
files are ready to be copied into the AffPapa web root when server access is
available.
