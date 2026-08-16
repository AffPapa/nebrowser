# Corresponding source

NeBrowser 0.1.0 uses Firefox 153.0.4 source from Mozilla's official release
archive:

- Source: `https://archive.mozilla.org/pub/firefox/releases/153.0.4/source/firefox-153.0.4.source.tar.xz`
- Upstream tag: `FIREFOX_153_0_4_RELEASE`
- Upstream commit: `0c39e9282688363f5028d0541c17784f7fa5117c`
- SHA-512: `9081beed7f08797c2128094169cf95af4a35e208fd22bba709bfb1a19e15d15aa484fccae71154d2ae0ff955bf629cd634cc7ed6b180371aea792daf7c689ff7`

The NeBrowser overlay, build configuration and scripts in this repository are
the preferred form for the NeBrowser modifications. Run the documented
bootstrap and overlay steps to reconstruct the complete modified source tree.

Before distributing a NeBrowser binary, publish an immutable snapshot of this
repository and put its exact URL in `config/release.json` and the application's
distribution notice.

