#!/usr/bin/env bash
# Builds the production Android App Bundle with live AdMob units.
#
#   tool/build_release.sh            # app bundle (.aab)
#   tool/build_release.sh apk        # split-per-ABI APKs
#
# Live IDs are read from ads.live.env (git-ignored) or from the environment
# (ADMOB_APP_ID, ADMOB_BANNER_ID, ADMOB_INTERSTITIAL_ID), e.g. CI secrets.
# Beta and internal-testing builds must NOT use this script: build them
# without ADS_MODE so they use Google's test ad units.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f ads.live.env ]; then
  set -a
  # shellcheck disable=SC1091
  source ads.live.env
  set +a
fi

: "${ADMOB_APP_ID:?ADMOB_APP_ID is not set}"
: "${ADMOB_BANNER_ID:?ADMOB_BANNER_ID is not set}"
: "${ADMOB_INTERSTITIAL_ID:?ADMOB_INTERSTITIAL_ID is not set}"

target="${1:-appbundle}"
case "$target" in
  appbundle) extra=() ;;
  apk) extra=(--split-per-abi) ;;
  *) echo "usage: $0 [appbundle|apk]" >&2; exit 2 ;;
esac

# The live app ID goes into the manifest through the environment variable
# read by android/app/build.gradle.kts.
export ADMOB_APP_ID

flutter build "$target" --release --flavor prod -t lib/main_prod.dart \
  "${extra[@]}" \
  --dart-define=ADS_MODE=live \
  --dart-define="ADMOB_BANNER_ID=${ADMOB_BANNER_ID}" \
  --dart-define="ADMOB_INTERSTITIAL_ID=${ADMOB_INTERSTITIAL_ID}"
