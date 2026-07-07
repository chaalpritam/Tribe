# Tribe

Native SwiftUI hyperlocal iOS client for the [TribeEco](https://github.com/chaalpritam/TribeEco) decentralized social protocol. Ports the [`tribeapp.wtf`](../tribeapp.wtf) web experience to iPhone — city-first feeds, channels/tribes, explore, map, chat, wallet, and create flows on the same hub + envelope format as the rest of the stack.

- **Bundle ID:** `app.tribe.app` (distinct from `app.tribe.twitter` so both apps can coexist)
- **Display name:** Tribe
- **Platform:** iPhone, portrait only

## Status

Feature-complete against a live hub + ER stack. All shell tabs ship read/write surfaces for tweets, events, polls, tasks, crowdfunds, DMs, tribes/channels, wallet, and notifications.

**Channel scoping:** Home, Explore, and Profile respect the active city/channel (`activeChannel`), not just the user's home city.

**Explore (recent):**

| Feature | Description |
|---------|-------------|
| Hub search | Debounced member search with channel-scoped results and profile deep links |
| Preview cards | Tappable rows open full detail (RSVP, vote, claim, etc.) |
| Map | MapKit pins for events; deep links to event detail or city scope |
| Discover tribes | Join city-scoped tribes from Explore and Tribes tab |
| Event time buckets | Tonight / This weekend / Later sections |

See [`PLAN.md`](PLAN.md) for the original port roadmap and remaining polish items.

## Requirements

- Xcode 16+ (iOS 17 deployment target)
- A running stack: `brew install tribe && tribe start` (hub `:4000`, ER `:3003`)
- Optional: [xcodegen](https://github.com/yonaskolb/XcodeGen) when editing `Project.yml`

## Running

```sh
cd tribe
open Tribe.xcodeproj
# Pick an iPhone simulator and ⌘R
```

`tribe-core-swift` is wired as a local SPM dependency (`../tribe-core-swift` in the monorepo). Standalone clone:

```sh
git clone https://github.com/chaalpritam/tribe-core-swift.git ../tribe-core-swift
xcodegen generate   # if you change Project.yml
```

On a physical device, set the hub URL to your Mac's LAN IP (`tribe share`) in onboarding or Settings.

## Layout

```
Tribe/                    App target (entry, assets, Info.plist)
Sources/
  API/                    Hub + ER clients, endpoints, publish helpers
  Common/                 HubDecode, TribeDiscovery, EventTimeBuckets, …
  Home/                   Mixed feed store, channel scope
  Models/                 Hub-aligned decodable types
  State/                  AppState, caches, notifications
  Theme/                  Design tokens (tribeapp.wtf mapping)
  Views/
    Shell/                Bottom pill nav, city switcher, tabs
    Home/                 Mixed feed cards
    Explore/              Search, map, tribes, bucketed events
    Tribes/               Channel directory
    Chat/                 Encrypted DMs
    Profile/              Self + other users, karma, follow lists
    Wallet/               Tips ledger, receive QR
    Create/               Tweet, event, poll, task, crowdfund, tribe composers
    Onboarding/           Connect hub, import/create identity, city picker
Tests/                    Unit tests (HubDecode, Explore, feed mixer, …)
```

Crypto and shared wire types come from [`tribe-core-swift`](../tribe-core-swift) (`import TribeCore`).

## Sister clients

| App | Shape | Bundle ID |
|-----|-------|-----------|
| **Tribe** (this repo) | Hyperlocal / tribeapp.wtf | `app.tribe.app` |
| [tribe-twitter](../tribe-twitter) | Twitter-shaped tabs | `app.tribe.twitter` |
| [tribe-insta](../tribe-insta) | Instagram-shaped (photos, reels) | `app.tribe.insta` |

## Related Repos

| Repo | Description |
|------|-------------|
| [TribeEco](https://github.com/chaalpritam/TribeEco) | Monorepo — protocol stack, clients, deploy tooling |
| [tribe-protocol](https://github.com/chaalpritam/tribe-protocol) | Solana programs (Anchor) — identity, social graph, registries |
| [tribe-sdk](https://github.com/chaalpritam/tribe-sdk) | TypeScript SDK — DirectSolana and EphemeralRollup providers |
| [tribe-hub](https://github.com/chaalpritam/tribe-hub) | Decentralized hub — message storage, Solana indexer, gossip sync |
| [tribe-er-server](https://github.com/chaalpritam/tribe-er-server) | Ephemeral Rollup sequencer — instant follows, L1 settlement |
| [tribe-twitter](https://github.com/chaalpritam/tribe-twitter) | Native SwiftUI Twitter-shaped iOS app (`app.tribe.twitter`) |
| [tribe-insta](https://github.com/chaalpritam/tribe-insta) | Native SwiftUI Instagram-shaped iOS app — photos, stories, reels |
| [tribe-twitter-app](https://github.com/chaalpritam/tribe-twitter-app) | Next.js reference web client |
| [tribeapp.wtf](https://github.com/chaalpritam/tribeapp.wtf) | Consumer hyperlocal web app + landing page |
| [tribe-core-swift](https://github.com/chaalpritam/tribe-core-swift) | Shared Swift package — crypto, hub API, models (see `MIGRATION.md`) |
| [homebrew-tap](https://github.com/chaalpritam/homebrew-tribe) | Homebrew formulas — `brew install tribe`, `brew install tribe-twitter-app` |

## License

MIT — same as the rest of TribeEco.
