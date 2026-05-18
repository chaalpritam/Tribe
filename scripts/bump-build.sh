#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="$ROOT/Tribe/Info.plist"
PROJECT_YML="$ROOT/Project.yml"

current="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST" 2>/dev/null || echo 0)"
next=$((current + 1))

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $next" "$PLIST"
if [[ -f "$PROJECT_YML" ]]; then
  sed -i '' -E "s/CURRENT_PROJECT_VERSION: \"[0-9]+\"/CURRENT_PROJECT_VERSION: \"$next\"/" "$PROJECT_YML"
fi

echo "Build number bumped: $current → $next"
echo "Run 'make generate' if you use xcodegen."
