# NeBrowser landing page

`index.html` and `nebrowser-icon.png` are the deployable static surface for
`https://affpapa.org/nebrowser/`.

The page intentionally references only immutable product metadata and GitHub
Release asset names. Publish it only after both `notarized.dmg` and
`notarized.zip` exist in the latest non-draft GitHub Release and their hosted
bytes pass the checks from `docs/RELEASING.md`.
