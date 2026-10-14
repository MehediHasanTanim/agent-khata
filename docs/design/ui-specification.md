# Agent Khata — UI / UX Specification

Purpose: a complete description of every screen, component, state and flow of the app, to hand to a designer (Claude Design) for a UX/visual redesign. It describes **what exists today** and the **constraints a redesign must respect**. Visual styling is intentionally open; behaviour, content and constraints are not.

---

## 1. Product context

**Agent Khata** is an offline-first Android cash book (khata = ledger) for Bangladeshi **mobile financial service (MFS) agents and flexiload retailers** — the person behind a small shop counter who handles bKash / Nagad / Rocket / Upay cash-in and cash-out, mobile top-ups (flexiload), small expenses and customer credit (baki), all day, all in quick succession.

- Package `com.nextgenai.agentkhata`, Flutter, Material 3, Android only (phones).
- Fully offline. No account, no cloud. Data lives on the phone, encrypted.
- Bangla-first (বাংলা default, English switchable), Bangla or Latin digits, Bangladeshi digit grouping (১,০০,০০০).
- Currency: Taka (৳), stored as integer paisa. Never shows decimals unless needed.
- Free, with ads (Google AdMob banner + occasional interstitial; non-personalized, G-rated).

### Users
| Persona | Description | Needs |
|---|---|---|
| **Owner** (primary) | Shop owner, 25–55, mid-range Android phone, limited English, often poor lighting, one-handed use, customers waiting | Record an entry in < 5 seconds, see balances at a glance, know if the day tallies, not get cheated by staff |
| **Staff** | Counter employee with own PIN | Add entries fast; sees only own entries; may or may not see profit / close the day |

### Design principles
1. **Speed at the counter**: the 4 most common entries (cash out, cash in, flexiload, expense) are one tap + amount + save.
2. **Numbers first**: balances and amounts are the hero; large, high-contrast, tabular figures.
3. **Forgiving**: everything is undoable or voidable; warnings (negative balance, large amount, duplicate) ask, never block.
4. **Trustworthy**: money apps must feel sober and exact. Every number is auditable.
5. **Low literacy / low vision friendly**: big touch targets (≥ 48dp, primary actions ≥ 76dp), big type, icons paired with words, high-contrast theme, text size up to 1.3×.
6. **Calm**: ads must never interrupt data entry or sit near money-moving buttons.

---

## 2. Global design system (current)

### Colour
- Seed `#0B6E4F` (deep green) → Material 3 `ColorScheme.fromSeed`.
- Semantic tokens beyond M3: 
  - `cashIn` light `#1B7F3B` / dark `#4ADE80` / HC `#00FF66`
  - `cashOut` light `#C2410C` / dark `#FB923C` / HC `#FFB300`
  - `warning` light `#B45309` / dark `#FBBF24` / HC `#FFFF00`
- Three themes: **Light**, **Dark**, **High contrast** (black bg, yellow primary `#FFFF00`, cyan secondary `#00E5FF`, white text).
- Amount direction is shown by colour **and** icon/sign (never colour alone).

### Typography
Larger-than-default Material scale for glanceability: display 48/40, headline 28, title 22/18, body 18/16, label 16. Font fallbacks: Noto Sans Bengali, Hind Siliguri. Text-size setting scales 1.0 / 1.15 / 1.3 — layouts must not overflow at 1.3× with Bangla (taller line height than Latin).

### Shape & spacing
Rounded 12–16dp cards/buttons, 8dp grid, 12dp screen gutters, `MaterialTapTargetSize.padded`.

### Components in use
Bottom NavigationBar (5), AppBar, Cards, ListTiles, FilledButton / FilledButton.tonal, ChoiceChips, ActionChips, SegmentedButton/Radio lists, SwitchListTile, bottom sheets, AlertDialogs, SnackBars with Undo, custom **numeric keypad**, custom **PIN pad**, custom **balance cards**, mini bar charts (CustomPainter).

### Money formatting
`৳ 12,345` (Bangla digits: `৳ ১২,৩৪৫`). Hidden-balance mask: `৳ ••••`. Money fields use a custom on-screen keypad, not the system keyboard.

### Banners (inline notices)
Rounded 12dp, tinted background (warning @15% or primary @10%), 1dp border in the same hue, leading icon, text, optional chevron. Used for: recurring expenses due, yesterday not closed, backup stale, low balance.

---

## 3. Information architecture & navigation

```
App launch
 ├─ Onboarding (first run only)
 │    Welcome → [Quick start | Step-by-step | Restore backup]
 ├─ PIN setup (first run) / Who-are-you + PIN unlock (every launch / auto-lock)
 └─ App shell — bottom navigation (5 tabs)
      1. Home          → Entry (6 kinds), Bulk flexiload, Dues, Account ledger,
                         Transaction detail, Recurring due, Shift handover
      2. History       → Transaction detail → Edit / Void
      3. Close day     → Cash counter sheet, Reason chooser, Daily summary (+share)
      4. Reports       → Insights, Variance charts, Commission, CSV, Statement PDF, Daily sheet
      5. Settings      → Low alerts, Recurring expenses, Staff, Backup, Commission rates,
                         Categories, About, Diagnostics
```

Role differences: Staff without “see profit” don't see profit figures or Reports; without “close day” don't see Close day action; Settings subsections (Staff, Backup, Rates…) are owner-only.

---

## 4. Screen specifications

Each screen: **purpose · layout · content · states · actions · notes**.

### 4.1 Onboarding flow (`onboarding_flow`)
Full-screen wizard, no bottom nav, Back/Next. Progress implied by steps.

1. **Welcome** — App name “Agent Khata”, body “Set up your cash book in about two minutes.” Three actions: **Quick start with defaults** (primary), **Set up step by step**, **Restore from a backup**.
2. **Wallets** — “Which wallets do you run?” multi-select of providers (bKash, Nagad, Rocket, Upay, …) with logo/colour chips; subtitle “Pick all that apply. You can add more later.”
3. **Flexiload operators** — multi-select (Grameenphone, Robi, Banglalink, Airtel, Teletalk).
4. **Opening balances** — one money field per selected wallet/operator + “Cash in drawer”. Subtitle “Enter what you have right now.” Uses the keypad.
5. **Commission rates** — sample rate per wallet (per ৳1,000 / % / fixed). Notice: “These are sample rates only. Please check them with your provider.”
6. **Shop name** — text field, hint “e.g. Rahim Telecom”, optional.
7. **Finish setup** — button; shows “Setting up…” then goes to PIN setup. Error: “Could not finish setup. Please try again.”

### 4.2 PIN screens (`lock/*`)
- **PIN setup**: title “Set a PIN”, subtitle (4–6 digits), then “Confirm your PIN”. Dots indicator + custom numeric PIN pad (0–9, delete, clear). Mismatch error inline.
- **Unlock**: “Enter PIN”. Dots, PIN pad, optional **fingerprint** button (“Use fingerprint”). Wrong-PIN message with attempts remaining; lock-out countdown “Try again in N seconds”.
- **Who are you?** (when staff exist): list of users (Owner + staff) → then PIN.
- Behaviour: auto-lock after N seconds in background; app preview hidden / screenshots blocked (secure flag, toggle).
- Notes: PIN pad keys ≥ 72dp, haptic on press, shake on error, no PIN shown in plain.

### 4.3 App shell (`shell/app_shell`)
- Body = selected tab. Bottom = **[Ad banner slot] above [NavigationBar]**.
- Tabs: Home, History, Close day, Reports, Settings (icon + label each).
- Ad banner: ≈50–60dp adaptive, labelled “Advertisement” for screen readers, collapses to zero height when no ad / keyboard open. Never shown on Entry, PIN, Close day, Keypad or any money-confirm screen.

### 4.4 Home (`home/home_screen`)
Purpose: instant situational awareness + one-tap entry. Scrollable column:

1. **AppBar**: “Agent Khata”; trailing user chip (person icon + “Owner” or staff name) → locks/switch user.
2. **Notice banners** (0–4, stacked, each dismiss-by-resolving):
   - Recurring expenses due (“N recurring expenses are due”) → Recurring due screen
   - Yesterday not closed (“Yesterday's accounts are not closed”) → Close day for that date
   - Backup stale (“Back up your data to keep it safe”) → Backup
   - Low balance (“Low balance: bKash, Cash”) — warning style
3. **Shift card** (if a shift is open): badge icon, “Shift: Rahim”, “since 10:30 AM”, trailing **Hand over** button.
4. **Balance cards** — horizontally scrolling row of equal-height cards: **Cash**, one per wallet (bKash, Nagad, Rocket…), and one combined **Flexiload** total. Each card: label (18), amount (28, bold), optional “Low” badge, optional “Tap to show” when balances are masked. Tap → that account's ledger. Min width 148dp. Must size to content (no fixed height; must survive 1.3× Bangla text).
5. **Action grid** (2 × 3, tonal tiles ≥ 76dp tall, icon 28 + label 18, tinted per direction):
   Cash out ↗ · Cash in ↙ · Flexiload 📱 · Buy float 👛 · Expense 🧾 · Baki (dues)
6. **Regulars** (optional): label “Regulars”, horizontally wrapping ActionChips of frequent customers (name/number + “N times”) → opens entry prefilled.
7. **Today** section: 4 stat tiles — Entries, Cash in, Cash out, Commission (commission hidden if no profit permission).
8. **Last 5 entries**: ListTiles — type icon, title (type label), subtitle (customer number/note), trailing amount in direction colour with sign; voided entries struck through with “Voided” tag. Empty: “No entries yet. Tap a button above to start.”

Interactions: after saving an entry a SnackBar “Saved” with **Undo** (5 s). Pull-to-refresh not needed (reactive).
Interstitial ad may follow a shift handover (policy-limited).

### 4.5 Entry screen (`entry/entry_screen`)
One screen, six modes via `EntryKind`: **Cash out, Cash in, Flexiload, Buy float, Expense, Commission received** (+ **Edit entry** mode).
- **AppBar**: mode title; action icon “Bulk flexiload” in Flexiload mode.
- **Scrollable form** (top):
  - *Wallet* / *Operator* chips (ChoiceChips, brand-coloured) — required.
  - *Paid from* chips (cash / which wallet) for float purchase / expense.
  - *Category* chips for expense + “New category” chip → small dialog.
  - *Regulars* chips for quick customer pick.
  - **Live preview line**: “Commission: ৳ 25” or “Margin: ৳ 8” (success colour); “Last: ৳ 5,000” tap-to-repeat.
  - **Negative-balance warning** inline: “{account} will go below zero” (warning colour).
  - **More details (optional)** expansion: Customer number (autocomplete from remembered customers), Customer name, Amount paid (if different), TrxID, Note.
- **Amount display**: very large (display 40–48) amount, sign/colour by direction, shown above keypad.
- **Custom keypad** (bottom, thumb zone): 0–9, 00, backspace, quick-amount chips (100 / 500 / 1,000 / last), full-width **Save** button (≥ 56dp).
- **Dialogs**: Large amount (“{amount} is a large amount. Save it?”), Possible duplicate (“A similar entry was saved a moment ago. Save again?”) → Cancel / Save anyway.
- **Errors** (snackbar): save failed, day closed (“This day is closed. Reopen it from Close day…”), permission denied.
- **Empty state**: “Add a wallet first” / “Add a flexiload operator first”.
- No ads on this screen.

### 4.6 Bulk flexiload (`entry/bulk_flexiload_screen`)
Purpose: record many top-ups at once (end-of-day catch-up).
- Operator chips; list of rows (Number optional · Price) with add/remove; **Add row**, **Paste list** (multi-line dialog: “One load per line: number and amount, like 01712345678 100”, “N lines skipped”).
- Per-row validation chips: “Check the number”, “Same number and amount twice”.
- Footer summary: “12 loads · ৳ 1,200” and “Margin ৳ 96”; low-balance warning; **Save all (12)** button.

### 4.7 Transaction detail (`history/transaction_detail_screen`)
- Header: type icon, big amount, status chips (Voided / Closed day).
- Key-value list: Amount, Charge, Commission, Rate used, Time, Recorded at, Entered by, Accounts (from → to), Customer, TrxID, Note.
- **Change history** (audit list, timeline style).
- Replaced-by / Replaces links.
- Actions: **Edit**, **Void entry** (dialog asks Reason, confirm “Void”). Disabled with hint “This day is closed, so the entry cannot be changed.” on closed days.

### 4.8 History (`history/history_screen`)
- AppBar “History” + search field (“Search amount, number, note, TrxID”).
- Filter chips row: Today · Yesterday · Week · Month · All; Account dropdown (“All accounts”) and type chips; “Clear filters”.
- Summary line: “42 entries · Total ৳ 1,23,000”.
- Grouped list (by date headers) of entry tiles (as Home) with time; infinite “Load more”.
- Empty: “Nothing found”. Staff see only own entries.

### 4.9 Account ledger (`accounts/account_ledger_screen`)
- Title “{Account} statement”; date-range selector.
- Table-like list: Date · Description · In (green) · Out (orange) · running Balance. Opening/closing row.
- Actions: **Adjust balance**, share **Statement PDF**.
- Empty: “No entries in this period”.

### 4.10 Adjust balance (`accounts/adjustment_screen`)
Segmented **Increase / Decrease**, amount via keypad, required **Reason**, live “Current balance → New balance” preview, Save. Owner only.

### 4.11 Dues / Baki (`dues/*`)
- **Dues list**: two tabs/segments — “They owe me” / “I owe them”; total headline (“Total to collect ৳ …”); search (“Search name or number”); list of people with name, phone, remaining amount, age; **Add baki** FAB. Empty: “No open dues”.
- **New baki form**: Type (they owe me / I owe them), Name, Phone (at least one), Amount, “Given from” (cash/wallet), “What for”, Save.
- **Due detail**: person header with **Call** and **SMS** buttons, “Original ৳ / Remaining ৳”, progress bar, Payments list (“No payments yet”), **Record payment** → bottom sheet (“Full amount” shortcut, amount, “Received in”/“Paid from” account chips, over-settle warning).

### 4.12 Close day (`closeday/*`) — tab + flow
Tab shows: day selector (“Which day?”), status (Open / Closed / Reopened), **Recent days** list, then the closing flow:
1. **Intro**: “Count your cash and wallet balances. We will show where any gap may be.”
2. **Count table**: one row per account — Expected (book balance) | Actual (input, “Leave empty if it matches”). Cash row has **Count notes** → **Cash counter sheet** (denomination steppers ৳1000/500/200/100/50/20/10/5/2/1 + coins, running total, “Use this total”).
3. **Review**: per-account result chip — Matches ✓ / Short by ৳X / Excess of ৳X; for each difference a **Reason** picker (Shortage, Excess, Provider charge, Counting error, Small difference, Other) + optional note; “Where could it be?” expands **gap suggestions** (e.g. “An entry of ৳500 is the same size as the gap…”, digits swapped, wrong direction, duplicate) with **Add a missing entry** shortcut. Footer: “Differences up to ৳X are written off automatically”.
4. **Close the day** button (primary, confirm) → success “Day closed” → **Daily summary**.
- **Reopen** (only most recent closed day): dialog “Reopen this day?” + reason.
- Interstitial ad may follow leaving the summary (frequency-capped).

### 4.13 Daily summary (`closeday/daily_summary_screen`)
Printable-style summary card: Entries, Cash-in total, Cash-out total, Commission, Flexiload margin, Expenses, **Net profit** (large), Difference. Per-account table Opening · In · Out · Closing. Actions: **Share image**, **Share PDF**, **Print sheet** (paper-style daily sheet with “Prepared by / Checked by” signature boxes). “Not closed yet” state.

### 4.14 Shift handover (`shifts/shift_handover_screen`)
Intro (“Count the cash and wallets before handing over…”), same count table as Close day, per-operator variance (“Short ৳X”), result summary, **Hand over**. Lists **Recent shifts** with difference per shift.

### 4.15 Reports (`reports/reports_screen`)
Scroll of cards, period switcher (This week / This month, Previous / Next):
1. **Net profit per day** — bar chart.
2. **By type** — breakdown list/bars (commission, margin, expenses…).
3. **Insights** — Average entry size, Busiest hour, Most profitable hour, Best weekday; charts “Entries by hour of day”, “Average profit by weekday”, “Average size by type”. Empty: “Not enough entries yet… (at least 10 needed)”.
4. **Day-close differences** — bar per day (short = orange down, excess = up), date labels; “By account (last 30 closed days)”, “Differences by weekday”, “Short most often on Friday: 4 of 12 closed days”.
5. **Commission: expected vs received** — Expected / Received / Pending + **Record commission received**.
6. Export: **Export CSV**, **Statement PDF**.
Staff without profit permission don't see this tab.

### 4.16 Settings (`settings/settings_screen`)
Grouped list with section headers (radio groups and switches):
- Language (বাংলা / English) · Digit style (Bangla/Latin) · Bangladeshi grouping switch
- Theme (Light / Dark / High contrast) · Text size (Normal / Large / Extra large)
- Security: Auto-lock after (Immediately / 15s / 30s / 60s…), Unlock with fingerprint, Hide preview & block screenshots, Lock now, Switch user (shows “Signed in as …”)
- Privacy toggles: Share anonymous usage counts, Remember customers
- Business: Shop name, Business day starts at (rollover hour), Ignore differences up to ৳X, Day-close reminder (+ time), Large-amount warning threshold, Hide balances until tapped
- Navigation rows: Low balance alerts · Recurring expenses · Staff · Backup and restore · Commission rates · Expense categories
- Footer rows: About · Diagnostics · **Ad privacy options** (only where required)

### 4.17 Commission rates (`commission/commission_rates_screen`)
List per wallet/operator; each row editable: mode **Per ৳1,000 / Percent / Fixed ৳ / By amount (tiers)**, value; tier editor (“Up to ৳… → rate”, “Above”, “Add tier”) with order validation; warnings (“This looks too high”); note “A new rate applies to new entries only.”

### 4.18 Low balance alerts (`accounts/low_alerts_screen`)
One money field per account (empty = no alert), subtitle “Warn me when an account falls to this amount.”

### 4.19 Recurring expenses (`expenses/recurring_screens`)
- **List**: label, amount, “Every month · day 5” / weekly, “Next: 12 Nov”, Paused tag; FAB **Add recurring expense**. Empty: “No recurring expenses yet. Add rent, internet…”.
- **Form**: category, amount, Repeats (monthly/weekly), day-of-month or weekday picker, hint “Months with fewer days use the last day”, active switch.
- **Due screen**: cards of due items with **Record** / **Skip**.

### 4.20 Staff (`staff/staff_screen`)
- List: avatar initial, name, role, Inactive tag; FAB **Add staff**; info card “Each staff member signs in with their own PIN…”.
- **Form**: Name, PIN (4–6 digits), switches “Can see profit and reports”, “Can close the day”; actions Reset PIN, Deactivate/Activate. Errors: PIN in use.

### 4.21 Backup & restore (`backup/*`)
- Status card: “Last backup: …” or “No backup yet”, explanation “Keep your books safe…”.
- **Back up now** → passphrase + repeat (warn: cannot be recovered) → progress “Creating backup…” → system share sheet (Drive, WhatsApp…).
- **Restore from a backup file** → file picker → passphrase → info “Backup made on …” → destructive confirm dialog → “Restoring…” → “Close app”.
- Errors: wrong passphrase, damaged file, newer version.

### 4.22 Categories (`settings/categories_screen`)
Expense categories list with Rename / Remove, **Add category**. Defaults: Rent, Electricity, Transport, Staff pay, Tea & snacks, Other.

### 4.23 About (`settings/about_screen`)
App name/version, disclaimer (not affiliated with bKash/Nagad/Rocket/Upay), privacy statement, ads disclosure, licences.

### 4.24 Diagnostics (`diagnostics/diagnostics_screen`)
Technical: encryption status, journal mode, schema version, DB size, entry count, cold-start time, write-speed test button, **Books check** (“Books verified: every entry balances”), Ads status line, **Share diagnostics report**. Low-priority screen.

### 4.25 Debug ledger (`debug/ledger_debug_screen`)
Developer-only, hidden. Not part of the design.

---

## 5. Cross-cutting UX behaviours

| Topic | Behaviour |
|---|---|
| **Undo** | After save: SnackBar “Saved · Undo” 5 s (voids entry). |
| **Void vs delete** | Entries are never deleted; they are voided with reason and shown struck-through. |
| **Closed days** | Entries/edits blocked; clear explanation + path to Reopen. |
| **Warnings** | Non-blocking confirm dialogs (large amount, duplicate, negative balance). |
| **Masked balances** | Optional: amounts show `৳ ••••` until tapped, per card. |
| **Empty states** | Every list has a friendly sentence + the primary action to fill it. |
| **Loading** | Local DB so near-instant; use skeleton/shimmer only for reports/PDF. |
| **Errors** | Plain-language snackbars; never raw exceptions. |
| **Notifications** | Daily “Time to close the day”, “Low balance”, “Expense due” (local). |
| **Haptics / sound** | Light haptic on keypad and save; optional. |
| **Offline** | Always; no network states in UI except ads. |
| **Accessibility** | TalkBack labels on all icons, 48dp targets, sufficient contrast in all 3 themes, text up to 1.3×, no colour-only meaning. |
| **Localisation** | All strings in ARB (en/bn); layouts must accommodate Bangla being ~10–25% wider and taller; dates in Bangla months/digits. |

## 6. Advertising constraints (design must honour)
- One **adaptive banner** pinned above the bottom nav (or `AdFooter` at the end of read-only screens like About/Reports lists). Reserve ~50–60dp; collapse when empty.
- **Never** on: PIN screens, Entry, Bulk entry, keypad sheets, Close-day counting/review, Backup/Restore, destructive dialogs.
- **Interstitial** only at natural breaks: after leaving Daily summary, after Shift handover; ≤ 3/day, ≥ 15 min apart, never in first 3 minutes, never mid-task.
- Banner must be visually separated (label “Advertisement”, divider) so it can't be mistaken for an action.

## 7. What we want from the redesign
1. A cohesive visual identity (green-led, trustworthy, warm — not “banking cold”) with refined cards, spacing, iconography and the three themes.
2. A Home that communicates “cash position + what to do next” in under 2 seconds; rethink balance cards and the action grid (grouping, hierarchy, thumb reach).
3. A faster, more tactile **Entry + keypad** experience (one-handed, large amount focus, smart defaults).
4. A clearer **Close day** story: guided, progress-aware, with delightful “all matches ✓” moment and friendly gap-finding.
5. Reports that are readable by non-analysts: bigger charts, plain-language headlines (“You earn most on Fridays”).
6. Consistent empty/error/loading patterns and illustration style.
7. Bangla typography polish: weights, line-height, numerals alignment (tabular figures), no clipping.
8. Tablet / large-text resilience and a proper dark & high-contrast variant.

### Deliverables requested
- Style guide (colour, type, spacing, elevation, iconography, motion).
- High-fidelity mockups for: Onboarding, PIN, Home, Entry (cash out + flexiload), History, Transaction detail, Close day (count + review + success), Daily summary, Reports, Dues, Settings, Backup — in Bangla and English, light and dark.
- Component library (balance card, action tile, keypad, banner, chip, list tile, charts, ad slot).
- Key micro-interactions (save → undo snackbar, reveal balance, close-day success).

## 8. Source of truth
Strings: `lib/l10n/app_en.arb` / `app_bn.arb`. Theme: `lib/core/theme/`. Screens: `lib/features/*`. Product spec: `docs/feature/`, technical design: `docs/design/`.
