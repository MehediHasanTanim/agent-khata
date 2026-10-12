# Agent Cash Book: Feature Specification

**App idea:** A cash book for bKash / Nagad / Rocket agents and flexiload (mobile top-up) retailers in Bangladesh. It tracks cash and e-float balances, cash-in / cash-out, commission, and daily reconciliation, replacing the paper notebook.

**Document status:** Draft v0.1
**Date:** 2026-10-10
**Platform (proposed):** Android-first mobile app (Flutter), offline-first, Bangla-first UI

---

## 1. Problem and Context

### 1.1 The user
A small agent who runs a mobile financial services (MFS) point from a shop, kiosk, or counter. Typically:
- Holds one or more agent wallets (bKash, Nagad, Rocket, sometimes Upay) plus SIMs for flexiload.
- Handles 30 to 300+ small transactions a day.
- Records everything on paper: a notebook with date, number, amount, and balance.
- Closes the day by counting cash and checking wallet balances on the phone or USSD.
- Is often not very tech-savvy, works in Bangla, and uses a low to mid-range Android phone with unreliable internet.

### 1.2 Pain points with paper
1. Arithmetic mistakes in running balances.
2. The end-of-day cash and float do not match, and it is hard to find where the gap came from.
3. Commission earned is unknown or guessed, so true daily profit is invisible.
4. Customer dues (baki) and float purchases from distributors get lost.
5. No history for searching, auditing, or disputes ("did I send 2,000 to this number yesterday?").
6. Employees or family members handle the counter, which makes accountability weak.

### 1.3 Product principle
> **Entering a transaction must be faster than writing it on paper.** Numbers are simple and repetitive, so the app should need 2 to 3 taps and one amount for the most common transaction.

---

## 2. Goals and Non-Goals

### Goals
- G1. Record a typical transaction in under 5 seconds.
- G2. Always show current **cash in hand** and **e-float per wallet**, accurate to the taka.
- G3. Calculate commission automatically from configurable rates.
- G4. Make end-of-day reconciliation a guided, 1-minute process that pinpoints variance.
- G5. Work fully offline, with optional cloud backup.
- G6. Be usable in Bangla with Bangla digits by non-technical users.

### Non-Goals (v1)
- Not an MFS provider app. It does not move real money or integrate with the bKash/Nagad agent API for payments.
- Not a full accounting or tax package.
- No customer-facing features.
- No iOS in v1 (revisit later).

---

## 3. Users and Roles

| Role | Description | Key permissions |
|---|---|---|
| **Owner** | Shop owner and primary agent | Everything, including settings, rates, reports, delete/edit, staff management |
| **Staff / Operator** | Employee at the counter | Add transactions, view own shift totals; cannot edit rates, delete, or see profit (configurable) |
| **Viewer** (optional, v2) | Family member or accountant | Read-only reports |

v1 can launch as single-owner with a simple PIN, and add staff with separate PINs in Phase 2.

---

## 4. Core Concepts and Data Model

### 4.1 Accounts (the "pockets" of money)
The app models every place money sits as an **account**:

| Account type | Examples | Notes |
|---|---|---|
| **Cash** | Cash drawer | Physical cash in hand |
| **E-float wallet** | bKash Agent, Nagad Agent, Rocket Agent, Upay | One per wallet number/provider |
| **Flexiload balance** | GP SIM, Robi SIM, Banglalink SIM, Airtel SIM, Teletalk SIM | Load balance per operator or SIM |
| **Bank (optional)** | DBBL, bank account | Used for float purchase or cash deposit |

Every transaction moves value between accounts, which is what makes reconciliation work.

### 4.2 Transaction types and their effect on accounts

| Type | Meaning | Cash | E-float (that wallet) | Commission |
|---|---|---|---|---|
| **Cash-in** | Customer gives cash, agent sends e-money to the customer's wallet | **+ amount** | **− amount** | Usually small or none (configurable) |
| **Cash-out** | Customer withdraws, agent gives cash | **− amount** | **+ amount** | Yes (the main earning) |
| **Send money / Payment (agent-assisted)** | Customer pays cash, agent sends to a third party | + amount (+ fee if charged) | − amount | Configurable |
| **Bill pay / Merchant pay** | Utility or merchant payment on behalf of the customer | + amount + service charge | − amount | Configurable |
| **Flexiload (top-up)** | Customer pays cash, agent loads a number | + sale amount | − load amount (SIM balance) | Margin = sale − cost, or % commission |
| **Float purchase / Float-in** | Agent buys e-float from a distributor, bank, or own wallet | − cash (or bank −) | + amount | None |
| **Float transfer between wallets** | e.g. bKash to Nagad | none | one −, one + | Fee, if any |
| **Cash deposit to bank / withdrawal from bank** | Moving cash to the bank to rebalance | ± cash | none | None |
| **Expense** | Rent, transport, tea, etc. | − cash | none | Tracked as expense |
| **Adjustment** | Correction with a reason, used in reconciliation | ± any | ± any | none |

> Sign convention is shown from the agent's point of view. Cash-in (customer deposit) *reduces* the agent's e-float and *increases* cash. Cash-out is the reverse. The UI uses plain Bangla wording ("ক্যাশ ইন / ক্যাশ আউট") with clear colors and icons, so users do not confuse direction.

### 4.3 Commission model
- **Rate table per provider and per transaction type**, for example:
  - Cash-out: X taka per 1,000 (or % of amount)
  - Cash-in: X taka per 1,000 (may be 0)
  - Flexiload: X% per operator
  - Bill pay: fixed per bill type
- Commission rates are **user-editable with effective dates**, because providers change them. The app ships with sensible defaults but **does not hardcode "official" rates**; the user confirms them on first setup.
- Per transaction, the app stores `commission_amount` using the rate in effect at that time (history stays correct when rates change).
- Commission can be **manually overridden** per transaction.
- Optional: **Actual commission credited** vs **calculated commission**. Providers credit commission in batches, so the app can compare the two periodically and show the gap (see 7.5).

### 4.4 Key entities (conceptual)
- `Account` (id, type, provider, label, number, opening_balance, is_active)
- `Transaction` (id, datetime, type, account_from, account_to, amount, customer_number?, customer_name?, charge, commission, note, created_by, status, reference_id/TrxID?)
- `CommissionRule` (provider, txn_type, mode[per_thousand|percent|fixed], value, effective_from)
- `Customer` (name, phone, notes), optional
- `DueEntry` (customer, amount, direction[they_owe|i_owe], status)
- `DayClose` (date, expected balances, counted balances, variance per account, notes, signed_off_by)
- `Expense`, `Adjustment`, `AuditLog`

---

## 5. Feature List (Prioritized)

Priority legend: **P0** = MVP must-have, **P1** = launch-soon, **P2** = later.

### 5.1 Onboarding and Setup (P0)
- F1.1 Language selection (Bangla default, English option); digit style selection (বাংলা ০-৯ or 0-9).
- F1.2 Create accounts: choose providers (bKash / Nagad / Rocket / Upay), flexiload operators, cash drawer.
- F1.3 Enter **opening balances** for cash and each account.
- F1.4 Set commission rates, with a guided screen showing defaults the user can confirm or edit.
- F1.5 Set PIN or biometric lock.
- F1.6 Skippable "quick start" with defaults, with the option to edit later.

### 5.2 Fast Transaction Entry (P0). The heart of the app

**Home screen layout**
- Top: live balance cards: **Cash**, **bKash float**, **Nagad float**, **Flexiload total** (horizontal scroll if more).
- Middle: large one-tap buttons: **ক্যাশ আউট**, **ক্যাশ ইন**, **ফ্লেক্সিলোড**, **ফ্লোট কেনা**, **খরচ**.
- Bottom: today's quick totals and the last 5 transactions with undo.

**Entry flow (cash-out, example)**
1. Tap **ক্যাশ আউট**, then choose the wallet (defaults to last used; one tap to switch).
2. Enter the amount on a large custom numeric keypad, with quick-amount chips (500, 1,000, 2,000, 5,000, "last amount").
3. Commission auto-calculates and is shown below the amount.
4. (Optional) Customer number / name / note, collapsed by default.
5. Tap **সেভ**. Balances update instantly, with haptic and brief confirmation.

Requirements:
- F2.1 Single-screen entry; no mandatory fields beyond type, account, amount.
- F2.2 **Repeat last transaction** and **quick amount chips** (learned from frequent amounts).
- F2.3 **Undo last entry** within a few seconds via a snackbar, and full edit/void later (with audit log).
- F2.4 Optional customer phone with auto-suggest from history (privacy-aware, see 9).
- F2.5 Optional **TrxID / reference** field for matching against provider SMS.
- F2.6 **Back-dated entry**, for when the agent records transactions later (time picker, default to now).
- F2.7 **Batch / tally mode**: when busy, tap counters (for example "+1,000 cash-out" repeated) and the app logs individual entries behind the scenes.
- F2.8 Warnings: float going negative, cash going negative, amount unusually large (configurable threshold), or duplicate amount and number within 2 minutes.
- F2.9 Per-wallet **transaction limits awareness** (optional reminders for daily limits).
- F2.10 Large-text mode and high-contrast mode for readability in poor lighting.

### 5.3 Balances and Accounts (P0)
- F3.1 Real-time balance per account, derived from opening balance + all transactions.
- F3.2 Account detail screen with the statement (ledger) for that account and a running balance.
- F3.3 **Low float / low cash alerts** with user-set thresholds ("bKash float below 10,000 → time to buy float").
- F3.4 Add or deactivate accounts anytime (new SIM, new wallet).
- F3.5 **Float purchase and transfer flows** keep both sides consistent (P0).
- F3.6 Manual balance correction through an **Adjustment** with a mandatory reason (P0).

### 5.4 Flexiload (P0/P1)
- F4.1 Record a top-up: operator, number (optional), load amount, price charged, auto-calculated margin.
- F4.2 **Operator-wise balance** tracking and low-balance alert.
- F4.3 Buying load stock (recharging the SIM or retailer balance) as a **Load Purchase** with cost, which feeds margin and cash.
- F4.4 Operator-wise commission or discount % settings.
- F4.5 (P1) **Repeat-customer shortcut** for regular numbers.
- F4.6 (P2) Bulk entry for multiple loads at once.

### 5.5 Daily Reconciliation (P0). The second most important feature

**Goal:** Close the day in about a minute and know exactly where any gap is.

Flow:
1. User taps **দিনের হিসাব মিলান** (Close Day).
2. App shows **Expected** balances (from the transactions): cash, each wallet, each flexiload account.
3. User enters **Actual** balances: counted cash, wallet balance from the app or USSD, and SIM balances.
   - Cash counting helper: enter notes by denomination (৳1000 / 500 / 200 / 100 / 50 / 20 / 10 / 5 / coins), which auto-sums. (P1)
4. App computes **variance** per account (actual − expected) and a total.
5. If variance ≠ 0, the app offers **Find the gap** helpers:
   - Highlights transactions that look suspicious: duplicates, round-number mismatches, amounts equal to the variance, or an amount equal to half or double of one.
   - Shows "variance equals the amount of transaction #X. Did you forget to record or double-record it?"
   - Lets the user **add a missing transaction** or **post an adjustment** (with a reason: "shortage", "excess", "provider charge", "counting error", "other").
6. Day is **closed**: the closing balances become the next day's opening balances, and the day's entries are locked (further changes require a "reopen" with an audit record).
7. A **daily summary** is generated: transactions count, total cash-in/cash-out volume, commission, expenses, net profit, and variance.

Additional requirements:
- F5.1 Reconciliation per account, not just a combined total.
- F5.2 **Shift-based reconciliation** (P1): multiple shifts or operators per day, each with its own handover count.
- F5.3 Missed-close reminder (notification if yesterday was not closed).
- F5.4 Variance history chart (is the shortage a pattern?). (P1)
- F5.5 Short **shortage/excess tolerance** setting (for example, ignore ±৳5, or flag it).
- F5.6 Reopening a closed day is owner-only and logged.

### 5.6 Commission and Profit Tracking (P0/P1)
- F6.1 Per-transaction commission calculation (see 4.3).
- F6.2 **Daily / weekly / monthly commission** report, by provider and transaction type.
- F6.3 **Net profit** = commission + flexiload margin − expenses (shown on the daily summary).
- F6.4 **Commission received vs expected** reconciliation (P1): the user records the actual commission credited by the provider, and the app shows the difference.
- F6.5 Rate change history with effective dates.
- F6.6 (P2) Insights: "Most profitable hour or day", "Average transaction size".

### 5.7 Expenses (P1)
- F7.1 Quick expense entry with categories (rent, electricity, transport, staff pay, tea/snacks, other) and a custom category option.
- F7.2 Expenses reduce cash and appear in the P&L.
- F7.3 Recurring expenses (monthly rent) with reminders. (P2)

### 5.8 Customer Dues / Baki (P1)
Agents sometimes give credit or hold customer money.
- F8.1 Record "customer owes me" (for example, gave cash or load without payment) and "I owe customer".
- F8.2 Settle partially or fully, with the settlement posting to cash or float.
- F8.3 Due list with total outstanding, search, and call/SMS shortcut.
- F8.4 Gentle reminder messages (SMS share). (P2)

### 5.9 History, Search and Edit (P0/P1)
- F9.1 Chronological transaction list grouped by day, with type filters and color/icon coding.
- F9.2 Search by amount, number, name, note, TrxID.
- F9.3 Filters: date range, account, type, staff.
- F9.4 Edit or void a transaction, with the **original preserved in the audit log** (never silent deletion).
- F9.5 Voided entries show strikethrough and are excluded from balances.
- F9.6 "Today / Yesterday / This week / This month" quick tabs.

### 5.10 Reports and Export (P1)
- F10.1 Daily summary (also shareable as an image or PDF to WhatsApp).
- F10.2 Weekly and monthly summaries: volume, commission, expenses, profit, variance trend.
- F10.3 Account statements per wallet.
- F10.4 Export to **PDF and CSV/Excel**.
- F10.5 Printable daily sheet that mirrors the paper format, for users who still want a hard copy. (P2)

### 5.11 SMS Assist (P2, optional and opt-in)
- F11.1 Read provider transaction SMS (with explicit Android permission) to **suggest** entries or verify TrxIDs and balances after each transaction.
- F11.2 Compare the balance in the latest SMS against the app's expected balance, giving a live mini-reconciliation.
- F11.3 Never auto-post without user confirmation; parsing is best-effort and fails gracefully.
- **Risk note:** SMS permission is sensitive on Google Play (see Section 10). This stays optional, and the app must work fully without it.

### 5.12 Security and Access (P0/P1)
- F12.1 App PIN and/or biometric lock (P0).
- F12.2 Auto-lock after inactivity.
- F12.3 Staff accounts with separate PINs and role permissions (P1).
- F12.4 **Hide profit/commission from staff** (P1).
- F12.5 Audit log of edits, voids, reopen-day actions, and adjustments (P0, minimal; expanded in P1).
- F12.6 Optional **screen-hide for balances** (tap to reveal), useful when customers can see the screen.

### 5.13 Backup, Sync and Data Safety (P0/P1)
- F13.1 Offline-first local database; everything works with no internet (P0).
- F13.2 **Manual backup/export** to a file, shareable to Google Drive or WhatsApp (P0).
- F13.3 **Automatic cloud backup** with phone-number login or OTP (P1).
- F13.4 Restore on a new phone (P0/P1).
- F13.5 Multi-device sync, owner and staff phones (P2; conflict resolution via append-only transactions).

### 5.14 Notifications and Reminders (P1)
- Low float / low cash alert
- Day-close reminder (user-set time, for example 9 PM)
- Unreconciled-yesterday reminder
- Daily summary notification at close

### 5.15 Settings and Localization (P0)
- Language (বাংলা / English), digit style, date format.
- Currency symbol (৳), rounding rules.
- Commission rates, thresholds, categories.
- Business name and shop details (appears on reports).
- Theme (light, dark, high-contrast), font size.

---

## 6. Key User Flows (Narrative)

### Flow A: A normal busy day
1. 9:00: Open the app. Opening balances are carried from last night's close.
2. Throughout the day: 1 tap to open **Cash-out**, type 2,000, Save. Repeat.
3. Midday: bKash float alert triggers, so the agent buys float: **Float purchase** ৳50,000 (cash −, bKash float +).
4. Evening: Taps **Close Day**, enters counted cash and wallet balances.
5. Variance ৳0, so the day is closed and the summary shows commission and profit.

### Flow B: Reconciliation with a mismatch
1. At close, cash is short by ৳500.
2. The app highlights: "A cash-out of ৳500 at 2:14 PM has no matching wallet increase. Possibly recorded but not completed" and "No transaction matches ৳500 on the cash side."
3. The agent realizes a customer's cash-in of ৳500 wasn't entered, adds it, and the variance becomes 0.
4. Close the day.

### Flow C: First-time setup
Language → providers → opening balances → commission defaults → PIN → home screen ready in about 2 minutes.

---

## 7. Business Rules and Calculation Details

1. **Balance formula (per account):**
   `current = opening + Σ(inflows) − Σ(outflows)`, excluding voided entries.
2. **Expected cash at close:**
   `opening_cash + cash_in_txns + flexiload_sales + other_cash_in − cash_out_txns − float_purchases_paid_in_cash − expenses − bank_deposits`
3. **Expected e-float at close (per wallet):**
   `opening_float + cash_out_amounts + float_purchases − cash_in_amounts − payments_sent`
   Commission credited by the provider is tracked separately, because it may be paid later or in batches (see F6.4).
4. **Net profit:** `Σ commission + Σ flexiload margin − Σ expenses`.
5. **Variance:** `actual − expected`. Positive means excess; negative means shortage.
6. **Closed-day locking:** Entries on closed days are immutable except through a logged reopen.
7. **Negative balance policy:** Warn, but allow (real life can be out of sync), and flag it at reconciliation.
8. **Amounts:** Whole taka by default, with optional paisa. Rounding is documented and consistent.
9. **Commission snapshot:** The rate in effect at transaction time is stored with the entry, so editing rates never rewrites history.

> **Note on rates and fees:** Provider commission and customer charges differ by provider and change over time. The app treats all rates as user-configured data and should show a clear "verify rates with your provider" prompt on setup.

---

## 8. UX and Design Requirements

- **Bangla-first**: all UI strings, number formatting (optional Bangla digits), and error messages in simple, everyday Bangla.
- **One-hand use**: key actions in the bottom half of the screen.
- **Big touch targets** (≥ 48dp) and a purpose-built **numeric keypad** with ৳ amounts and "000" shortcut.
- **Color + icon + text** for direction (green and arrow-in for cash-in, red or orange and arrow-out for cash-out), so it does not rely on color alone.
- **Minimal text input**: prefer chips, defaults, and recents.
- **Paper-familiar layout** for ledgers: date, description, in, out, balance columns.
- **Low-end device performance**: cold start under 2 seconds, smooth on 2-3 GB RAM phones, small APK size.
- **Works in poor light and with dirty or greasy hands**: high contrast, large text, forgiving taps, undo.
- Accessibility: scalable fonts, optional TalkBack labels.

---

## 9. Non-Functional Requirements

| Area | Requirement |
|---|---|
| **Offline** | 100% core functionality offline; sync is background and optional |
| **Performance** | Transaction save < 300 ms; list of 10,000+ transactions scrolls smoothly (paged/indexed) |
| **Reliability** | No data loss on crash or low battery (write-ahead local DB); durable saves |
| **Data integrity** | Append-only ledger design; edits and voids create audit entries; balances derived or verifiable |
| **Security** | Local DB encryption; PIN/biometric; encrypted backups |
| **Privacy** | Collect minimal customer data; customer phone numbers optional; clear consent and policy; data stays on device unless the user enables backup |
| **Compatibility** | Android 8+ (target the low end of common devices in Bangladesh) |
| **Size** | Small APK; low memory and battery usage |
| **Localization** | Bangla and English; Bangla digits |

---

## 10. Risks and Open Questions

### Risks
1. **Trust and adoption:** Agents are used to paper. The app must be visibly faster and simpler, with a free tier and fast onboarding.
2. **Commission rate variance:** Rates differ by provider tier and change over time, so they must be easy to edit, and the app must not present them as official.
3. **SMS permission policy:** Google Play restricts SMS permissions. The SMS feature may need a policy declaration or may be dropped, so the core app cannot depend on it.
4. **Data loss fear:** Phone loss or damage means lost books. Backup and restore must be prominent and simple.
5. **Staff misuse / fraud:** Roles, audit logs, and variance tracking are important and should be positioned as a selling point.
6. **Regulatory sensitivity:** The app records financial activity but does not move money. This should be stated clearly in the app and listing, so it is not confused with an MFS provider app. Branding must avoid implying affiliation with bKash, Nagad, or other providers (use generic wording and no logos without permission).

### Open questions
- Q1. Should v1 support **multiple wallets of the same provider** (two bKash numbers)? *(Recommended: yes, since accounts are generic.)*
- Q2. Do target users want **staff/multi-operator** in v1, or is single-owner enough?
- Q3. How much **customer detail** is desired (phone, name), given privacy and speed trade-offs?
- Q4. Pricing model: free with ads, a freemium one-time unlock, or a small subscription? Pricing must suit very small shops.
- Q5. Should the app support **Rocket / Upay / other wallets** at launch or add them later?
- Q6. Is SMS-assisted entry worth the Play Store policy overhead in v1?
- Q7. Do agents want **distributor/DSO float ledgers** (credit purchases of float)? This looks common and might be P1.

---

## 11. Release Plan

### Phase 1: MVP (P0)
Onboarding, accounts and opening balances, fast transaction entry (cash-in, cash-out, flexiload, float purchase, expense), live balances, commission auto-calculation, daily reconciliation with variance and adjustments, history and search, edit/void with audit, PIN lock, manual backup/restore, Bangla UI.

### Phase 2: Growth (P1)
Customer dues, detailed reports with PDF/CSV export and share, cash denomination counter, low-float alerts and reminders, automatic cloud backup, staff roles, commission received vs expected, shift reconciliation.

### Phase 3: Advanced (P2)
SMS-assisted entry and balance verification, multi-device sync, printable paper-style daily sheet, insights and analytics, recurring expenses, bulk flexiload entry, iOS.

---

## 12. Success Metrics

| Metric | Target (initial) |
|---|---|
| Time to record a typical transaction | ≤ 5 seconds |
| Onboarding completion (to first transaction) | ≥ 80% within 5 minutes |
| Day-close completion rate (active users) | ≥ 60% of active days |
| Days with variance resolved or explained | ≥ 90% of closed days |
| 30-day retention (agents who still log daily) | ≥ 40% |
| Crash-free sessions | ≥ 99.5% |
| Data-loss incidents | 0 |

---

## 13. Appendix: Example Daily Summary (Mock)

```
তারিখ: ১০ অক্টোবর ২০২৬

                     Opening     In        Out     Expected   Actual   Variance
Cash                  25,000   182,000   171,500    35,500    35,500       0
bKash float           80,000   120,500   112,000    88,500    88,500       0
Nagad float           40,000    55,000    48,200    46,800    46,800       0
GP load                5,000     0         2,300     2,700     2,700       0

লেনদেন: 142   |   মোট কমিশন: ৳ 1,180   |   খরচ: ৳ 350   |   নিট লাভ: ৳ 830
```

*(Figures are illustrative only.)*
