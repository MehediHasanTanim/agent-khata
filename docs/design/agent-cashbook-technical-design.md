# Agent Cash Book: Technical Design

**Companion to:** `agent-cashbook-feature-spec.md`
**Status:** Draft v0.1 | **Date:** 2026-10-10
**Scope:** MVP (Phase 1, P0) in detail, with extension points for Phase 2 and 3.

---

## 1. Design Goals and Constraints

| # | Goal | Consequence for design |
|---|---|---|
| 1 | Save a transaction in under 300 ms; the whole flow in about 5 s | Local DB writes only on the hot path; no network calls |
| 2 | 100% offline core | Offline-first architecture; the cloud is optional backup/sync |
| 3 | Balances must never be wrong | Append-only ledger; balances are derived and verifiable |
| 4 | Runs on low-end Android (2-3 GB RAM, Android 8+) | Small APK, lazy loading, indexed queries, minimal background work |
| 5 | Non-technical, Bangla-first users | i18n from day one, Bangla digits, large-text support |
| 6 | Trust and auditability (staff, disputes) | Audit log, void-not-delete, closed-day locking |
| 7 | Solo or small team build | Proven, boring tech; few moving parts |

---

## 2. Technology Stack

### 2.1 Mobile app
| Concern | Choice | Why |
|---|---|---|
| Framework | **Flutter (Dart)**, Android first | Single codebase, good low-end performance, strong Bangla text rendering, iOS possible later |
| State management | **Riverpod** | Testable, compile-safe, works well with streams from the DB |
| Local database | **SQLite via Drift** | Typed queries, migrations, reactive streams, transactions |
| DB encryption | **SQLCipher** (`sqlcipher_flutter_libs`) | Encrypts data at rest, key held in the Android Keystore |
| Secure storage | `flutter_secure_storage` | PIN hash, DB key, backup key |
| Biometrics | `local_auth` | Fingerprint unlock |
| i18n | `flutter_localizations` + ARB files | Bangla and English, with a number/digit formatter |
| PDF / share | `pdf` + `printing` + `share_plus` | Daily summary and report export, WhatsApp share |
| Notifications | `flutter_local_notifications` + `workmanager` | Reminders (day close, low float) with no server |
| Crash / analytics | Firebase Crashlytics (opt-in analytics) | Crash-free rate target is 99.5% |

### 2.2 Backend (Phase 2, optional)
Only for **cloud backup, restore, and later multi-device sync**. The app must never depend on it.

| Concern | Choice |
|---|---|
| API | **Django + Django REST Framework** (or FastAPI if preferred) |
| Auth | Phone number + OTP (SMS gateway), JWT access and refresh tokens |
| DB | PostgreSQL |
| Blob storage | S3-compatible bucket for encrypted backup files |
| Hosting | Single small VPS or managed container; low traffic |

> **MVP decision:** Phase 1 ships with **no backend**, only encrypted file backup/restore (Section 9). This removes OTP cost, hosting, and a privacy surface from the first release.

---

## 3. High-Level Architecture

```
┌──────────────────────────── Flutter App ────────────────────────────┐
│                                                                     │
│  Presentation        Application            Domain          Data    │
│  (Widgets/Screens) → (Riverpod providers, → (Entities,    → (Drift  │
│                       use cases)             rules, calc)    repos, │
│                                                              DAOs)  │
│                                                                     │
│   Cross-cutting: Auth/PIN · i18n · Audit · Backup · Notifications   │
└───────────────┬─────────────────────────────────────┬───────────────┘
                │                                     │
        SQLCipher SQLite DB                  (Phase 2) Sync client
        (single source of truth)                      │
                                              ┌───────▼────────┐
                                              │  REST backend  │
                                              │  + Postgres/S3 │
                                              └────────────────┘
```

### 3.1 Layering rules
- **Presentation** only talks to the **Application** layer (providers or controllers).
- **Domain** is pure Dart: entities, value objects (`Money`), the commission engine, the reconciliation engine, and validators. It has no Flutter or DB imports, which makes it fully unit-testable.
- **Data** implements repository interfaces defined in the domain, using Drift DAOs.
- **Single source of truth is the local DB.** The UI observes DB streams; it does not cache balances in memory.

### 3.2 Suggested project structure
```
lib/
  core/
    money/            # Money value object, formatting, digit localization
    db/               # Drift database, migrations, DAOs, encryption setup
    security/         # PIN, biometrics, keystore, lock controller
    i18n/             # ARB files, digit mapper
    audit/            # audit logger
    utils/
  features/
    onboarding/
    accounts/
    transactions/     # entry, history, search, edit/void
    flexiload/
    commission/       # rule engine + settings
    reconciliation/   # day close engine + UI
    expenses/
    dues/             # Phase 2
    reports/
    backup/
    settings/
  app.dart
  main.dart
test/
  domain/ data/ integration/
```

---

## 4. Core Domain Design

### 4.1 Money handling
- Store all amounts as **integer minor units (paisa)** in a 64-bit integer. Never use floating point.
- UI shows whole taka by default and supports paisa where needed.
- A `Money` value object enforces the currency (BDT), arithmetic, and formatting, including Bangla digits.
- Commission calculation uses integer math with explicit rounding rules (see 4.4).

### 4.2 Ledger model: double-entry
Each transaction posts **balanced entries** between accounts. This makes balances mathematically verifiable and makes reconciliation reliable.

- Every business event creates one `transaction` row plus **two or more `ledger_entry` rows** (debit and credit) that sum to zero.
- Account balance = opening balance + Σ(credits) − Σ(debits), excluding voided transactions.
- A hidden **"External / Customer"** account balances the entries (money entering or leaving the agent's world).

Examples (agent perspective; amounts in taka):

| Event | Entries |
|---|---|
| Cash-in ৳1,000 via bKash | Cash **+1,000**; bKash float **−1,000**; Customer/External net **0** |
| Cash-out ৳2,000 via bKash | Cash **−2,000**; bKash float **+2,000** |
| Flexiload sale ৳100 (cost ৳97) | Cash **+100**; GP load balance **−97**; margin ৳3 in the commission report |
| Float purchase ৳50,000 with cash | Cash **−50,000**; bKash float **+50,000** |
| Expense ৳350 | Cash **−350**; Expense category **+350** |

> **Pragmatic simplification:** The user never sees debits and credits. The domain layer maps each transaction type to its ledger postings through a **PostingStrategy** per type (Section 4.3). The UI speaks in plain terms (cash-in, cash-out).

### 4.3 Posting strategies
```dart
abstract class PostingStrategy {
  TransactionType get type;
  List<LedgerEntry> post(TransactionDraft draft, AccountResolver accounts);
  void validate(TransactionDraft draft); // required fields, positive amount, etc.
}
```
Implementations: `CashInStrategy`, `CashOutStrategy`, `SendMoneyStrategy`, `BillPayStrategy`, `FlexiloadStrategy`, `FloatPurchaseStrategy`, `FloatTransferStrategy`, `BankDepositStrategy`, `ExpenseStrategy`, `AdjustmentStrategy`.

A registry maps `TransactionType` to its strategy, so adding a new type later means adding a class and registering it. This is covered by golden tests.

### 4.4 Commission engine
Inputs: provider, transaction type, amount, timestamp. Output: commission in paisa plus a snapshot of the rule used.

```dart
class CommissionRule {
  String provider;          // 'bkash', 'nagad', 'gp', ...
  TransactionType txnType;
  CommissionMode mode;      // perThousand | percent | fixed | tiered
  int valuePaisa;           // or basis points for percent
  DateTime effectiveFrom;
  DateTime? effectiveTo;
}
```
- **Rule selection:** the rule for the provider and type whose effective range contains the transaction time. If several match, the latest `effectiveFrom` wins.
- **Rounding:** round half-up to the nearest paisa, documented and unit-tested.
- **Snapshot:** the transaction stores `commission_paisa` and `commission_rule_id`, so later rate edits never change history.
- **Manual override:** `commission_overridden = true` with the user-entered value.
- **Tiered mode** (P1) supports amount bands if providers use them.
- **Defaults:** shipped as editable seed data, not as authoritative constants, and confirmed by the user at onboarding.

### 4.5 Reconciliation engine
Pure domain service.

```dart
class ReconciliationResult {
  Map<AccountId, Money> expected;
  Map<AccountId, Money> actual;
  Map<AccountId, Money> variance;     // actual − expected
  List<Suggestion> suggestions;       // ranked "find the gap" hints
}
```

**Expected balance** for account A at close time T is the ledger-derived balance: opening + all non-void postings up to T. This is the same formula as the live balance, which keeps the two consistent.

**Gap-finding heuristics** (run only when variance ≠ 0, within a bounded set such as today's transactions per account):
1. **Exact match:** a transaction whose amount equals |variance| ("recorded twice" if the variance is the opposite sign, "missing" if the same sign).
2. **Double/half:** an amount equal to 2×|variance| or |variance|/2 (a direction error: cash-in recorded as cash-out flips the effect by 2×).
3. **Swap error:** a transaction where the cash and float effects are equal and opposite, suggesting a flipped direction.
4. **Duplicates:** identical amount, account, and customer within a short window.
5. **Digit transposition:** the difference between two amounts is divisible by 9 (for example 540 vs 450), among today's transactions for that account.
6. **Unrecorded known items:** expected commission credits, charges, or fees for that account.

Each suggestion carries a **confidence score** and a human-readable Bangla/English explanation, and the UI shows the top 3 candidates.

### 4.6 Day close and locking
- `day_close` row: date, per-account expected, actual, variance, notes, closed_by, closed_at, status.
- On close, the day's transactions are marked **locked** (`day_close_id` set).
- Editing, voiding, or adding transactions dated within a closed day requires **reopen** (owner-only, with a reason), logged in the audit trail.
- The next day's **opening balance** equals this day's **actual** balance. The difference between expected and actual is posted as an **Adjustment** on the closed day, so the ledger always agrees with reality.
- Closing is **idempotent and transactional**: all postings and the status change commit in one DB transaction.

---

## 5. Data Model (SQLite / Drift)

All IDs are **UUIDv7** (time-ordered) generated on device, which prevents collisions in future sync. Timestamps are stored as UTC epoch milliseconds, with the display timezone fixed to Asia/Dhaka by default.

```sql
-- Accounts (cash, wallets, SIM load balances, bank, internal)
CREATE TABLE account (
  id              TEXT PRIMARY KEY,
  kind            TEXT NOT NULL,         -- cash | wallet | load | bank | expense | external
  provider        TEXT,                  -- bkash | nagad | rocket | upay | gp | robi | bl | airtel | teletalk | ...
  label           TEXT NOT NULL,
  number          TEXT,                  -- wallet / SIM number (optional)
  opening_paisa   INTEGER NOT NULL DEFAULT 0,
  low_alert_paisa INTEGER,
  is_active       INTEGER NOT NULL DEFAULT 1,
  sort_order      INTEGER NOT NULL DEFAULT 0,
  created_at      INTEGER NOT NULL
);

-- Business event
CREATE TABLE txn (
  id                  TEXT PRIMARY KEY,
  type                TEXT NOT NULL,     -- cash_in | cash_out | send_money | bill_pay | flexiload | float_purchase | float_transfer | bank_deposit | expense | adjustment
  occurred_at         INTEGER NOT NULL,  -- when it happened (user-editable, back-dating)
  recorded_at         INTEGER NOT NULL,  -- when it was entered (immutable)
  amount_paisa        INTEGER NOT NULL CHECK (amount_paisa > 0),
  charge_paisa        INTEGER NOT NULL DEFAULT 0,  -- fee collected from customer, if any
  commission_paisa    INTEGER NOT NULL DEFAULT 0,
  commission_rule_id  TEXT,
  commission_overridden INTEGER NOT NULL DEFAULT 0,
  customer_id         TEXT,
  customer_number     TEXT,
  reference           TEXT,              -- TrxID (optional)
  note                TEXT,
  status              TEXT NOT NULL DEFAULT 'active',  -- active | void
  void_reason         TEXT,
  voided_at           INTEGER,
  replaces_txn_id     TEXT,              -- edit lineage
  day_close_id        TEXT,              -- set when locked
  created_by          TEXT NOT NULL,     -- user id (owner/staff)
  shift_id            TEXT,
  device_id           TEXT NOT NULL
);

-- Ledger postings (balanced per txn)
CREATE TABLE ledger_entry (
  id            TEXT PRIMARY KEY,
  txn_id        TEXT NOT NULL REFERENCES txn(id),
  account_id    TEXT NOT NULL REFERENCES account(id),
  delta_paisa   INTEGER NOT NULL,        -- signed effect on the account
  line_no       INTEGER NOT NULL
);

CREATE TABLE commission_rule (
  id             TEXT PRIMARY KEY,
  provider       TEXT NOT NULL,
  txn_type       TEXT NOT NULL,
  mode           TEXT NOT NULL,          -- per_thousand | percent | fixed | tiered
  value          INTEGER NOT NULL,       -- paisa per 1000 / basis points / paisa
  tiers_json     TEXT,
  effective_from INTEGER NOT NULL,
  effective_to   INTEGER
);

CREATE TABLE customer (
  id TEXT PRIMARY KEY, name TEXT, phone TEXT, note TEXT, created_at INTEGER NOT NULL
);

CREATE TABLE day_close (
  id TEXT PRIMARY KEY,
  business_date TEXT NOT NULL UNIQUE,    -- 'YYYY-MM-DD' (Asia/Dhaka)
  status TEXT NOT NULL,                  -- closed | reopened
  note TEXT, closed_by TEXT, closed_at INTEGER, reopened_by TEXT, reopened_at INTEGER, reopen_reason TEXT
);

CREATE TABLE day_close_line (
  day_close_id TEXT NOT NULL REFERENCES day_close(id),
  account_id   TEXT NOT NULL REFERENCES account(id),
  expected_paisa INTEGER NOT NULL,
  actual_paisa   INTEGER NOT NULL,
  variance_paisa INTEGER NOT NULL,
  adjustment_txn_id TEXT,
  PRIMARY KEY (day_close_id, account_id)
);

CREATE TABLE expense_category (id TEXT PRIMARY KEY, name TEXT NOT NULL, is_default INTEGER DEFAULT 0);

CREATE TABLE app_user (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, role TEXT NOT NULL,  -- owner | staff
  pin_hash TEXT, can_see_profit INTEGER DEFAULT 0, is_active INTEGER DEFAULT 1
);

CREATE TABLE audit_log (
  id TEXT PRIMARY KEY,
  at INTEGER NOT NULL,
  user_id TEXT NOT NULL,
  action TEXT NOT NULL,                  -- txn_create | txn_edit | txn_void | day_close | day_reopen | rate_change | adjustment | backup | restore ...
  entity TEXT NOT NULL, entity_id TEXT,
  before_json TEXT, after_json TEXT, reason TEXT
);

CREATE TABLE setting (key TEXT PRIMARY KEY, value TEXT NOT NULL);
```

### 5.1 Indexes
```sql
CREATE INDEX idx_txn_occurred   ON txn(occurred_at DESC);
CREATE INDEX idx_txn_type_day   ON txn(type, occurred_at);
CREATE INDEX idx_txn_status     ON txn(status);
CREATE INDEX idx_txn_customer   ON txn(customer_number);
CREATE INDEX idx_txn_reference  ON txn(reference);
CREATE INDEX idx_le_account     ON ledger_entry(account_id);
CREATE INDEX idx_le_txn         ON ledger_entry(txn_id);
CREATE INDEX idx_audit_entity   ON audit_log(entity, entity_id);
```

### 5.2 Integrity constraints (enforced by app code and DB triggers)
- **Balanced postings:** for each txn (except one-sided internal types such as an expense posting to an expense account), Σ`delta_paisa` = 0. Enforced in the repository inside the same DB transaction, and verified by a trigger or a periodic integrity check.
- **No hard deletes** on `txn`, `ledger_entry`, and `audit_log`; triggers block `DELETE` and block `UPDATE` of immutable columns (`recorded_at`, `amount_paisa` after lock).
- **Locked transactions:** triggers reject changes where `day_close_id IS NOT NULL` unless the day is in `reopened` status.

### 5.3 Balance queries
Live balance of an account:
```sql
SELECT a.opening_paisa + COALESCE(SUM(le.delta_paisa), 0) AS balance
FROM account a
LEFT JOIN ledger_entry le ON le.account_id = a.id
LEFT JOIN txn t ON t.id = le.txn_id AND t.status = 'active'
WHERE a.id = ?
  AND (le.id IS NULL OR t.id IS NOT NULL);
```
**Performance plan:** with the indexes above this is fast for tens of thousands of rows. To keep it O(1) as data grows, maintain a **`balance_snapshot`** table written at each day close (account, date, balance). Live balance = latest snapshot + entries after the snapshot date. The full-recompute query remains as the integrity check.

---

## 6. Key Flows (Technical)

### 6.1 Record a transaction
```
UI keypad → TransactionController.submit(draft)
  1. validate(draft)                         [domain]
  2. check day lock for draft.occurred_at    [repo]
  3. commission = CommissionEngine.compute() [domain]
  4. entries = strategy.post(draft)          [domain]
  5. BEGIN TRANSACTION
       insert txn
       insert ledger_entry rows
       insert audit_log (txn_create)
     COMMIT
  6. DB stream emits → balances/home list update automatically
  7. Post-save warnings (negative balance, large amount, possible duplicate) shown as non-blocking UI
```
- The write is a single local DB transaction, so it is atomic, durable, and typically a few milliseconds.
- **Duplicate guard:** same type, amount, account, and customer number within 2 minutes triggers a confirm prompt (user can override).

### 6.2 Edit and void
- **Void:** set `status='void'`, `voided_at`, `void_reason`; ledger entries remain but are excluded from balances; audit entry stores before/after.
- **Edit:** creates a **new** transaction with `replaces_txn_id` pointing to the old one and voids the original, in one DB transaction. The history stays intact and the audit log records the change.
- Blocked on locked days (owner can reopen the day first).

### 6.3 Day close
```
CloseDayController.start(date)
  → ReconciliationEngine.expected(date)  (from ledger)
  → user enters actual balances (cash helper optional)
  → ReconciliationEngine.analyze() → variance + suggestions
  → user resolves: add missing txn / post adjustment (reason required) / accept
  → CloseDayService.commit():
      BEGIN
        insert day_close + day_close_line
        post adjustment txns for residual variance
        mark txns of that date with day_close_id
        write balance_snapshot per account
        write audit_log (day_close)
      COMMIT
  → schedule next-day reminder
```
**Business date** is derived from `occurred_at` in Asia/Dhaka, with a configurable **day-rollover hour** (for example 4 AM) so late-night transactions count toward the right business day.

---

## 7. Security Design

| Area | Design |
|---|---|
| **Data at rest** | SQLCipher-encrypted DB. A random 256-bit key is generated on first run and stored in the Android Keystore through secure storage. |
| **App lock** | PIN (4-6 digits) stored as a salted hash (Argon2id or PBKDF2 with high iterations). Biometric unlock as a convenience layer. Lock on app background after a configurable timeout. |
| **Brute force** | Incremental lockout after failed PIN attempts (for example 5 attempts, then 30 s, then longer). |
| **Roles** | Owner vs staff, enforced in the application layer (use-case level permission checks) **and** reflected in the UI. |
| **Screen privacy** | Optional balance masking; `FLAG_SECURE` on sensitive screens to block screenshots and the recents preview. |
| **Backups** | Encrypted with a key derived from a user-chosen backup passphrase (see Section 9). The passphrase is never stored; losing it means the backup cannot be restored, and the UI states this clearly. |
| **Network** | None in MVP. Phase 2 uses TLS only, certificate pinning optional. |
| **Privacy** | Customer phone and name are optional fields. No contacts access. No SMS access in MVP. Analytics is opt-in and excludes financial data and phone numbers. |
| **Root / tamper** | Best-effort detection with a warning only; not blocking, since the threat model is casual misuse rather than a determined attacker. |

---

## 8. Localization and UX Technical Notes
- **Strings:** ARB files for `bn` and `en`; all strings externalized from the start.
- **Digits:** a `DigitFormatter` converts between 0-9 and ০-৯ for display. **Input is normalized to ASCII digits internally**, so storage and calculation are unaffected.
- **Number grouping:** Bangladeshi style grouping (for example 1,00,000) as a user option.
- **Fonts:** bundle a Bangla font subset (for example Noto Sans Bengali or Hind Siliguri) to guarantee rendering on old devices; check APK size impact.
- **Custom numeric keypad:** an in-app widget (not the system keyboard) with a "000" key, quick-amount chips, and a backspace, for speed and predictable behavior.
- **Text scaling:** layouts tested at up to 1.5x system font scale.
- **Accessibility:** semantic labels for TalkBack on key buttons and balances.

---

## 9. Backup, Restore and Sync

### 9.1 MVP: Encrypted file backup
- **Format:** a single `.cbk` file containing a SQLite DB dump (or the DB file after a checkpoint) plus a metadata header (schema version, app version, created_at, device_id, checksum), encrypted with AES-256-GCM using a key derived (Argon2id) from the user's backup passphrase.
- **Actions:** *Backup now* writes the file and opens the Android share sheet (Google Drive, WhatsApp, local storage). *Restore* picks a file, validates the checksum and schema version, asks for the passphrase, then replaces the local DB after a confirmation step.
- **Auto-reminder:** nudge weekly (and after day-close) if no backup has been made recently.
- **Safety:** a pre-restore snapshot of the current DB is kept so a bad restore can be undone.

### 9.2 Phase 2: Cloud backup
- Authenticated upload of the same encrypted `.cbk` blob to the backend, with versioning (keep the last N). The server stores ciphertext only (**zero-knowledge** with respect to financial data).

### 9.3 Phase 3: Multi-device sync (design sketch)
- **Append-only event model:** transactions, ledger entries, and audit rows are immutable events with UUIDv7 IDs and `device_id`, so merging is mostly set union.
- **Conflict areas:** account metadata edits and day-close state, resolved by last-writer-wins with owner priority, plus an explicit "day already closed on another device" check.
- **Protocol:** pull and push by a monotonic server cursor; idempotent upserts by ID; retry with backoff; sync is background and never blocks entry.
- This is why IDs are device-generated UUIDs and why history is never mutated in place.

---

## 10. Migrations and Versioning
- Drift schema versioning with **step-by-step migrations** and **migration tests** (old-schema fixture DBs upgraded and checked).
- Backups carry the schema version; restoring an older-schema backup runs migrations before use; restoring a **newer** schema than the app supports is rejected with a clear message.
- Feature flags (local settings) gate Phase 2 and 3 features, so the same codebase can ship incrementally.

---

## 11. Performance Plan

| Concern | Approach |
|---|---|
| Cold start < 2 s | Defer non-critical init, lazy-open features, avoid heavy startup work, use deferred components if needed |
| Long history | Paged queries (`LIMIT/OFFSET` or keyset by `occurred_at, id`), list virtualization |
| Balances | Snapshot-plus-delta (Section 5.3), indexed ledger lookups |
| Search | Indexed columns for amount, number, and reference; optional FTS5 for notes if needed |
| Low-end devices | Avoid large images and animations, profile on a 2 GB device, keep the APK small (split per ABI, tree-shake fonts and icons) |
| Memory | Stream and paginate; avoid loading full tables |
| DB writes | Use WAL mode; keep transactions short; batch inserts for restore or import |

---

## 12. Testing Strategy

| Level | What | Tools |
|---|---|---|
| **Unit (domain)** | `Money`, commission engine (rounding, effective dates, overrides), posting strategies (every type produces balanced entries), reconciliation heuristics | `flutter_test` |
| **Property-based** | Random transaction sequences: ledger always balances; sum of account balances stays consistent; void then re-add returns to the same balance | `glados` or custom generators |
| **Golden tests** | Posting output per transaction type; daily summary PDF layout | golden files |
| **Repository / DB** | Constraints, triggers (no delete, locked day), migrations, balance queries vs recompute | Drift in-memory DB |
| **Widget** | Keypad, entry flow, home balance cards, Bangla digit display, text scale | `flutter_test` widget tests |
| **Integration** | End-to-end: onboard → add transactions → close day with variance → backup → restore | `integration_test` on emulator |
| **Manual / field** | Usability sessions with real agents on low-end phones (timing the 5-second goal) | Observation, task timing |

**Critical invariants to test continuously**
1. Σ ledger deltas per active transaction = 0.
2. Live balance = recomputed balance from scratch.
3. Closing a day then reopening and re-closing yields the same results.
4. Backup, then restore, yields an identical DB (checksum of the logical content).

---

## 13. CI/CD and Release
- **Repo:** monorepo (`app/`, later `backend/`), trunk-based with short-lived branches.
- **CI (GitHub Actions):** format and analyze, unit and widget tests, build a release APK/AAB, and upload artifacts.
- **Signing:** keystore stored in CI secrets; Play App Signing enabled.
- **Distribution:** internal testing track, then closed beta with a small group of agents, then production.
- **Crash reporting and OTA hotfixes:** Crashlytics; Dart-only fixes shipped through regular store updates (no code push in MVP).
- **Versioning:** semantic version plus build number; the schema version is tracked separately.

---

## 14. Observability (Privacy-Preserving)
- Crash and ANR reports.
- Opt-in anonymous product analytics with events like `txn_saved`, `day_closed`, `variance_nonzero`, and `entry_time_ms`. **No amounts, phone numbers, or names.**
- Local **diagnostics screen** (integrity check result, DB size, last backup) that the user can share with support.

---

## 15. Implementation Plan (MVP)

| Milestone | Scope | Rough effort |
|---|---|---|
| **M0: Foundations** | Project setup, CI, Drift and SQLCipher, `Money`, i18n, theme, PIN lock | 1 to 1.5 wks |
| **M1: Ledger core** | Accounts, posting strategies, commission engine, integrity checks, audit log, with full unit tests | 1.5 to 2 wks |
| **M2: Entry and home** | Onboarding, home balances, fast entry (cash-in/out, flexiload, float purchase, expense), undo, history and search | 2 wks |
| **M3: Day close** | Reconciliation engine, gap suggestions, adjustments, locking, reopen, daily summary and PDF share | 1.5 to 2 wks |
| **M4: Backup and hardening** | Encrypted backup/restore, reminders and alerts, migrations, performance pass on a low-end device | 1 to 1.5 wks |
| **M5: Beta** | Field testing with real agents, fixes, Play Store listing and policy review | 2 wks |

Total: roughly **9 to 11 weeks** for one developer (estimate; adjust after M1 produces real velocity numbers).

---

## 16. Technical Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Ledger bug produces wrong balances | Destroys trust | Strategy-per-type design, property-based tests, a periodic integrity check with a visible "books verified" indicator |
| Data loss (lost or damaged phone) | Severe | Prominent backup UX, weekly nudges, early cloud backup in Phase 2 |
| Slow entry on low-end phones | Core promise broken | Local-only writes, custom keypad, profiling on a 2 GB device from M2 |
| Bangla text or digit rendering issues | Poor UX | Bundled font, widget tests at multiple text scales, test on old Android versions |
| Commission rates wrong or outdated | Wrong profit figures | User-confirmed, editable, dated rules; provider-agnostic defaults with a "verify rates" prompt |
| Schema changes break old backups | Failed restores | Versioned backups, migration tests, restore-time validation |
| SMS-parsing policy or brittleness (Phase 3) | Feature rejection or errors | Keep optional and isolated behind an interface; core never depends on it |
| Solo-dev scope creep | Delays | Strict P0 scope; Phase 2 and 3 gated by feature flags and by beta feedback |

---

## 17. Open Technical Decisions
1. **DB encryption cost:** confirm the SQLCipher APK size and performance on target devices, with a fallback of unencrypted DB plus an app-level lock if it is too heavy.
2. **Backend choice for Phase 2:** Django REST (matches common team skills) vs a managed backend (Firebase or Supabase) to cut ops work.
3. **Day-rollover hour default:** needs field input (shops open late or close after midnight).
4. **Staff accounts in MVP:** if included, the permission checks and the per-user audit trail move into M1.
5. **Posting model for charges:** whether customer-paid charges are tracked as separate ledger lines or only as informational fields in MVP.
6. **Edit semantics:** replace-by-new-transaction (proposed) vs in-place edit with a versioned history table.
