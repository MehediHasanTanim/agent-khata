# Agent Khata

Offline-first, Bangla-first cash book for bKash / Nagad / Rocket agents and
flexiload retailers in Bangladesh. Android package: `com.nextgenai.agentkhata`.

Specs live in [`docs/`](docs): feature spec, technical design, sprint plan.

## Status

Sprints 0-5 (foundations through backup, hardening and release prep) — see
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

### Sprint 5 (backup, hardening, release prep)

| Task | State |
|---|---|
| S5-01 encrypted `.cbk` backup (AES-256-GCM, Argon2id, authenticated header, share sheet) | done |
| S5-02 restore (checksum, schema check, passphrase, staging DB + integrity check, swap on next start, pre-restore copy kept) | done |
| S5-03 backup UX (last backup, weekly banner, lost-passphrase warning) | done |
| S5-04 migration + round-trip test suite | done |
| S5-05 biometric unlock (on top of the PIN) | done |
| S5-06 settings completion (text size, rollover hour, shop name, categories, about) | done |
| S5-07 performance pass | regression tests + indexes done; **device measurements pending** |
| S5-08 privacy polish (FLAG_SECURE, balance masking, books-verified check) | done |
| S5-09 accessibility / Bangla QA | partial: text-size setting, 48dp+ targets, labels; **TalkBack and native-speaker review pending** |
| S5-10 crash log + opt-in anonymous counts | done locally; Firebase Crashlytics **not wired** (needs your Firebase project) |
| S5-11 release prep | docs in `docs/release/`; release APKs build (arm64 27.5 MB, armv7 24.5 MB, x86_64 29.8 MB, debug-signed without `key.properties`); **signing key, icons, screenshots pending** |

Restore model: the backup is a logical dump (table rows as JSON, gzipped,
encrypted), so it is independent of the device's database key and restores on
a new phone. Restore writes a staging database, verifies it, and the next app
start swaps it in; the previous database is kept as `<db>.pre-restore`.

### Phase 2, first slice

| Backlog item | State |
|---|---|
| Customer dues (baki): give, settle (partial/full), due list, totals, search, call/SMS | done (schema v4; every due and payment is a real ledger transaction) |
| Reports: weekly/monthly summaries, per-type table, net-per-day chart | done |
| CSV export (UTF-8 + BOM, opens in Excel), account statement PDF | done (statement is drawn with the phone's own fonts so Bangla renders) |
| Commission received vs expected (per provider) + "record commission received" | done |
| Variance history chart | done |
| Staff accounts with separate PINs, roles, hidden profit | done (schema v5) |
| Shift-based reconciliation (handover counts, per-operator variance) | done |
| Repeat-customer shortcuts (regulars on Home and in entry screens), bulk flexiload entry (rows or pasted list, all-or-nothing, one-tap undo) | done |
| Printable paper-style daily sheet (cash ledger, wallets, summary, signature lines; print or PDF) | done |
| Insights: average entry size, busiest and most profitable hour, best weekday | done |
| Tiered commission (amount bands, each with per-thousand / percent / fixed) | done |
| Recurring expenses (monthly/weekly reminders; the agent confirms each one) | done (schema v6) |
| Cloud backup (OTP login), multi-device sync, SMS assist, iOS | not started: need decisions (see notes) |

### Staff and shifts

- **Users:** the owner keeps the PIN set at first run (secure storage). Staff
  have their own PIN (salted hash in `app_user`), chosen by the owner under
  Settings > Staff. When staff exist the lock screen asks who is signing in.
  All users share one failed-attempt counter and lockout.
- **Permissions** (`core/security/roles.dart`): owner can do everything. Staff
  can add entries, and see and void/edit only their own entries. Per staff
  member the owner can allow "see profit and reports" and "close the day".
  Reopening a day, manual adjustments, rates, settings, backup and staff
  management are owner-only. Checks live in the services (void/edit, day
  close and reopen, adjustments, rates, staff) as well as the UI.
- **Biometrics** unlock the owner only and are switched off while staff
  accounts exist, because any enrolled fingerprint would open the owner's
  session.
- **Shifts:** the first entry opens a shift for its author; entries are tagged
  with it. "Hand over" counts the drawer and wallets, posts any difference as
  an adjustment against that shift (reason required beyond the tolerance), and
  the next entry opens a new shift. Closing the day ends the open shift using
  the day-close counts. Reports > "Differences by operator" totals shortages
  per person.

Regulars and bulk flexiload: "regulars" are numbers the agent typed on at
least two active entries (cash out, cash in or flexiload), most used first,
with the last amount and wallet/operator. They appear only when "Remember
customers" is on, and staff see only the numbers they served. Bulk flexiload
posts one ordinary flexiload entry per row inside a single database
transaction, so either every load is saved or none; the undo snackbar voids the
whole batch.

Tiered commission: a rule can be "By amount (tiers)". Each tier has an upper
bound (inclusive) and its own per-thousand, percent or fixed rate; the last
tier is open-ended. The tier that contains the transaction amount applies to
the whole amount (bands, not marginal slices). Tiers are stored in
`commission_rule.tiers_json`, effective-dated like any rate, and validated
(ascending, last open).

Recurring expenses: monthly (day 1-31, clamped to the month's last day) or
weekly (a weekday). Nothing is posted automatically. When a date arrives the
owner sees a banner (and a 09:00 notification) and taps Record, which creates
an ordinary expense entry and moves to the next date, or Skip. Several missed
periods are cleared one confirmation at a time. A closed business day refuses
the record and leaves the schedule unchanged.

Variance patterns (Reports tab): the day-close difference chart can be
filtered to one account and carries date labels; below it, a per-account
list (shortage, excess, days with a difference over the last 30 closed
days) and a "differences by weekday" chart over the last 90 closed days with
a one-line "short most often on ..." finding.

Daily sheet and insights: from a day's summary, "Print sheet" renders the
cash drawer as a ruled ledger (time, particulars, in, out, balance, with
opening and closing rows and voided lines struck through), then the wallet
and operator balances, the day summary and Prepared by / Checked by lines.
Pages are drawn with the phone's own fonts (so Bangla prints) and sent to
the system print dialog or shared as a PDF. Commission and profit rows
appear only for users allowed to see profit. Insights (Reports tab) use
customer entries only (cash in/out, flexiload, send money, bill pay), hours
in Dhaka clock time and weekdays by business day.

How dues are modelled: two hidden accounts, receivable (positive) and
payable (negative, a liability). Credit given moves value from cash/wallet/load
into receivable; a payment moves it back. Money held for a customer moves
into payable. Because these are ordinary postings, day close, backups and the
integrity check cover them automatically. Commission received posts
wallet +X against the external account, so credits no longer show up as an
unexplained wallet surplus at day close.

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
