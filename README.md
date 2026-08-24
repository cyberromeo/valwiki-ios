# VALOWIKI

A funky, dark-mode, native iOS (SwiftUI) encyclopedia for VALORANT, powered by **every live endpoint of [valorant-api.com](https://valorant-api.com)** — 25 paths, one app. Designed after brutalist music-app aesthetics: condensed display type, monospace micro-labels, film grain, halftone dot matrices, glow blobs, tilted red tickers, and a floating tab bar.

![design](https://img.shields.io/badge/style-BRUTALIST_FUNK-FF4655) ![ios](https://img.shields.io/badge/iOS-17%2B-black) ![swiftui](https://img.shields.io/badge/SwiftUI-native-blue)

## Features

- **Home** — rotating featured-agent hero with dossier corner-tags, red marquee ticker, endpoint vault grid (now with Bundles), map rotation rail, live build footer. Pull-to-refresh.
- **Agents** — role-filtered grid, gradient cards from the API's own `backgroundGradientColors`, full dossier view with ability tabs and playable **voice lines** (AVPlayer, lenient-decoded).
- **Maps** — splash cards with coordinates + tactical descriptions, callout grid grouped by super-region, and an **interactive tactical minimap**: callouts are plotted from the API's world coordinates using its own multipliers — tap a ping to identify it.
- **Arsenal** — guns (grouped by category, full ballistics + damage matrix) and the full skin gallery with tier filters (Select / Deluxe / Premium / Ultra / Exclusive), chroma colorway switcher, upgrade ladder. Stock weapon skins are filtered out automatically.
- **Everything Else hub** — game modes, seasons timeline, competitive ranks **with episode picker**, contracts with chapter/reward ladders (real `content.chapters[].levels[].reward` shape), esports pass events with LIVE badges, bundles, ceremonies, mode items, buddies, buddy levels, player cards, sprays (null sprays filtered), spray levels, player titles, currencies, skin chromas, skin levels, skin themes, gear, and **live rarity tiers** from `/v1/contenttiers` (skin colors are driven by the API, not hardcoded).
- **System** — live game version terminal card, and a **Raw Feed** terminal that pretty-prints JSON from any of the 25 endpoints.
- **Global search** across agents, maps, weapons, skins, buddies, cards, sprays, bundles and titles.
- Custom floating tab bar with matched-geometry glow, haptics, splash screen, offline "SIGNAL LOST" retry screen, NSCache-backed image loading.

## Endpoint coverage (25/25 live endpoints)

| Endpoint | Screen |
| --- | --- |
| `/v1/agents?isPlayableCharacter=true` | Agents grid + dossier |
| `/v1/maps` | Maps + callouts + interactive minimap radar |
| `/v1/weapons` | Guns list + stats + damage matrix |
| `/v1/weapons/skins` | Skin gallery + detail |
| `/v1/weapons/skinchromas` | Chromas grid + chroma switcher |
| `/v1/weapons/skinlevels` | Skin levels grid + upgrade ladder |
| `/v1/buddies` | Buddies grid |
| `/v1/buddies/levels` | Buddy levels grid |
| `/v1/playercards` | Player cards grid |
| `/v1/sprays` | Sprays grid |
| `/v1/sprays/levels` | Spray levels grid |
| `/v1/playertitles` | Titles list |
| `/v1/currencies` | Currencies list |
| `/v1/gamemodes` | Modes list |
| `/v1/gamemodes/equippables` | Mode items grid |
| `/v1/gear` | Gear list |
| `/v1/seasons` | Seasons timeline |
| `/v1/competitivetiers` | Ranks by division + episode picker |
| `/v1/contracts` | Contracts + chapter/reward ladders |
| `/v1/themes` | Skin themes list |
| `/v1/events` | Events list with LIVE badges |
| `/v1/bundles` | Bundles grid + Home vault tile |
| `/v1/ceremonies` | Ceremonies list |
| `/v1/contenttiers` | Rarity list + dynamic skin tier colors |
| `/v1/version` | Version terminal card |

The Raw Feed terminal can query any of these paths live.

## Build

### Option A — Swift Playgrounds (iPad / Mac, no Xcode needed)

The repo ships a self-contained Swift Playgrounds package: **`VALOWIKI.swiftpm`**.

1. Copy `VALOWIKI.swiftpm` to your iPad or Mac (AirDrop, iCloud Drive, or Files).
2. Tap it in **Files** — it opens straight into [Swift Playgrounds](https://www.apple.com/swift-playgrounds/) (iPadOS 17+ / macOS 14+).
3. Press **⌘R / Run** to launch the full app. Edit any file and re-run to see changes live.

The `.swiftpm` bundle is a Swift package with an `.iOSApplication` product (`Package.swift`), so it also opens directly in Xcode 15+ if you prefer.

### Option B — open the pre-generated project

```bash
open VALOWIKI.xcodeproj
```

Select the `VALOWIKI` scheme and press ⌘R on any iOS 17+ simulator. No signing account needed for the simulator.

### Option C — regenerate with XcodeGen

```bash
brew install xcodegen
cd VALOWIKI
xcodegen
open VALOWIKI.xcodeproj
```

### Option D — plain Xcode

1. Xcode → File → New → Project → iOS App (SwiftUI, Swift), deployment target iOS 17.0.
2. Delete the generated `ContentView.swift` / app entry file.
3. Drag the `VALOWIKI/VALOWIKI` source folder into the project navigator (copy items, create groups).
4. ⌘R.

No third-party dependencies.

## Project layout

```
VALOWIKI/
├── VALOWIKI.xcodeproj             pre-generated project (Xcode 16 format)
├── VALOWIKI.swiftpm               Swift Playgrounds app package (iPad + Xcode)
├── project.yml                    XcodeGen spec (optional)
└── VALOWIKI/
    ├── App/                       entry point, root tabs, splash, theme (colors/fonts/haptics)
    ├── Core/
    │   ├── Networking/            generic async/await API client
    │   ├── Models/                Codable models for all 25 endpoints (+ FlexDouble safe numeric decoding)
    │   ├── Services/              @Observable LibraryStore + cached image loader
    │   └── Routes.swift            endpoint index, routes, navigation destinations
    └── UI/
        ├── Components/            grain/dots/glow FX, tab bar, chips, stat bars, ticker
        └── Features/              Home, Agents, Maps, Arsenal, More hub, Search
```

## Design system

- **Ink** `#0A0A0E` page, **Panel** `#121218` cards, **VAL Red** `#FF4655` accent, **Cream** `#ECE8E1` type, **Mint** `#8CE3E9` secondary, **Gold** `#F2C94C` tertiary.
- Condensed heavy display type (`UIFont.systemFont(ofSize:weight:width:)`) + monospaced micro-labels with wide tracking.
- Film grain (generated noise texture, overlay blend), halftone `Canvas` dot matrices, blurred glow blobs, tilted red marquee ticker.
- Light haptics on taps, heavy on retries.

## Data-resilience notes

The API mixes JSON numbers and numeric strings for the same fields (`fireRate: 11` vs `equipTimeSeconds: "0.75"`), and several map/contract payloads nest differently than they first appear. Every risky field decodes through `FlexDouble` / `LenientBox` wrappers, so a payload surprise degrades one card to "—" instead of blanking a whole screen. Decoding runs off the main actor so the splash animation never stutters.

## Disclaimer

Unofficial fan project. Data and assets from valorant-api.com. VALORANT and all related properties are trademarks of Riot Games, Inc. Not endorsed by Riot Games.
