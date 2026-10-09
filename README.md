# ValWiki for iOS

A native SwiftUI encyclopedia for VALORANT, rebuilt for iOS 26 with Liquid Glass. Companion to the web wiki at [cyberromeo.github.io/valwiki](https://cyberromeo.github.io/valwiki/). All data is live from the public [valorant-api.com](https://valorant-api.com).

## What's in it

- **Home**: featured agent hero (shuffle), live patch number, current act with days left, map pool rail, quick links.
- **Agents**: role filter, search, full dossier per agent with ability picker (Q / E / C / X keys), role info, same-role agents, previous/next.
- **Arsenal**: every weapon grouped by class with cost and fire rate; handling gauges, damage-by-range table, and every skin with edition filter, variant switcher, upgrade levels and level videos.
- **Maps**: competitive pool and mode maps, splash art, and an interactive minimap with every callout plotted from the API's coordinates (filter by site, full-screen zoom).
- **Search**: one search tab across agents, weapons, skins, maps and bundles.
- **Intel**: competitive ranks, episodes & acts timeline, game modes, store bundles, and a 30-second aim trainer that saves your best score.
- Works offline after the first launch (API responses and images are cached).

Native iOS 26 design: floating glass tab bar with a search tab, Liquid Glass cards and buttons, large titles, sheets and lists. Valorant red is the accent. Runs on iOS 18+ (glass effects need iOS 26; older versions get frosted material).

## Build

The Xcode project is generated from `project.yml`:

```sh
brew install xcodegen
xcodegen generate
open ValWiki.xcodeproj
```

Every push to `main` runs **Build Unsigned IPA** on GitHub Actions (Xcode 26). It uploads `ValWiki-unsigned.ipa` as a workflow artifact and to the `latest-build` pre-release.

## Install the unsigned IPA

The IPA is not signed, so install it with a sideloading tool that signs it with your own Apple ID: **Sideloadly** or **AltStore / SideStore** (a free Apple ID re-signs for 7 days), or **TrollStore** on supported iOS versions.

The previous version of this app is on the `pre-redesign-backup` branch.

_Not affiliated with or endorsed by Riot Games._
