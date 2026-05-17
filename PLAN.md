# Tribe iOS — Port of tribeapp.wtf

Native SwiftUI iOS app that ports the full feature set of the `tribeapp.wtf` web client (Next.js) into the `tribe/` submodule. Reuses `tribe-core-swift` (crypto) and lifts models/API/state patterns from `tribe-ios` (the existing Twitter-shaped client).

## Goals

- Hyperlocal social app, city-first, on the Tribe protocol.
- Feature parity with the web app: home, explore, map, tribes/channels, chat (DMs), profile, wallet, notifications, create.
- Mixed content feed: tweets + events + polls + tasks + crowdfunds, scoped by city/channel.
- E2E-encrypted DMs (NaCl box).
- On-chain identity (TID), reputation (karma), value transfer (tips/escrow), follows via ER + L1 settlement.

## Non-goals (initially)

- Single-tweet thread detail screen with deep replies (web doesn't have a dedicated route either — replies live in cards).
- Places/reviews data plane (web shows dummy data only; map shows placeholder, not real MapKit pins).
- Tribe creation on-chain registration UX polish (channel-registry call works, but slug-pick/conflict UX is minimal in week 1).
- WalletConnect / external wallet pairing — we'll use in-app keypair (Keychain-backed AppKey + custody seed) matching `tribe-ios`. External wallet linking is a later phase.

---

## Architecture

```
tribe/
├── Tribe.xcodeproj/               (replace with Project.yml + xcodegen, matching tribe-ios)
├── Tribe/                          (app target sources: Assets, Info.plist, App entry, Theme)
├── Sources/                        (NEW — feature code)
│   ├── Models/                     (copied from tribe-ios; trimmed)
│   ├── API/                        (HubClient, ERClient, Endpoints, Publish, InteractionReads)
│   ├── State/                      (AppState, caches — adapted for hyperlocal shape)
│   ├── Theme/                      (colors, typography, spacing — design tokens)
│   ├── Views/
│   │   ├── Onboarding/             (Connect, City)
│   │   ├── Shell/                  (BottomPillNav, AppHeader, Tab containers)
│   │   ├── Home/                   (mixed feed)
│   │   ├── Explore/
│   │   ├── Map/
│   │   ├── Tribes/                 (directory + single tribe)
│   │   ├── Chat/                   (conversations + thread)
│   │   ├── Profile/                (self + others, edit sheet, follow lists)
│   │   ├── Wallet/                 (balance + tips ledger)
│   │   ├── Notifications/
│   │   ├── Create/                 (mode selector + 6 composers)
│   │   └── Common/                 (cards: Tweet, Event, Poll, Task, Crowdfund; buttons, badges)
│   └── Common/                     (decoding helpers, formatters, utilities)
├── Package.dependencies            (SPM: TribeCore via local path)
└── PLAN.md
```

### Package wiring

- Add `tribe-core-swift` as an SPM **local** dependency (path: `../tribe-core-swift`). Same approach as `tribe-ios` after Phase 4.1 cutover.
- App imports: `import TribeCore` for all crypto (AppKey, DMKey, Blake3, NaClBox, MessageSigner, BIP39, SolanaHD, BackupFile, Keychain).
- Bundle id: `app.tribe.app` (distinct from `app.tribe.ios` so Keychain is isolated and both can coexist on the same device).

### Project layout choice

Switch from Xcode-managed `.xcodeproj` to `Project.yml` + xcodegen, matching `tribe-ios` and `tribe-insta`. Justification: less merge conflict noise, consistent with sibling repos, easier CI.

---

## Design system mapping (web → SwiftUI)

| Token | Web | SwiftUI |
|---|---|---|
| Primary | `#6366F1` indigo | `Color("Primary")` in Assets, semantic `Theme.primary` |
| Success | `#10B981` | `Theme.success` |
| Warning | `#F59E0B` | `Theme.warning` |
| Error | `#EF4444` | `Theme.error` |
| Body font | Inter | SF Pro (system) |
| Mono | Geist Mono / similar | `.system(.body, design: .monospaced)` |
| Card corner | 16–24pt | `RoundedRectangle(cornerRadius: 20)` |
| Modal/sheet corner | 32–40pt | `.presentationCornerRadius(36)` |
| Bottom nav pill | rounded, dark, fixed | Custom view at safe-area bottom |
| Shadows | `shadow-sm`/`shadow-2xl` | `.shadow(color:radius:x:y:)` matched per tier |

Build a `Theme` namespace in `Sources/Theme/` exporting colors, type ramp, spacing constants, and card/modal radii so every view pulls from one place.

---

## Reuse map

What gets copied from where, and how.

| Concern | Source | Destination | Effort |
|---|---|---|---|
| Crypto (AppKey, DMKey, Blake3, NaClBox, MessageSigner, BIP39, SolanaHD, BackupFile, Keychain) | `tribe-core-swift` (SPM) | `import TribeCore` | 5 min — add Package.swift dependency |
| Models: User, Tweet, DM*, Channel, Notification, Tip, Poll, Event, Task, Crowdfund | `tribe-ios/Sources/Models/*.swift` | `tribe/Sources/Models/` | 30 min — copy verbatim, no changes |
| Decoding helpers (BIGINT TID, ISO/epoch timestamps) | `tribe-ios/Sources/Models/Decoding.swift` | `tribe/Sources/Common/HubDecode.swift` | drop-in |
| Hub transport: `HubClient`, `Endpoints` (45+ read methods), `Publish` (15+ write methods), `InteractionReads` | `tribe-ios/Sources/API/` | `tribe/Sources/API/` | 30 min — copy verbatim |
| ER client | `tribe-ios/Sources/API/ERClient.swift` | `tribe/Sources/API/` | drop-in |
| Caches pattern (Interaction, OnchainTipStats, UserAvatar) | `tribe-ios/Sources/State/` | `tribe/Sources/State/` | copy + rewire to new AppState |
| AppState shape | `tribe-ios/Sources/State/AppState.swift` | `tribe/Sources/State/AppState.swift` | **adapt** — adds `currentCity`, `joinedChannels`, `selectedCityChannelId`; phase enum gets `.cityPicker` step |
| Config (hub/ER base URLs) | `tribe-ios/Sources/Config.swift` | `tribe/Sources/Config.swift` | drop-in + customize defaults |
| Common UI primitives (avatar, badge, button styles) | `tribe-ios/Sources/Views/Common/` | `tribe/Sources/Views/Common/` | **selective copy** — themes diverge, verify each |
| Tweet/Event/Poll/Task/Crowdfund cards | `tribe-ios/Sources/Views/Home/*` | rewrite | **rewrite** — different visual shape (web's rounded-card look) |
| Bottom nav | rewrite | `tribe/Sources/Views/Shell/` | **new** — rounded-pill nav with center + button is distinctive to tribeapp.wtf |
| Onboarding (connect, city) | rewrite | `tribe/Sources/Views/Onboarding/` | **new** — city picker has no analog in tribe-ios |
| DM views | rewrite from tribe-ios pattern | `tribe/Sources/Views/Chat/` | **rewrite** with new visual shape, encryption flow identical |
| Map | new (MapKit) | `tribe/Sources/Views/Map/` | **new** — start with placeholder + filter pills, real MapKit pins in polish phase |

**Estimated reusable line count**: ~4.6k lines from tribe-ios (models + API + state patterns), ~2.5k from TribeCore. Views are all new.

---

## Phases

Each phase is a self-contained landing — review-ready at the end.

### Phase 0 — Plan + Scaffold groundwork (this doc)
Deliverable: `PLAN.md` reviewed and approved. No code yet.

### Phase 1 — Project skeleton
- [ ] Replace `Tribe.xcodeproj` with `Project.yml` + xcodegen. Add Makefile-or-shell entry to regen.
- [ ] Add `tribe-core-swift` as local SPM dependency.
- [ ] Move existing files into `Sources/` layout. `TribeApp.swift` stays in `Tribe/` (app target entry).
- [ ] Create empty `Theme/`, `Models/`, `API/`, `State/`, `Views/` dirs with index .swift files.
- [ ] Confirm `xcodegen generate && xcodebuild -scheme Tribe build` succeeds.

### Phase 2 — Foundation: models, API, state
- [ ] Copy all 13 model files from `tribe-ios/Sources/Models/` → `tribe/Sources/Models/`.
- [ ] Copy all 5 API files from `tribe-ios/Sources/API/` → `tribe/Sources/API/`.
- [ ] Copy and adapt `AppState`: same Phase enum + base fields, add `currentCity: Channel?`, `joinedChannels: [Channel]`.
- [ ] Copy 3 caches (`InteractionCache`, `OnchainTipStatsCache`, `UserAvatarCache`) — rewire to new AppState.
- [ ] Build `Theme/` (colors from Assets.xcassets + Swift `Theme` namespace).
- [ ] App builds; AppState init from Keychain works; can hit a localhost hub and decode `/v1/feed`.

### Phase 3 — Onboarding (connect + city)
- [ ] Connect screen: in-app keypair flow (generate or restore from 12-word mnemonic via `BIP39` + `SolanaHD`).
- [ ] Generate/load `AppKey` and `DMKey` via TribeCore Keychain.
- [ ] Publish initial profile + register DM key (`HubClient.Publish.registerDMKey()`).
- [ ] City picker: load city channels via `Endpoints.fetchChannels()` filtered to `kind=2`. Static fallback list.
- [ ] Persist `currentCity` (UserDefaults) + hydrate AppState on app launch.
- [ ] Phase transitions: `.unloaded → .connect → .city → .ready`.

### Phase 4 — Shell (bottom-nav pill + tab containers)
- [ ] Build `BottomPillNav` view: 6 tabs around a center +Create button. Active-tab styling matches web (white pill on dark bg).
- [ ] `RootShellView` switches on selected tab. Each tab gets a placeholder view.
- [ ] City switcher overlay ("Traveling… Syncing local pulse" spinner) when `currentCity` changes.
- [ ] Common `AppHeader` (sticky title + optional back + optional right actions).

### Phase 5 — Home feed (mixed)
- [ ] Build 5 cards: Tweet, Event, Poll, Task, Crowdfund. Match web's rounded-card aesthetic.
- [ ] Mixed feed view interleaves them (2 tweets → 1 event/poll/task/crowdfund → repeat).
- [ ] Use `Endpoints.fetchChannelFeed()` for current city's tweets.
- [ ] Wire reactions (`likeTweet`/`unlikeTweet`/`bookmark`/`retweet`) via `InteractionCache`.
- [ ] Poll/event/task/crowdfund: stub with hub data first, on-chain queries in Phase 10 polish.
- [ ] Real-time: connect to `/v1/ws` and merge new tweets at top.

### Phase 6 — Tribes / channels
- [x] Directory page: city channels grid (3-col) + interest channels list ("Your Tribes" / "Discover").
- [x] Join/leave (channel-registry envelope).
- [x] Single tribe view: feed scoped to that channel id (reuse Home feed views with channel param).

### Phase 7 — Profile, wallet, notifications
- [x] **Profile**: hero card (avatar + name + handle + bio + badges), karma card, tabs (Posts / Media / Stats), follow lists modal, edit sheet.
  - `fetchUser`, `fetchFollowers`, `fetchFollowing`, on-chain karma via `karma-registry`.
- [x] **Wallet**: balance via Solana RPC `getBalance`, tip ledger via `fetchTipsSent` + `fetchTipsReceived` + `fetchOnchainTips`, disconnect button (clears Keychain + AppState → `.unloaded`).
- [x] **Notifications**: `fetchNotifications` + count badge in shell. Each notification type renders with appropriate icon/verb.

### Phase 8 — Explore, map, chat (DMs)
- [x] **Explore**: search bar (`/v1/search?q=`), channel grid, interleaved discovery content scoped to city.
- [x] **Map**: MapKit-backed view at minimum (real pins for events with coordinates). Filter pills (All/People/Places/Events/Reviews). Place/review sections may show dummy data initially to match web.
- [x] **Chat list**: `fetchDMConversations` + `fetchGroupConversations`.
- [x] **Chat thread**: `fetchDMMessages` (read), NaCl-box decrypt via DMKey + peer pubkey. Send: encrypt + `sendDM`.

### Phase 9 — Create (6 composers)
- [x] Create mode selector (6 cards in 2-col grid: Tweet, Event, Poll, Task, Fund, Tribe).
- [x] Composers — each writes via existing `Publish` paths:
  - **Tweet**: text + image upload (`uploadMedia` → BLAKE3 hash → embed) + channel select.
  - **Event/Poll/Task/Crowdfund**: hub envelope first, on-chain settlement deferred (Phase 10).
  - **Tribe (channel)**: claim slug, register on-chain via channel-registry program.
- [x] PhotosPicker for image input; `URLSessionWebSocketTask` already set up for WS.

### Phase 10 — Polish
- [x] On-chain settlement for events/polls/tasks/crowdfunds — hub-mediated envelopes + `HubSettlementBadge` on cards (matches tribe-ios; direct Anchor client deferred).
- [x] ER follow flow: `FollowButton` reads ER link status, polls while `pending_follow` / `pending_unfollow`, explainer sheet; `ActivityView` surfaces follow settlement rows.
- [x] Image lazy-load + cache: `ImageCache`, `CachedAsyncImage`, URL cache at launch; avatars, tweet media, profile grid.
- [x] Pagination on city home feed (`fetchFeedPage` cursor + load-more in `HomeFeedStore`).
- [x] Error toasts + retry flows: `ToastCenter`, `EmptyStateView` with retry on feed/follow lists/activity.
- [x] Performance pass: NSCache image decode, `LazyVStack` feed, bounded URL cache.

---

## Open decisions

1. **On-chain client library on iOS** — tribe-ios doesn't yet write to Solana programs directly (envelopes go through hub; on-chain settlement is hub-mediated). For events/polls/tasks/crowdfunds, do we (a) wait for hub-mediated settlement (lowest effort, matches current iOS), or (b) use `Solana.swift` to sign + submit Anchor instructions client-side? Decision punted to Phase 10; for now follow tribe-ios pattern (hub-mediated).
2. **External wallet linking** — Phantom mobile or WalletConnect-Mobile? Not needed for Phase 1–9 (in-app AppKey + Keychain). Revisit when users start asking to manage external custody.
3. **Map provider** — MapKit (Apple, free, native look) vs MapLibre (open, vector tiles). MapKit unless brand cohesion with web (Google Maps) is required.
4. **Module split** — keep `Sources/API`, `Sources/Models` in-app for now; lift to TribeCore when Phase 4.2 of tribe-core-swift ships (CLAUDE.md notes this is planned). Until then, the duplication across tribe-ios and tribe/ is acceptable.

---

## Status notes

- `tribe/` was scaffolded by Xcode (single-file `ContentView`); CLAUDE.md in the parent repo still describes it as the CLI submodule, which is stale. Update the parent's CLAUDE.md when this app starts shipping.
- `tribe-core-swift` Phase 4.1 (crypto) is the only fully-shipped layer; API + Models still live in `tribe-ios` and will move to TribeCore in Phase 4.2 per its MIGRATION.md.

---

## Definition of done (per phase)

- Code compiles (`xcodebuild -scheme Tribe -destination 'platform=iOS Simulator,name=iPhone 15' build`).
- Manual UI walkthrough of the phase's screens hits the golden path without console errors against a local hub (`tribe start`).
- New screens get a SwiftUI `#Preview` so designers can iterate without booting the full app.
- Phase ends with a single squash-merge PR named `Phase N: <summary>`.
