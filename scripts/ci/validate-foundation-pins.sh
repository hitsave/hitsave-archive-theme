#!/usr/bin/env bash
# Ensure prod pin (FOUNDATION_S_GIT_REF) matches CI deploy.latest_foundation_ref.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PIN_FILE="$ROOT/FOUNDATION_S_GIT_REF"
CONFIG="$ROOT/config/foundation-build-pins.yml"

if [[ ! -f "$PIN_FILE" ]]; then
  echo "Missing $PIN_FILE" >&2
  exit 1
fi
if [[ ! -f "$CONFIG" ]]; then
  echo "Missing $CONFIG" >&2
  exit 1
fi

PIN="$(tr -d ' \n\r' <"$PIN_FILE")"
eval "$(python3 "$ROOT/scripts/ci/foundation_build_pins.py" --format env)"
LATEST="$HITSAVE_LATEST_FOUNDATION_REF"

if [[ -z "$PIN" ]]; then
  echo "Empty pin in $PIN_FILE" >&2
  exit 1
fi
if [[ "$PIN" != "$LATEST" ]]; then
  echo "FOUNDATION_S_GIT_REF ($PIN) != deploy.latest_foundation_ref ($LATEST) in $CONFIG" >&2
  echo "Keep them in sync when changing the production Foundation base." >&2
  exit 1
fi

python3 "$ROOT/scripts/ci/foundation_build_pins.py" >/dev/null
echo "Foundation pins OK (prod pin $PIN)."
