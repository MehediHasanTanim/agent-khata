# Agent Khata

Offline-first, Bangla-first cash book for bKash / Nagad / Rocket agents and
flexiload retailers in Bangladesh. Android package: `com.nextgenai.agentkhata`.

Specs live in [`docs/`](docs): feature spec, technical design, sprint plan.

## Status

Sprint 0 (foundations) — see `docs/plan/agent-cashbook-sprint-plan.md`.

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
- Local `flutter test` on macOS needs the Xcode command line tools
  (`xcode-select --install`); some native-asset hooks call `xcrun`.
