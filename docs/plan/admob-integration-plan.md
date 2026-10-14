# AdMob Integration Plan

**Companions:** `agent-cashbook-feature-spec.md`, `agent-cashbook-technical-design.md`,
`agent-cashbook-sprint-plan.md`, `docs/release/*`
**Status:** Implemented (Phases 0 to 4); Phase 5 device verification pending | **Date:** 2026-10-13
**Scope:** Banner and interstitial ads on every screen where they are safe, shipped from the first
public build. Non-personalized ads only.

---

## 1. Decisions (locked)

| # | Question | Decision |
|---|---|---|
| D1 | Ad formats | **Banner and interstitial** |
| D2 | Paid "remove ads" option | **None** (no Play Billing work) |
| D3 | Who sees ads | **Everyone**: owner and staff alike |
| D4 | Rollout | **Ads ship in the first public build** (beta tracks use Google test ad units) |
| D5 | Personalization | **No personalized ads at all**: every request is non-personalized |

Consequences that follow from these decisions are carried through the rest of this document.

---

## 2. What this changes in the product

The app was designed and documented as offline-first and "no data leaves the phone". Ads change
three of those promises. They must be updated together with the code:

| Existing commitment | Where it lives | Change |
|---|---|---|
| Release APK requests no `INTERNET` permission | `docs/release/privacy-policy.md`, release checklist | Add `INTERNET` and `ACCESS_NETWORK_STATE`; the app now makes network requests (ads only) |
| "No SDK sends data", Data safety = "no data collected or shared" | `docs/release/data-safety.md` | Declare the data the AdMob SDK collects; financial records stay "not collected" |
| Entry in about 5 seconds, 48 dp+ targets, no accidental taps | Feature spec section 1.3 and 8 | No ad on any screen with money input (section 4) |
| Cold start under 2 s on 2 to 3 GB phones | Tech design section 11 | SDK initialises after the first frame, never on the critical path |

The records themselves (transactions, balances, customers, staff) are **never** passed to the ad
SDK or placed in an ad request. Ad requests carry no keywords, no content URL and no user data.

---

## 3. Ad configuration

### 3.1 Non-personalized only (D5)

- Every `AdRequest` sets `nonPersonalizedAds: true`.
- Content rating cap: `maxAdContentRating = G`; do not set any user-interest targeting.
- Keep the Google User Messaging Platform (UMP) consent flow. It only shows a form where law
  requires it (for example EEA/UK users of a globally distributed app), and the "Ad privacy
  options" entry stays available in Settings. Because requests are non-personalized regardless of
  the answer, the answer never switches personalization on.
- Advertising ID: decide at implementation time between
  1. **Remove** `com.google.android.gms.permission.AD_ID` from the merged manifest
     (`tools:node="remove"`). Simplest privacy story and consistent with "no personalization";
     expect somewhat lower fill and eCPM and weaker invalid-traffic measurement.
  2. **Keep** it. Slightly better ad quality and fraud protection; the data-safety form must then
     declare the advertising ID.

  Recommendation: start with option 1 and measure; revisit only if revenue is clearly hurt.
  Verify the current Google guidance on this permission before release.

### 3.2 Build modes (D4)

| Build | Ad units | Notes |
|---|---|---|
| `dev` flavor | Google **test** app and ad unit IDs | Real ads can never appear in development |
| Internal and closed beta tracks | Google **test** ad units | Beta agents do not click real ads; no invalid-traffic risk |
| First public production build | **Live** ad units | Ads on from day one, per D4 |

Implementation: a build-time switch (`ADS_MODE=test|live` via `--dart-define` and a gradle
property), with live IDs kept out of the repository (CI secrets / `local.properties`). A unit test
asserts that `dev` can never resolve a live ID.

Note that a new AdMob app serves full inventory only after it is published on Google Play and
linked in the AdMob console; plan the console linking as part of the release.

---

## 4. Placement

### 4.1 Banner placement matrix

One anchored adaptive banner, with its height always reserved so content never jumps. It collapses
to zero height when offline or on no fill.

| Screen group | Banner | Mechanism |
|---|---|---|
| The five tabs: Home, History, Close day, Reports, Settings | **Yes** | One banner in `AppShell` above the navigation bar (a single integration point) |
| Dues list and detail, Account ledger, Daily summary, Staff list, Recurring list and due list, Backup, About, Diagnostics, Commission rates, Categories, Low-balance settings | **Yes** | Shared `AdFooter` at the bottom of the screen |
| History transaction detail | **Yes** | `AdFooter` (read-only screen) |
| Entry screens (cash out, cash in, flexiload, float purchase, expense, commission received) | **No** | Keypad and money input; accidental-tap risk |
| Bulk flexiload, balance adjustment, due form, settle sheet, recurring form, staff form | **No** | Money or PIN input |
| Lock and PIN screens, onboarding, passphrase and restore dialogs | **No** | Security and first-run trust |
| Day-close counting and review, shift handover counting and review | **No** | Money counting; must stay uncluttered |
| Keyboard open (any screen) | **Hidden** | Banner is hidden while the keyboard is visible |

A route allow-list in code decides this. A test asserts that every screen in the "No" rows can
never build an ad widget.

### 4.2 Interstitial placement (D1)

Interstitials appear only at **natural breaks** where the agent has just finished something and is
not about to tap money controls.

| Trigger | When |
|---|---|
| T1 | When the agent **leaves the daily summary** after closing a day |
| T2 | After a **shift handover** completes and the screen has returned to Home |

Frequency rules (global, enforced in one controller):

- At most **1 interstitial per 15 minutes** and **3 per day**.
- Never within the first **3 minutes** of a session, and never on app start or resume.
- Never during or immediately after saving an entry, undo, void, edit or any money flow.
- Never while the app is locked.
- An ad that is not preloaded is skipped; the user flow is never delayed or blocked.
- A user back-press or system back during an ad must return to the previous screen without side
  effects.

### 4.3 Staff sessions (D3)

Staff see the same ads as the owner. The same blocked-screen list applies, so staff entry flows are
never covered. Staff shift handover (T2) can trigger an interstitial like any other user.

---

## 5. Technical design

### 5.1 Components

| Component | Responsibility |
|---|---|
| `AdsConfig` | Resolves app ID and ad unit IDs from build mode; test IDs for dev and beta |
| `AdsService` (interface) | `initialize()`, `loadBanner(...)`, `showInterstitial(trigger)`, `openPrivacyOptions()` |
| `NoopAdsService` | Used in tests, when ads are disabled, and on platforms without the SDK |
| `AdMobAdsService` | Wraps `google_mobile_ads`; the only file that imports the SDK |
| `ConsentController` | UMP consent state; gates `initialize()` where consent is required |
| `AdBanner` widget | Anchored adaptive banner, reserved height, collapse on failure, retry with backoff, no refresh faster than 60 s, disposes with the screen |
| `AdFooter` widget | Wraps a screen's bottom area; refuses blocked routes |
| `InterstitialController` | Preloads, applies the frequency rules, exposes `maybeShow(trigger)` |
| `adsServiceProvider` | Riverpod provider; overridden with `NoopAdsService` in widget tests |

All SDK access sits behind `AdsService`, which keeps the domain layer and tests free of the plugin
and lets ads be switched off with one flag.

### 5.2 Startup and performance

- Initialise the SDK after the first frame, and only once the app is unlocked, so it never delays
  cold start or the lock screen.
- Preload one interstitial after initialisation and after each show.
- No ad request while offline; resume attempts when connectivity returns.
- Measure on a 2 to 3 GB device: cold start, memory, history scroll with a banner present.

### 5.3 Android configuration

- Dependency: `google_mobile_ads` (pin the version).
- Manifest: `com.google.android.gms.ads.APPLICATION_ID` meta-data via a manifest placeholder per
  build mode; `INTERNET` and `ACCESS_NETWORK_STATE` permissions; `AD_ID` handled per section 3.1.
- Release hardening: confirm R8 shrinking keeps the SDK working; no WebView debugging in release.
- `dev` flavor keeps the `.dev` application ID suffix and test IDs.

### 5.4 Layout rules

- Reserve the banner height (adaptive, based on width) in layouts that show it, so appearing or
  disappearing ads never shift controls.
- Keep at least 16 dp between the banner and any tappable control above it.
- Text scale 1.5x: the banner area must not push content off screen on 360 dp wide phones.
- The banner has a `Semantics` label ("Advertisement") and is excluded from the focus order of
  money controls.

---

## 6. Privacy, policy and listing changes

Update these documents in the same change set as the code:

| Document | Change |
|---|---|
| `docs/release/privacy-policy.md` | State that ads are shown by Google AdMob, that ads are non-personalized, what the SDK may collect, that business records are never sent to ad networks, and how to open ad privacy options |
| `docs/release/data-safety.md` | Declare the data collected by the ad SDK per Google's current AdMob guidance (verify at submission); records and PINs remain "not collected" |
| `docs/release/store-listing.md` | Mark the app as containing ads; keep the "not a financial service" disclaimer |
| `docs/release/release-checklist.md` | Add: live ad unit IDs set only for the production build; AdMob app linked to the Play listing; test-device list; never click own ads; ad privacy options reachable |
| `README.md` | Document `ADS_MODE`, the blocked-screen rule and the interstitial caps |
| Feature spec | Note the ad policy next to the performance and accessibility requirements |

AdMob console set-up (outside the code):

- Create the app and the ad units (one banner, one interstitial).
- Block sensitive ad categories (gambling, loans, dating, adult, etc.) because customers can see
  the agent's screen.
- Publish `app-ads.txt` on the developer website.
- Enable "Do not deliver personalized ads" style settings where the console offers them.

---

## 7. Implementation plan

Task IDs follow the sprint-plan convention (`AD-xx`) for the board, commits and PRs.

### Phase 0: Preparation (0.5 day + approval time)

| ID | Task | Est. |
|---|---|---|
| AD-01 | Create AdMob account, app, banner and interstitial units; block sensitive categories | 0.5d |
| AD-02 | Decide `AD_ID` option (section 3.1); define `ADS_MODE` build switch and secret handling | 0.25d |

### Phase 1: Foundation (1 day)

| ID | Task | Est. | Depends on |
|---|---|---|---|
| AD-03 | Add SDK, manifest placeholders, permissions; flavors resolve test or live IDs; unit test that `dev` cannot resolve live IDs | 0.5d | AD-02 |
| AD-04 | `AdsService`, `NoopAdsService`, `AdMobAdsService`, provider; initialise after first frame and after unlock | 0.5d | AD-03 |
| AD-05 | UMP consent flow and "Ad privacy options" entry in Settings > About | 0.5d | AD-04 |

### Phase 2: Banners (1.5 days)

| ID | Task | Est. | Depends on |
|---|---|---|---|
| AD-06 | `AdBanner` (adaptive, reserved height, collapse and retry, 60 s refresh floor, hide with keyboard) | 0.5d | AD-04 |
| AD-07 | Integrate in `AppShell` for the five tabs | 0.25d | AD-06 |
| AD-08 | `AdFooter` and route allow-list; add to the allowed pushed screens | 0.5d | AD-06 |
| AD-09 | Test: blocked screens never build an ad widget; 1.5x text scale layout tests | 0.25d | AD-08 |

### Phase 3: Interstitials (0.75 day)

| ID | Task | Est. | Depends on |
|---|---|---|---|
| AD-10 | `InterstitialController` with the frequency rules and preloading; unit tests for caps and cool-downs | 0.5d | AD-04 |
| AD-11 | Hook T1 (leaving daily summary after a close) and T2 (after shift handover) | 0.25d | AD-10 |

### Phase 4: Compliance and docs (0.5 day)

| ID | Task | Est. | Depends on |
|---|---|---|---|
| AD-12 | Update privacy policy, data-safety, store listing, release checklist, README (section 6) | 0.5d | AD-05 |

### Phase 5: Verification (1 to 2 days)

| ID | Task | Est. |
|---|---|---|
| AD-13 | Device pass on a 2 to 3 GB phone: cold start, memory, scroll; compare ads on vs off | 0.5d |
| AD-14 | Offline, airplane mode, slow network, no fill: no layout jump, no crash, no blocked flow | 0.25d |
| AD-15 | Staff and owner flows, FLAG_SECURE, TalkBack, FLAG-protected screens, back-press during interstitial | 0.5d |
| AD-16 | AdMob policy checklist walk-through; verify that no ad sits near a money control | 0.25d |

**Total:** about 5 to 6.5 working days, plus AdMob account review and the Play listing link time.

---

## 8. Acceptance criteria

1. Ads appear on all allowed screens (section 4.1) and on none of the blocked ones; enforced by an
   automated test.
2. Every ad request is non-personalized; no records or user identifiers are sent in requests.
3. With no connection, or no fill, no screen shifts or breaks and the user is never blocked.
4. Cold start on the reference 2 to 3 GB device does not regress beyond the existing 2 s target
   plus a measured, documented margin.
5. Interstitials respect the caps in section 4.2 and never appear in or after money flows.
6. `dev` and beta builds can only use test ad units; live units exist only in the production build.
7. Privacy policy, data-safety form and store listing match actual behaviour before submission.

---

## 9. Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Accidental taps on ads near controls | Invalid traffic, account suspension, unhappy agents | Blocked-screen list, reserved space, 16 dp gap, hidden with keyboard, test enforcement |
| Ads degrade the 5-second entry promise | Core value damaged | No ads in entry flows; interstitials only at breaks; caps |
| Ad content inappropriate in a shop with customers watching | Trust and brand damage | Console category blocking, G rating cap |
| Low revenue (small shops, non-personalized, low-income market) | Effort not repaid | Keep scope small; measure in AdMob; no revenue assumptions in planning |
| Policy mismatch between listing and behaviour | Play rejection or removal | Section 6 docs updated with the code; checklist item |
| SDK adds startup cost or memory on low-end phones | Performance regression | Init after first frame and unlock; device pass AD-13 |
| New AdMob app serves limited inventory until linked to Play | Empty slots at launch | Link app to the Play listing as part of release; layout collapses cleanly |
| `AD_ID` removal reduces fill or fraud signals | Lower eCPM | Start without it, measure, revisit |

---

## 10. Out of scope

- Paid ad removal or any in-app purchase (D2).
- Personalized ads, remarketing, user-interest targeting (D5).
- Rewarded video, native or app-open ad formats.
- Mediation networks.
- Ad-related remote configuration or A/B tests.

---

## 11. Implementation status

| Phase | State |
|---|---|
| 0 Preparation | **Done.** AdMob app "Agent Khata" (Android) with banner and interstitial units created; all 11 sensitive categories blocked at app level; app-level ad content rating set to G (the console estimates a large revenue impact for G; the SDK request cap is also G). Live IDs live in git-ignored `ads.live.env` and in GitHub Actions secrets `ADMOB_APP_ID`, `ADMOB_BANNER_ID`, `ADMOB_INTERSTITIAL_ID`. |
| 1 Foundation | **Done.** `google_mobile_ads`, manifest, `AdsConfig` (test vs live), `AdsService`, UMP consent, AD_ID permission removed. |
| 2 Banners | **Done.** `AdBanner` in `AppShell` (5 tabs) and `AdFooter` on read-only pushed screens; blocked-screen test. |
| 3 Interstitials | **Done.** `InterstitialPolicy` (15 min gap, 3 per day, 3 min warm-up), triggers on leaving the daily summary after a close and after a shift handover. |
| 4 Compliance docs | **Done.** Privacy policy, data safety, listing, release checklist, README updated. |
| 5 Verification | **Pending.** Device pass (cold start, memory, offline, TalkBack), AdMob policy walk-through. |

Still to do outside the code:

- Publish the app on Google Play and add the store to the AdMob app so it
  leaves "Limited ad serving" (AdMob shows "Requires review").
- `app-ads.txt` needs a developer website URL (not available yet).
- Optional: a GDPR/EEA consent message under AdMob "Privacy & messaging".
- Build production artifacts only with `tool/build_release.sh` (or the manual
  `Release build (live ads)` workflow); all other builds use test units.
