# NeBrowser landing page

`website/` is the deployable static surface for `https://affpapa.org/nebrowser/`.
It links the live AffPapa design bundle at `/css/affpapa.min.css` and keeps only
NeBrowser-specific presentation in `nebrowser.css`.

The page intentionally references only immutable product metadata and GitHub
Release asset names. Switch the AffPapa production buttons to stable only
after both `notarized.dmg` and `notarized.zip` exist in the latest non-draft
GitHub Release and their hosted bytes pass `docs/RELEASING.md`.

Until the stable release exists, the page explicitly labels and links the
unsigned technical preview. GitHub Pages is the public fallback; the same
files are ready to be copied into the AffPapa web root when server access is
available.

The canonical production page is live at `https://affpapa.org/nebrowser/`.
Production updates use the dedicated forced-command SSH account and deploy an
exact 40-character commit from this repository; no general shell or root access
is granted to the deploy identity.
