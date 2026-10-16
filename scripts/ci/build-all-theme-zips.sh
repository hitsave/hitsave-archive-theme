#!/usr/bin/env bash
# Build HitSaveArchive zips for each configured Foundation pin + HitSaveArchive-latest.zip.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DIST="$ROOT/dist"
WORK="$ROOT/build/ci"
FOUNDATION_REPO="${HITSAVE_FOUNDATION_REPO:-https://github.com/omeka-s-themes/foundation.git}"

"$ROOT/scripts/ci/validate-foundation-pins.sh"

mkdir -p "$DIST" "$WORK"
rm -rf "$DIST"/*.zip "$WORK"/*

CFG_JSON="$(python3 "$ROOT/scripts/ci/foundation_build_pins.py")"
LATEST_REF="$(python3 -c "import json,sys; c=json.load(sys.stdin); print(c['latest_foundation_ref'])" <<<"$CFG_JSON")"
OVERLAY_SHA="${GITHUB_SHA:-$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)}"
OVERLAY_REF="${GITHUB_REF_NAME:-$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)}"
BUILT_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

build_one() {
  local ref="$1"
  local version="$2"
  local foundation_dir="$WORK/foundation-${version}"
  local theme_dir="$WORK/HitSaveArchive"

  rm -rf "$foundation_dir" "$theme_dir"
  git clone --depth 1 --branch "$ref" "$FOUNDATION_REPO" "$foundation_dir"

  HITSAVE_FOUNDATION_REF_OVERRIDE="$ref" \
    "$ROOT/scripts/build-hitsave-archive-theme.sh" \
    "$foundation_dir" \
    "$theme_dir" \
    "$ROOT"

  python3 - "$theme_dir" "$ref" "$version" "$OVERLAY_SHA" "$OVERLAY_REF" "$BUILT_AT" <<'PY'
import json
import sys
from pathlib import Path

theme_dir, ref, version, overlay_sha, overlay_ref, built_at = sys.argv[1:7]
info = {
    "artifact": "HitSaveArchive",
    "foundation_ref": ref,
    "foundation_version": version,
    "overlay_repository": "https://github.com/hitsave/hitsave-archive-theme",
    "overlay_sha": overlay_sha,
    "overlay_ref": overlay_ref,
    "built_at": built_at,
}
Path(theme_dir, "BUILD_INFO.json").write_text(
    json.dumps(info, indent=2) + "\n", encoding="utf-8"
)
PY

  local zip_name="HitSaveArchive-foundation-${version}.zip"
  (cd "$WORK" && zip -qr "$DIST/$zip_name" HitSaveArchive)
  echo "Wrote $DIST/$zip_name"
  rm -rf "$foundation_dir" "$theme_dir"
}

while IFS= read -r line; do
  ref="$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['ref'])" "$line")"
  version="$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['version'])" "$line")"
  build_one "$ref" "$version"
done < <(python3 -c "import json,sys; c=json.load(sys.stdin);
[print(json.dumps(p)) for p in c['foundation_pins']]" <<<"$CFG_JSON")

LATEST_VERSION="$(python3 -c "import json,sys; c=json.load(sys.stdin);
print(next(p['version'] for p in c['foundation_pins'] if p['ref']==c['latest_foundation_ref']))" <<<"$CFG_JSON")"
cp "$DIST/HitSaveArchive-foundation-${LATEST_VERSION}.zip" "$DIST/HitSaveArchive-latest.zip"
echo "Wrote $DIST/HitSaveArchive-latest.zip (Foundation ${LATEST_REF})"

ls -la "$DIST"
