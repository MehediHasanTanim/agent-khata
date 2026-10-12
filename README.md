# Agent Khata

Offline-first, Bangla-first cash book for bKash / Nagad / Rocket agents and
flexiload retailers in Bangladesh. Android package: `com.nextgenai.agentkhata`.

Specs live in [`docs/`](docs): feature spec, technical design, sprint plan.

## Status

Sprints 0-4 (foundations, ledger core, onboarding/home/entry, history/edit/flexiload/ledgers, day close) — see
`docs/plan/agent-cashbook-sprint-plan.md`.

| Task | State |
|---|---|
| S0-01 project, flavors, lints, structure | done |
| S0-02 CI (`.github/workflows/ci.yml`) | done |
| S0-03 Drift + SQLCipher, key in Keystore, WAL, empty schema v1 | done |
| S0-04 SQLCipher feasibility check | tooling done; **measure on a device** (see below) |
| S0-05 `Money` | done |
| S0-06 i18n (bn/en, digits, grouping) | done; Bangla font not bundled yet (see below) |
| S0-07 theme + tokens | done |
| S0-08 PIN lock | done |

### Sprint 1 (ledger core)

| Task | State |
|---|---|
| S1-01 schema (v2: all design tables + indexes) | done |
| S1-02 integrity triggers (no delete, immutable columns, closed-day lock) | done |
| S1-03 entities, UUIDv7, Dhaka business date with rollover hour | done |
| S1-04 account repository, live/reactive balances, recompute check | done |
| S1-05 posting framework + registry, atomic write | done |
| S1-06/07 all 10 posting strategies | done |
| S1-08 commission engine | done |
| S1-09 audit logger | done |
| S1-10 invariant + randomized tests | done |
| S1-11 dev-only debug harness (Settings, dev flavor) | done |

Posting model: every transaction posts entries that sum to zero across
accounts including the hidden `external` account (customer fees, flexiload
margin, adjustments) and expense-category accounts. Provider commission on
cash-out/cash-in is recorded on the transaction but not posted (it is credited
later; reconciled in Phase 2). Flexiload: `amount` is the price charged, the
load balance falls by `amount - margin`.

### Sprint 2 (onboarding, home, fast entry)

| Task | State |
|---|---|
| S2-01 onboarding (language, wallets/operators, balances, rates, shop; quick start) | done |
| S2-02 commission setup + effective-dated rate editing (Settings > Commission rates) | done |
| S2-03 home balance cards (low highlight, tap-to-reveal masking) | done |
| S2-04 custom keypad (000, backspace, chips, Bangla digits) | done |
| S2-05 cash-out / cash-in entry with live commission | done |
| S2-06 undo snackbar + last 5 entries | done |
| S2-07 learned quick-amount chips + repeat last | done |
| S2-08 entry guards (negative source, large amount, duplicate) | done |
| S2-09 float purchase entry | done |
| S2-10 expense entry with category chips + custom category | done |
| S2-11 navigation shell (History, Close day, Reports are placeholders) | done |

Not yet: flexiload entry (S3-01), account ledger on card tap (S3-08),
low-balance thresholds UI (S3-10). The business-day "today" totals use the
rollover hour (default 4) and are computed when the home screen builds.

### Sprint 3 (history, edit/void, flexiload, ledgers)

| Task | State |
|---|---|
| S3-01 flexiload entry (operator, price, live margin) | done |
| S3-02 load purchase (float purchase to a load account, optional amount paid -> charge/discount) | done |
| S3-03 history list (day groups, type icons+text, keyset paging, Today/Yesterday/Week/Month/All) | done |
| S3-04 search (amount, number, name, note, TrxID) + type/account/date filters | done |
| S3-05 transaction detail (commission snapshot, accounts, audit trail, lineage) | done |
| S3-06 void with required reason | done |
| S3-07 edit = new txn + void original, atomic | done |
| S3-08 account ledger (running balance, range filter, paper-style columns) | done |
| S3-09 manual balance adjustment with mandatory reason | done |
| S3-10 low-balance thresholds + home banner | done (local notification deferred to S4-10 with reminders) |
| S3-11 customer quick-fill (opt-in, stored only on device) | done |
| S3-12 expense list = History filtered to Expense, with totals | done |

### Sprint 4 (day close and reconciliation)

| Task | State |
|---|---|
| S4-01 expected balances per account for a business date | done |
| S4-02 gap heuristics (same amount, flipped, double/half, duplicates, digit swap, cross-account) | done; "unrecorded known items" deferred |
| S4-03 counting step + cash denomination counter | done |
| S4-04 variance, ranked top-3 hints, add-missing-entry, tolerance | done |
| S4-05 adjustment on close with reason code | done |
| S4-06 atomic, idempotent close; locks the day; writes snapshots | done |
| S4-07 lock enforcement + owner reopen (latest closed day only, reason, audit) | done |
| S4-08 daily summary + share as image / PDF | done |
| S4-09 balance snapshots (live balance = snapshot + later entries, verified by integrity check) | done |
| S4-10 close-day reminder (local notification) + "yesterday not closed" banner; low-balance notification | done |

Close and reopen: a reopen voids the close adjustments; closing again
recomputes them from the new counts, so close, reopen and re-close with the
same counts gives identical balances (covered by tests). Reopening is
limited to the most recent closed day. There is a single owner for now, so
"owner-only" is not yet enforced by roles (Phase 2 staff accounts).

## Develop

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift
flutter gen-l10n                                           # ARB -> lib/l10n/gen
flutter run --flavor dev -t lib/main_dev.dart
flutter test
```

Flavors: `dev` (`com.nextgenai.agentkhata.dev`, "Khata Dev") and `prod`
(`com.nextgenai.agentkhata`).

Release signing: put `storeFile`, `storePassword`, `keyAlias`, `keyPassword`
in `android/key.properties` (git-ignored). Without it release builds use the
debug key.

## S0-04 decision gate: SQLCipher

SQLCipher comes from the `sqlite3` package's build hook
(`hooks.user_defines.sqlite3.source: sqlcipher` in `pubspec.yaml`); the old
`sqlcipher_flutter_libs` is end-of-life. On a 2-3 GB phone, open
Settings -> Diagnostics and record: encryption status, cold-start-to-first-frame,
the 1,000-insert write time, and the APK size delta of
`flutter build apk --release --flavor prod --split-per-abi` with
`source: sqlcipher` vs `source: sqlite3`. If it is too heavy, switch `source`
to `sqlite3` and rely on the app lock plus encrypted backups.

Decision: _pending device measurements_.

## Notes

- `android:allowBackup` is off: the DB key lives in the Android Keystore, so
  an auto-restored database file could never be decrypted.
- Bangla font: bundle Noto Sans Bengali (or Hind Siliguri) under
  `assets/fonts/` and declare it in `pubspec.yaml` (S0-06). The theme already
  lists both as fallbacks.
- Domain/DB tests can run without Xcode in a plain Dart package using
  `source: system` for sqlite3; CI runs the full `flutter test`.
- Local `flutter test` on macOS needs the Xcode command line tools
  (`xcode-select --install`); some native-asset hooks call `xcrun`.
