# Release checklist (beta / internal testing)

## Build and signing

- [ ] Create an upload keystore; put `storeFile`, `storePassword`,
      `keyAlias`, `keyPassword` in `android/key.properties` (git-ignored).
      Without it the release falls back to the debug key.
- [ ] Bump `version:` in `pubspec.yaml` (name+build number).
- [ ] `flutter build appbundle --release --flavor prod -t lib/main_prod.dart`
- [ ] Upload the `.aab` to the Play **internal testing** track; enable Play
      App Signing.
- [ ] CI is green (format, analyze, full `flutter test`, debug APK).

## Measure on a real 2 to 3 GB phone (cannot be done in CI)

- [ ] **S0-04 SQLCipher decision**: Settings > Diagnostics shows encryption
      status, cold start and the 1,000-insert write test. Record the numbers
      in README ("S0-04 decision").
- [ ] **S5-07**: cold start under 2 s; save under 300 ms; scroll History with
      10,000+ rows (use the dev "Ledger debug harness" to seed); APK size per
      ABI from `--split-per-abi`.
- [ ] Time the 5-second cash-out entry with a real agent.

## Functional pass on device

- [ ] Onboarding (quick start and step by step), PIN, fingerprint
- [ ] Cash in/out, flexiload, float purchase, expense; undo; edit; void
- [ ] Day close with a deliberate gap; hints; reopen and re-close
- [ ] Share summary image and PDF to WhatsApp
- [ ] Backup, then restore on a second phone (and on the same phone)
- [ ] Notification permission prompt; reminder fires; low-balance alert
- [ ] Block screenshots on; recents preview blank
- [ ] TalkBack: home actions, keypad, save button, balances
- [ ] Text size "Extra large" and system font 1.5x: no clipped text
- [ ] Bangla copy read-through by a native speaker

## Store

- [ ] Listing text (docs/release/store-listing.md), screenshots, icon
- [ ] Privacy policy URL (docs/release/privacy-policy.md, hosted)
- [ ] Data safety form (docs/release/data-safety.md)
- [ ] Disclaimer present in the description and in Settings > About
