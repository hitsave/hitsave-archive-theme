#!/usr/bin/env bash
# Compare pinned Foundation S tag to latest GitHub release (informational).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIN_FILE="$ROOT/FOUNDATION_S_GIT_REF"
REPO="omeka-s-themes/foundation"

if [[ ! -f "$PIN_FILE" ]]; then
  echo "Missing pin file: $PIN_FILE" >&2
  exit 1
fi

PIN="$(tr -d ' \n\r' <"$PIN_FILE")"
if [[ -z "$PIN" ]]; then
  echo "Empty pin in $PIN_FILE" >&2
  exit 1
fi

LATEST=""
if command -v gh >/dev/null 2>&1; then
  LATEST="$(gh api "repos/${REPO}/releases/latest" --jq .tag_name 2>/dev/null || true)"
fi
if [[ -z "$LATEST" ]]; then
  LATEST="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tag_name',''))" 2>/dev/null || true)"
fi

echo "Foundation S upstream: https://github.com/${REPO}"
echo "Pinned (this repo):    ${PIN}"

if [[ -z "$LATEST" ]]; then
  echo "Could not fetch latest release tag (network or API limit)." >&2
  exit 0
fi

echo "Latest GitHub release: ${LATEST}"

if [[ "$PIN" == "$LATEST" ]]; then
  echo "Pin is up to date with latest release."
  exit 0
fi

echo ""
echo "Action: review Foundation release notes, bump FOUNDATION_S_GIT_REF and"
echo "config/foundation-theme-upstream.yml, rebuild HitSaveArchive, and test overlay merges."
echo "See README.md"
exit 1
