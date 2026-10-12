# Agent Cash Book: Sprint-wise Implementation Plan

**Companions:** `agent-cashbook-feature-spec.md`, `agent-cashbook-technical-design.md`
**Status:** Draft v0.1 | **Date:** 2026-10-11
**Scope:** MVP (Phase 1, P0) through closed beta. Phase 2 and 3 are outlined at the end.

---

## 1. Planning Assumptions

| Item | Assumption |
|---|---|
| Team | 1 full-time developer (Flutter), plus part-time design/QA support. Adjust the estimates if more people join. |
| Working week | Sunday to Thursday (5 days/week) |
| Proposed start | **Sunday, 2026-10-18** (change the dates if the start moves) |
| Sprint length | Sprint 0 = 1 week; Sprints 1 to 5 = 2 weeks each (**11 weeks total**) |
| Capacity | 10 working days per 2-week sprint; plan about **8 ideal days** of tasks per sprint, leaving about 20% for bugs, review, and surprises |
| Estimates | Ideal developer-days (**d**); 0.5d is the smallest unit. They are rough and should be recalibrated after Sprint 1 from actual velocity. |
| Priority | P0 only until the MVP beta; anything else is parked in the backlog (Section 10) |
| Tracking | Task IDs (e.g. `S2-07`) are used for the board, commits, and PRs |

### Sprint calendar

| Sprint | Dates (Sun to Thu) | Theme | Milestone |
|---|---|---|---|
| **S0** | Oct 18 to Oct 22 | Foundations | M0 |
| **S1** | Oct 25 to Nov 5 | Ledger core | M1 |
| **S2** | Nov 8 to Nov 19 | Onboarding, home, fast entry | M2 |
| **S3** | Nov 22 to Dec 3 | History, edit/void, commission UI, flexiload | M2 (cont.) |
| **S4** | Dec 6 to Dec 17 | Day close and reconciliation | M3 |
| **S5** | Dec 20 to Dec 31 | Backup, hardening, beta release | M4 + M5 start |
| **Beta** | Jan 2027 (2 to 3 wks) | Field testing with real agents | M5 |

> Note: the technical design grouped M2 as one 2-week block. Splitting it into S2 and S3 here adds buffer, because the entry flow, history, and flexiload together are the largest user-facing area.

---

## 2. Definition of Ready and Definition of Done

**Definition of Ready (task can start):**
- Acceptance criteria are written.
- Dependencies are done or stubbed.
- UI reference exists for any screen task (a sketch is enough).

**Definition of Done (task is complete):**
- Code merged to `main` through a PR with passing CI (format, analyze, tests).
- Unit or widget tests added for new logic and UI behavior.
- Bangla and English strings externalized; no hardcoded text.
- Works offline; no crashes on a low-end test device or emulator profile.
- Audit-log entries written for any state-changing action covered by the spec.
- Task acceptance criteria demonstrated, with a short note or screenshot in the PR.

**Sprint-level DoD:** a demo build (APK) installed on a real low-end Android phone, a short demo against the sprint goal, and a retro note.

---

## 3. Sprint 0: Foundations (Oct 18 to Oct 22, 1 week)

**Goal:** A running app skeleton with encrypted DB, CI, theming, localization, and lock screen, so feature work can start cleanly.
**Capacity:** about 4 ideal days.

| ID | Task | Details | Est. | Depends on |
|---|---|---|---|---|
| S0-01 | Repo and project setup | Create the repo, Flutter project (Android first), flavors (`dev`, `prod`), lints, `analysis_options`, folder structure per the tech design (core/features) | 0.5d | None |
| S0-02 | CI pipeline | GitHub Actions: format check, analyze, tests, build debug APK, upload artifact; cache pub dependencies | 0.5d | S0-01 |
| S0-03 | Drift + SQLCipher setup | Add Drift, SQLCipher libs, generate and store the DB key in the Android Keystore (secure storage), open the encrypted DB, WAL mode, an empty initial schema (v1) | 1d | S0-01 |
| S0-04 | **SQLCipher feasibility check** | Measure APK size delta, cold-start time, and write speed on a 2 to 3 GB device or emulator profile. **Decision gate:** keep SQLCipher or fall back to an unencrypted DB plus app lock (open question 1 in the tech design) | 0.5d | S0-03 |
| S0-05 | `Money` value object | Integer paisa, arithmetic, comparison, formatting, ৳ symbol, whole-taka vs paisa display, with unit tests | 0.5d | S0-01 |
| S0-06 | i18n scaffolding | ARB files for `bn` and `en`, language switch, `DigitFormatter` (0-9 and ০-৯), Bangladeshi digit grouping option, bundled Bangla font, with tests | 1d | S0-01 |
| S0-07 | Theme and design tokens | Light, dark, and high-contrast themes, colors for in/out direction, typography scale, 48dp tap targets | 0.5d | S0-01 |
| S0-08 | PIN lock (basic) | Set and verify PIN (salted hash), lock screen, auto-lock on background, incremental lockout after failed attempts; biometric deferred to S5 | 1d | S0-03 |

**Sprint 0 exit criteria**
- A signed debug APK builds on CI and runs on a physical phone.
- The DB opens encrypted; a PIN gates app entry; the language switch works with Bangla digits.
- SQLCipher decision recorded.

---

## 4. Sprint 1: Ledger Core (Oct 25 to Nov 5)

**Goal:** A trustworthy, fully tested accounting engine with no UI beyond a debug screen: accounts, posting strategies, commission engine, audit log, and integrity checks.
**Capacity:** about 8 ideal days.

| ID | Task | Details | Est. | Depends on |
|---|---|---|---|---|
| S1-01 | Schema v1 migration | Tables: `account`, `txn`, `ledger_entry`, `commission_rule`, `customer`, `day_close`, `day_close_line`, `expense_category`, `app_user`, `audit_log`, `setting`; indexes per Section 5.1 of the tech design | 1d | S0-03 |
| S1-02 | DB integrity triggers | Block `DELETE` on `txn`, `ledger_entry`, and `audit_log`; block updates of immutable columns; reject changes to locked transactions unless the day is reopened; trigger tests | 1d | S1-01 |
| S1-03 | Domain entities and enums | `Account`, `Transaction`, `TransactionType`, `LedgerEntry`, `CommissionRule`, `DayClose`; UUIDv7 generator; Dhaka timezone and business-date helper with a configurable rollover hour | 0.5d | S0-05 |
| S1-04 | Account repository and balances | Create, update, and deactivate accounts; live balance query; reactive balance stream (Drift watch); balance-from-scratch recompute used as an integrity check | 1d | S1-01, S1-03 |
| S1-05 | Posting strategy framework | `PostingStrategy` interface, registry, and the draft validator; the repository writes `txn` and `ledger_entry` in one DB transaction | 1d | S1-03, S1-04 |
| S1-06 | Strategies: cash-in, cash-out, float purchase, float transfer, expense, adjustment | Each produces balanced entries; golden tests per type; negative-amount and missing-account validation | 1.5d | S1-05 |
| S1-07 | Strategies: flexiload, send money, bill pay, bank deposit | Flexiload handles load cost vs sale price and margin; golden tests | 1d | S1-05 |
| S1-08 | Commission engine | Rule selection by provider, type, and effective date; modes `per_thousand`, `percent`, `fixed`; half-up rounding in integer math; snapshot of the rule on the transaction; manual override flag; unit tests for dates, rounding, and overrides | 1d | S1-03 |
| S1-09 | Audit logger | Central `AuditLogger` used by repositories; records before/after JSON, user, action, reason | 0.5d | S1-01 |
| S1-10 | Property-based and invariant tests | Random transaction sequences: Σ deltas per transaction = 0; live balance = recomputed balance; void then re-add restores the balance | 1d | S1-06, S1-07 |
| S1-11 | Debug harness screen | Dev-only screen: add transactions of each type, see account balances and the audit log; used for manual verification | 0.5d | S1-06 |

**Buffer:** about 1 day inside the 10-day sprint.

**Sprint 1 exit criteria**
- All transaction types post balanced entries; invariant tests pass over thousands of random sequences.
- The commission engine matches hand-calculated examples, including a mid-day rate change.
- A deleted-row attempt fails at the DB level.

---

## 5. Sprint 2: Onboarding, Home, and Fast Entry (Nov 8 to Nov 19)

**Goal:** A user can set up the app and record the most common transactions in about 5 seconds, with live balances on the home screen.
**Capacity:** about 8 ideal days.

| ID | Task | Details | Est. | Depends on |
|---|---|---|---|---|
| S2-01 | Onboarding flow | Language, provider and operator selection, account creation, opening balances, shop name, PIN setup; skippable quick start with defaults | 1.5d | S1-04 |
| S2-02 | Commission setup screen | Seeded default rules the user confirms or edits, with an "verify rates with your provider" prompt; effective-dated rule editing (also reused in settings later) | 1d | S1-08 |
| S2-03 | Home screen: balance cards | Horizontal cards for cash, each wallet, and flexiload total, from the live balance streams; low-balance highlight; tap to open the account ledger; optional tap-to-reveal masking | 1d | S1-04 |
| S2-04 | Custom numeric keypad widget | In-app keypad with "000" key, backspace, quick-amount chips (500, 1,000, 2,000, 5,000), Bangla digit display, input normalized to ASCII internally; widget tests at 1.5x text scale | 1d | S0-06 |
| S2-05 | Cash-out and cash-in entry screens | Single-screen flow: wallet picker (defaults to last used), amount via the keypad, auto-computed commission shown live, collapsed optional fields (customer number, note, TrxID), Save, then haptic and a confirmation | 1.5d | S2-04, S1-06, S1-08 |
| S2-06 | Undo and recent list | "Last 5 transactions" on home; undo snackbar for a few seconds after save (void with reason "undo") | 0.5d | S2-05 |
| S2-07 | Quick-amount learning | Chips learned from the user's most frequent amounts per type, plus "repeat last" | 0.5d | S2-05 |
| S2-08 | Entry guards and warnings | Warning if float or cash would go negative; large-amount confirm (threshold in settings); duplicate guard (same type, amount, account, and customer within 2 minutes); all non-blocking where possible | 0.5d | S2-05 |
| S2-09 | Float purchase entry | Source (cash or bank) and target wallet; updates both sides; uses the keypad | 0.5d | S1-06 |
| S2-10 | Expense entry | Category chips (rent, electricity, transport, staff pay, tea/snacks, other) plus custom category; amount via the keypad | 0.5d | S1-06 |
| S2-11 | Navigation shell | Bottom navigation (Home, History, Close Day, Reports, Settings placeholders) | 0.5d | S0-07 |

**Buffer:** about 1 day inside the 10-day sprint, for design iteration on the keypad and entry flow.

**Sprint 2 exit criteria**
- A new user completes onboarding in about 2 minutes.
- A cash-out is recorded in 5 seconds or less (timed on a real device).
- Home balances update instantly after each save, offline.
- Demo APK given to 1 or 2 friendly agents for early feedback on keypad and flow.

---

## 6. Sprint 3: History, Edit/Void, Flexiload, and Account Ledgers (Nov 22 to Dec 3)

**Goal:** Complete the daily-use feature set: flexiload, searchable history, corrections, account statements, and alerts.
**Capacity:** about 8 ideal days.

| ID | Task | Details | Est. | Depends on |
|---|---|---|---|---|
| S3-01 | Flexiload entry | Operator picker, number (optional), load amount, price charged, margin shown live; updates the operator balance; repeat-customer shortcut deferred (P1) | 1d | S1-07, S2-04 |
| S3-02 | Load purchase flow | Recharge the operator or SIM balance with cost; reduces cash or bank; feeds flexiload margin math | 0.5d | S3-01 |
| S3-03 | Transaction history list | Grouped by day, type icons and colors, direction text (not color only), keyset pagination, "Today / Yesterday / Week / Month" tabs | 1.5d | S1-04 |
| S3-04 | Search and filters | Search by amount, number, name, note, TrxID; filters by date range, account, type; indexed queries | 1d | S3-03 |
| S3-05 | Transaction detail screen | Full details, commission snapshot, creator, audit trail for the entry | 0.5d | S3-03, S1-09 |
| S3-06 | Void flow | Void with required reason; strikethrough in lists; excluded from balances; audit entry | 0.5d | S3-05 |
| S3-07 | Edit flow | Edit = new transaction with `replaces_txn_id` plus void of the original, in one DB transaction; lineage view in the detail screen | 1d | S3-06 |
| S3-08 | Account ledger screen | Per-account statement with running balance, date filter, paper-style columns (date, description, in, out, balance) | 1d | S1-04 |
| S3-09 | Manual balance adjustment | Adjustment with mandatory reason, posted through the adjustment strategy | 0.5d | S1-06 |
| S3-10 | Low float / low cash alerts | Per-account thresholds in settings; in-app banner on home; local notification | 0.5d | S2-03 |
| S3-11 | Customer quick-fill | Optional customer table; suggest names or numbers from history while typing (opt-in, privacy-aware, nothing imported from contacts) | 0.5d | S2-05 |
| S3-12 | Expenses list | Simple expense list and monthly total in History | 0.5d | S2-10 |

**Buffer:** about 1 day inside the 10-day sprint.

**Sprint 3 exit criteria**
- Every transaction type can be entered, found, corrected, and voided.
- Editing and voiding never delete data; the audit trail shows every change.
- Per-account ledgers agree with home balances (verified by the integrity check).
- Second demo to field agents; collect keypad speed and flow feedback.

---

## 7. Sprint 4: Day Close and Reconciliation (Dec 6 to Dec 17)

**Goal:** The "close the day in a minute and see where the gap is" experience, with locking and a shareable summary.
**Capacity:** about 8 ideal days.

| ID | Task | Details | Est. | Depends on |
|---|---|---|---|---|
| S4-01 | Reconciliation engine: expected balances | Expected balance per account at close time from the ledger (same formula as live balance); the rollover-hour business date | 0.5d | S1-04 |
| S4-02 | Reconciliation engine: gap heuristics | Exact-match and sign check (missing vs double-recorded), double and half amount, direction-swap, duplicate window, digit transposition (difference divisible by 9), each with a confidence score and explanation text (bn and en); unit tests with seeded scenarios | 1.5d | S4-01 |
| S4-03 | Close Day UI: counting step | Expected shown per account; actual entry fields; optional **cash denomination counter** (৳1000 down to coins) with auto-sum | 1.5d | S4-01, S2-04 |
| S4-04 | Close Day UI: variance and suggestions | Per-account variance, ranked top-3 suggestions, "add missing transaction" shortcut returning to the flow, tolerance setting (±৳ threshold) | 1.5d | S4-02, S4-03 |
| S4-05 | Adjustment on close | Residual variance posted as an adjustment with a required reason code (shortage, excess, provider charge, counting error, other) | 0.5d | S4-04, S3-09 |
| S4-06 | Day close commit | Transactional commit: `day_close` and lines, adjustment postings, lock the day's transactions, write `balance_snapshot`, audit entry; idempotent | 1d | S4-05, S1-02 |
| S4-07 | Day-lock enforcement in UI | Locked days show a lock icon; edit/void and back-dated entry disabled with an explanation; owner-only **reopen** with a reason and audit trail | 1d | S4-06, S3-07 |
| S4-08 | Daily summary screen and share | Transactions count, volume, commission, flexiload margin, expenses, net profit, variance; export to image and PDF; share through WhatsApp | 1d | S4-06 |
| S4-09 | Balance snapshots | `balance_snapshot` table; live balance = latest snapshot plus later entries; the full recompute stays as the integrity check | 0.5d | S4-06 |
| S4-10 | Close-day reminder | Local notification at a user-set time, plus a "yesterday not closed" banner | 0.5d | S3-10 |

**Buffer:** about 0.5 day. This sprint is tight, and S4-02 (heuristics) can be trimmed to the first three checks if needed, with the rest moved to Sprint 5 or Phase 2.

**Sprint 4 exit criteria**
- A seeded day with a deliberate error is closed, and the app correctly surfaces the likely cause.
- Closing, reopening, and re-closing a day gives identical results (test-verified).
- The next day's opening balances equal the previous day's actual balances.
- Daily summary PDF shared successfully through WhatsApp on a real device.

---

## 8. Sprint 5: Backup, Hardening, and Beta Release (Dec 20 to Dec 31)

**Goal:** Data safety, polish, performance on low-end phones, and a beta-ready build in Play internal testing.
**Capacity:** about 8 ideal days.

| ID | Task | Details | Est. | Depends on |
|---|---|---|---|---|
| S5-01 | Encrypted backup file | `.cbk` format: DB checkpoint plus metadata header (schema version, app version, device id, checksum), AES-256-GCM with a key from a user passphrase (Argon2id); share sheet | 1.5d | S0-03 |
| S5-02 | Restore flow | Pick file, verify checksum and schema version, passphrase prompt, pre-restore snapshot of the current DB, confirmation, replace; rejects newer-schema backups with a clear message | 1.5d | S5-01 |
| S5-03 | Backup reminders and UX | Weekly nudge and a post-close nudge; "last backup" shown in settings; clear warning that a lost passphrase cannot be recovered | 0.5d | S5-01 |
| S5-04 | Migration test suite | Fixture DBs from each schema version upgraded and verified; backup/restore round trip equals the original logical content | 1d | S5-02 |
| S5-05 | Biometric unlock | `local_auth` layer on top of the PIN; fallback to the PIN; settings toggle | 0.5d | S0-08 |
| S5-06 | Settings completion | Language and digit style, thresholds, categories, rollover hour, theme and text size, shop details, commission rules, tolerance | 1d | S2-02 |
| S5-07 | Performance pass | Profile on a 2 to 3 GB device: cold start under 2 s, transaction save under 300 ms, history scroll with 10,000+ seeded rows, APK size per ABI; fix hotspots | 1d | all |
| S5-08 | Privacy and safety polish | `FLAG_SECURE` on sensitive screens, optional balance masking, diagnostics and integrity-check screen ("books verified" indicator) | 0.5d | S1-04 |
| S5-09 | Accessibility and Bangla QA | Text scale to 1.5x on all key screens, TalkBack labels on primary actions, a Bangla copy review for plain everyday wording | 0.5d | all |
| S5-10 | Crash reporting and opt-in analytics | Crashlytics; opt-in analytics events (`txn_saved`, `day_closed`, `variance_nonzero`, `entry_time_ms`) with **no amounts or phone numbers** | 0.5d | S0-02 |
| S5-11 | Release prep | Signing config, Play Console listing (Bangla and English text, screenshots), privacy policy, data-safety form, a disclaimer that this is not an MFS provider app and is not affiliated with any provider, internal testing track upload | 1d | all |

**Buffer:** minimal. If time runs short, move S5-05 (biometric) and part of S5-09 to the first beta patch release.

**Sprint 5 exit criteria**
- A backup taken on one phone restores correctly on another.
- Performance targets are met on the low-end test device.
- A signed AAB is available on the Play internal testing track.

---

## 9. Beta Phase (January 2027, 2 to 3 weeks)

**Goal:** Prove the product with real agents and decide what goes into Phase 2.

| ID | Task | Details | Est. |
|---|---|---|---|
| B-01 | Recruit 8 to 15 beta agents | Mix of bKash-only, Nagad, and flexiload-heavy shops; at least a few low-end phones | 3d (elapsed, parallel) |
| B-02 | Onboarding and training | Short Bangla guide or video (2 to 3 minutes), a WhatsApp support group | 1d |
| B-03 | Observed sessions | Time the 5-second entry goal and the close-day flow with 3 to 5 agents in their shops | 2d |
| B-04 | Metrics review | Entry time, day-close completion, variance frequency, crashes, backup usage | 1d |
| B-05 | Triage and fix | Bugs, wording fixes, flow tweaks; weekly patch releases | 5d |
| B-06 | Phase 2 prioritization | Rank the backlog from field feedback (Section 10) and set Phase 2 sprints | 1d |

**Beta exit criteria**
- Entry time is 5 seconds or less in the median case.
- At least 60% of active beta days are closed through the app.
- Zero data-loss incidents; crash-free sessions are 99.5% or better.
- At least some beta agents say they would stop using paper.

---

## 10. Backlog for Phase 2 and Phase 3 (not in MVP sprints)

**Phase 2 candidates (P1), to be re-ranked after beta**
- Customer dues (baki) with settle flows and a due list
- Staff accounts with separate PINs, role permissions, and hidden profit
- Shift-based reconciliation
- Reports: weekly and monthly summaries, CSV and Excel export, account statements as PDF
- Commission received vs expected comparison
- Cloud backup with phone and OTP login (Django REST or a managed backend)
- Repeat-customer shortcuts and bulk flexiload entry
- Tiered commission mode and recurring expenses
- Variance history chart

**Phase 3 candidates (P2)**
- SMS-assisted entry and balance verification (opt-in; Play policy review required)
- Multi-device sync (append-only events, UUIDv7 IDs)
- Printable paper-style daily sheet
- Insights (best hours, average transaction size)
- iOS

---

## 11. Dependencies and Critical Path

```
S0 Foundations ─► S1 Ledger core ─► S2 Entry/Home ─► S3 History/Flexiload ─► S4 Day close ─► S5 Backup/Release ─► Beta
      │                 │                                                          ▲
      └─ S0-04 gate     └─ commission engine ──► S2-02 rate setup                  │
         (SQLCipher)                                S1-04 balances ──────────────────┘ (expected = ledger balance)
```

**Critical path:** S0-03 (encrypted DB), then S1-05 to S1-08 (posting strategies and commission), then S2-05 (entry), then S4-01 to S4-06 (day close commit), then S5-01/S5-02 (backup and restore), then release.

Items that can run in parallel with a single developer by interleaving: UI sketches and Bangla copy review (design/QA support), the Play listing assets, and the training guide.

---

## 12. Risks and Contingency by Sprint

| Sprint | Risk | Early signal | Contingency |
|---|---|---|---|
| S0 | SQLCipher too heavy or slow on low-end devices | S0-04 measurements | Fall back to an unencrypted DB plus app lock and encrypted backups; revisit later |
| S1 | Ledger design bug found late | Property tests failing, or the integrity check disagreeing with live balances | Stop feature work; fix before S2; this is the foundation |
| S2 | Entry flow not fast enough | Timed sessions over 5 s | Cut optional fields further, enlarge chips, add repeat-last on the first screen |
| S3 | Edit/void semantics confuse users | Beta feedback or testing | Restrict edit to void and re-enter in MVP; keep the lineage view |
| S4 | Heuristics produce noisy suggestions | Many wrong "top-3" hints in seeded tests | Ship only exact-match, double/half, and duplicate checks; the rest moves to Phase 2 |
| S5 | Backup and restore edge cases | Round-trip test failures across schema versions | Delay beta by a few days; do not ship without a working restore |
| All | Velocity lower than estimated | Sprint 1 actuals below 80% of plan | Recalibrate; defer S5-05, S3-11, S2-07 first (nice-to-haves) |
| All | Commission rates or provider rules differ from assumptions | Beta feedback | Keep rates user-editable and effective-dated; adjust defaults by data, not code |

**Scope-cut order if time is short (least painful first):** biometric unlock, quick-amount learning, customer quick-fill, cash denomination counter, extra reconciliation heuristics, expenses list screen.

---

## 13. Ceremonies and Working Agreements
- **Sprint planning:** half a day at the start of each sprint (Sunday); re-estimate from actual velocity.
- **Daily check-in:** 10 minutes, written, even when working solo (done, next, blockers).
- **Mid-sprint demo to a field agent:** at the end of S2, S3, and S4, a 30-minute session with an agent; the notes feed the next sprint.
- **Sprint review and retro:** 1 hour on the last day (Thursday): demo build, metrics, what to change.
- **Branching:** trunk-based with short-lived branches, `main` always releasable, PRs even when solo (self-review checklist).
- **Commit convention:** `S2-05: add cash-out entry screen` (task ID first).
- **Testing rule:** no ledger or reconciliation code merges without tests; the invariant suite runs on every CI build.

---

## 14. Summary Timeline

| Week | Dates | Sprint | Main deliverable |
|---|---|---|---|
| 1 | Oct 18 to 22 | S0 | App skeleton, encrypted DB, CI, PIN, i18n |
| 2 to 3 | Oct 25 to Nov 5 | S1 | Tested ledger and commission engine |
| 4 to 5 | Nov 8 to 19 | S2 | Onboarding, home balances, fast entry |
| 6 to 7 | Nov 22 to Dec 3 | S3 | Flexiload, history, edit/void, ledgers, alerts |
| 8 to 9 | Dec 6 to 17 | S4 | Day close, reconciliation, lock, daily summary |
| 10 to 11 | Dec 20 to 31 | S5 | Backup/restore, hardening, internal-testing release |
| 12 to 14 | Jan 2027 | Beta | Field testing and the Phase 2 plan |
