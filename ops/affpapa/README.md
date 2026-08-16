# AffPapa page deployment

The reviewed site payload is `website/`. On the AffPapa origin, stage this
repository and run as root:

```sh
./ops/affpapa/install-nebrowser-page.sh ./website
```

The installer validates canonical/source links and the PNG, backs up the
existing `/var/www/hrband/public/nebrowser`, replaces it atomically, then
checks both resources through the loopback TLS vhost. Any failed check restores
the previous state.

The existing `neantik-deploy` SSH identity must not be expanded or reused for
this command. A server administrator installs the page through a separately
authorized root session.
