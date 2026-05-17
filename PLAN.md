# Tribe iOS — Port of tribeapp.wtf

Native SwiftUI iOS app that ports the full feature set of the `tribeapp.wtf` web client (Next.js) into the `tribe/` submodule. Reuses `tribe-core-swift` (crypto) and lifts models/API/state patterns from `tribe-ios` (the existing Twitter-shaped client).

## Status

All ten phases shipped. App boots, onboards (connect + city), runs the full shell, and exercises every feature surface (home feed, tribes, explore, map, chat, profile, wallet, notifications, create). Polish — settlement badges, ER follow status, image cache, pagination, toasts, empty states — is in.

Next priorities live in **[What's next](#whats-next)** below.

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
- [x] Replace `Tribe.xcodeproj` with `Project.yml` + xcodegen. Add Makefile-or-shell entry to regen. (`Project.yml` + `Makefile`; pbxproj kept committed so fresh clones open without xcodegen.)
- [x] Add `tribe-core-swift` as local SPM dependency.
- [x] Move existing files into `Sources/` layout. `TribeApp.swift` stays in `Tribe/` (app target entry).
- [x] Create empty `Theme/`, `Models/`, `API/`, `State/`, `Views/` dirs with index .swift files.
- [x] Confirm `xcodegen generate && xcodebuild -scheme Tribe build` succeeds.

### Phase 2 — Foundation: models, API, state
- [x] Copy all 13 model files from `tribe-ios/Sources/Models/` → `tribe/Sources/Models/` (12 shipped + `Karma.swift` added).
- [x] Copy all 5 API files from `tribe-ios/Sources/API/` → `tribe/Sources/API/` (plus `HubRealtime.swift`, `SolanaRPCClient.swift`).
- [x] Copy and adapt `AppState`: 4-case `Phase` enum (`.unloaded`, `.connect`, `.city`, `.ready`), `currentCity`, `joinedChannels`.
- [x] Copy 3 caches (`InteractionCache`, `OnchainTipStatsCache`, `UserAvatarCache`) — rewired to new AppState.
- [x] Build `Theme/` (colors from Assets.xcassets + Swift `Theme` namespace).
- [x] App builds; AppState init from Keychain works; can hit a localhost hub and decode `/v1/feed`.

### Phase 3 — Onboarding (connect + city)
- [x] Connect screen: in-app keypair flow (generate via `CreateAppKeyView` / restore via `SeedPhraseConnectView` + `ImportIdentityView`).
- [x] Generate/load `AppKey` and `DMKey` via TribeCore Keychain.
- [x] Publish initial profile + register DM key (`HubClient.Publish.registerDMKey()`).
- [x] City picker: load city channels via `Endpoints.fetchChannels()` filtered to `kind=2`. Static fallback via `CityCatalog`.
- [x] Persist `currentCity` (UserDefaults) + hydrate AppState on app launch.
- [x] Phase transitions: `.unloaded → .connect → .city → .ready`.

### Phase 4 — Shell (bottom-nav pill + tab containers)
- [x] Build `BottomPillNav` view: 6 tabs around a center +Create button. Active-tab styling matches web (white pill on dark bg).
- [x] `RootShellView` switches on selected tab. Each tab gets a placeholder view (then real views as phases landed).
- [x] City switcher overlay ("Traveling… Syncing local pulse" spinner) via `CitySwitchOverlay` + `CitySwitcherSheet`.
- [x] Common `AppHeader` (sticky title + optional back + optional right actions).

### Phase 5 — Home feed (mixed)
- [x] Build 5 cards: Tweet, Event, Poll, Task, Crowdfund. Match web's rounded-card aesthetic.
- [x] Mixed feed view interleaves them (2 tweets → 1 event/poll/task/crowdfund → repeat) via `HomeFeedItemsView`.
- [x] Use `Endpoints.fetchChannelFeed()` for current city's tweets.
- [x] Wire reactions (`likeTweet`/`unlikeTweet`/`bookmark`/`retweet`) via `InteractionCache`.
- [x] Poll/event/task/crowdfund: hub data, on-chain queries deferred to Phase 10 polish (settled via `HubSettlementBadge`).
- [x] Real-time: connect to `/v1/ws` (via `HubRealtime`) and merge new tweets at top.

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

## What's next

Phases 1–10 landed the feature surface. The list below is what stands between "works on dev hub" and "shippable beta." Roughly ordered by leverage; nothing here is started.

### Production readiness
- [ ] **Tests**. No `Tests/` target yet. Start with model decode (`HubDecode`, all 12 model types' JSON fixtures), then `MessageSigner` envelope round-trip, then a couple of `HomeFeedStore` async paths. Wire to scheme so `make test` works.
- [ ] **App icon + launch screen**. Currently default Xcode placeholder. Ship marks before TestFlight.
- [ ] **Info.plist permission strings** — verify usage descriptions for Photos (compose), Location (map / city), Camera if image capture is added. Missing strings = App Store rejection.
- [ ] **Crash + analytics hookup**. Light-touch (Sentry or os_log + Console export) so beta crashes are debuggable.
- [ ] **TestFlight pipeline**. Marketing/build version bumps, App Store Connect record, signing certs, screenshots.

### Deferred features (from initial non-goals)
- [ ] **Single-tweet thread detail screen**. Web doesn't have one either, but iOS users expect a tap-into-thread surface. Reuse `TweetCardView` + a replies list scoped to the parent envelope id.
- [ ] **On-chain settlement directly from device** (Solana.swift). Today events/polls/tasks/crowdfunds rely on hub-mediated settlement (matches tribe-ios). Direct Anchor submission would close the trust loop for power users.
- [ ] **External wallet linking** (Phantom mobile deeplink or WalletConnect). Lets users custody outside the app's Keychain.
- [ ] **Places / reviews data plane**. Map currently shows event pins + dummy place/review cards. Needs a real `places` envelope type on the hub before we can populate.
- [ ] **Tribe slug-conflict UX**. Compose-time check + suggestion list when a slug is taken.

### Module hygiene
- [ ] **Lift API + Models to TribeCore (Phase 4.2 of tribe-core-swift)**. Currently duplicated between `tribe-ios/Sources/` and `tribe/Sources/`. Blocked on `tribe-core-swift` shipping the API layer.
- [ ] **Parent repo CLAUDE.md** — entry for `tribe/` still describes it as the CLI submodule. Update to "Native SwiftUI iOS app — hyperlocal flavor; port of tribeapp.wtf."
- [ ] **README.md in `tribe/`** — once an icon and screenshots exist, mirror `tribe-ios` README structure (screenshots grid + quickstart).

### Polish backlog
- [ ] Skeleton loaders on cold feed (current empty-state is text-only).
- [ ] Pull-to-refresh haptics on `HomeFeedView`.
- [ ] Notification deep-linking (tap a follow → profile, tap a reaction → tweet).
- [ ] Background WS reconnection on app foreground.
- [ ] Push notifications (APNs) once a hub endpoint exists.

---

## Open decisions

1. **On-chain client library on iOS** — tribe-ios doesn't yet write to Solana programs directly (envelopes go through hub; on-chain settlement is hub-mediated). For events/polls/tasks/crowdfunds, do we (a) wait for hub-mediated settlement (lowest effort, matches current iOS), or (b) use `Solana.swift` to sign + submit Anchor instructions client-side? Decision punted to Phase 10; for now follow tribe-ios pattern (hub-mediated).
2. **External wallet linking** — Phantom mobile or WalletConnect-Mobile? Not needed for Phase 1–9 (in-app AppKey + Keychain). Revisit when users start asking to manage external custody.
3. **Map provider** — MapKit (Apple, free, native look) vs MapLibre (open, vector tiles). MapKit unless brand cohesion with web (Google Maps) is required.
4. **Module split** — keep `Sources/API`, `Sources/Models` in-app for now; lift to TribeCore when Phase 4.2 of tribe-core-swift ships (CLAUDE.md notes this is planned). Until then, the duplication across tribe-ios and tribe/ is acceptable.

---

## Status notes

- Parent `CLAUDE.md` still describes the `tribe/` submodule as a CLI — stale. Update when this app cuts its first beta build (tracked in [What's next](#whats-next)).
- `tribe-core-swift` Phase 4.1 (crypto) remains the only shipped layer. API + Models still duplicated between `tribe-ios` and `tribe/`; will collapse onto TribeCore once 4.2 ships per its `MIGRATION.md`.
- `Tribe.xcodeproj` is committed alongside `Project.yml`. Source of truth is the YAML — re-run `make generate` after edits. Generated pbxproj is kept so cloners without xcodegen can still open in Xcode (matches `.gitignore` comment).

---

## Definition of done (per phase)

- Code compiles (`xcodebuild -scheme Tribe -destination 'platform=iOS Simulator,name=iPhone 15' build`).
- Manual UI walkthrough of the phase's screens hits the golden path without console errors against a local hub (`tribe start`).
- New screens get a SwiftUI `#Preview` so designers can iterate without booting the full app.
- Phase ends with a single squash-merge PR named `Phase N: <summary>`.
