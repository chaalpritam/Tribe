#!/usr/bin/env bash
# Upload the IPA produced by `make archive` to App Store Connect.
# Requires: Xcode, valid DEVELOPMENT_TEAM, App Store Connect API key or interactive login.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IPA="${1:-$ROOT/build/export/Tribe.ipa}"

if [[ ! -f "$IPA" ]]; then
  echo "IPA not found: $IPA" >&2
  echo "Run: DEVELOPMENT_TEAM=XXXXXXXXXX make archive" >&2
  exit 1
fi

xcrun altool --upload-app -f "$IPA" -t ios --apiKey "${APP_STORE_CONNECT_API_KEY:-}" --apiIssuer "${APP_STORE_CONNECT_ISSUER_ID:-}" "$@"
