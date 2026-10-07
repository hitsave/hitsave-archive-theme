#!/bin/sh
# Build HitSaveArchive from Foundation S + overlay (Omeka theme dir name = output folder name).
set -eu

FOUNDATION="${1:?foundation theme path}"
OUT="${2:?output theme path}"
OVERLAY="${3:?overlay directory}"

if [ ! -d "$FOUNDATION" ]; then
  echo "Foundation theme not found: $FOUNDATION" >&2
  exit 1
fi
if [ ! -d "$OVERLAY" ]; then
  echo "Overlay not found: $OVERLAY" >&2
  exit 1
fi

rm -rf "$OUT"
cp -a "$FOUNDATION" "$OUT"
if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude='HitSaveArchive/' \
    --exclude='foundation-theme/' \
    --exclude='.git/' \
    --exclude='scripts/' \
    --exclude='examples/' \
    --exclude='.gitignore' \
    --exclude='README.md' \
    --exclude='config/foundation-theme-upstream.yml' \
    "$OVERLAY/" "$OUT/"
else
  cp -a "$OVERLAY/." "$OUT/"
fi

THEME_INI="$OUT/config/theme.ini"
if [ ! -f "$THEME_INI" ]; then
  echo "Missing theme.ini in $OUT" >&2
  exit 1
fi

FOUNDATION_REF=""
if [ -f "$OVERLAY/FOUNDATION_S_GIT_REF" ]; then
  FOUNDATION_REF="$(tr -d ' \n\r' <"$OVERLAY/FOUNDATION_S_GIT_REF")"
fi

sed -i \
  -e 's/^name = "Foundation"/name = "Hit Save Archive"/' \
  -e 's/^author = .*/author = "Hit Save! (overlay); Foundation S by Omeka Team"/' \
  -e 's|^theme_link = .*|theme_link = "https://github.com/omeka-s-themes/foundation"|' \
  -e "s/^description = .*/description = \"Hit Save Archive: Foundation S ${FOUNDATION_REF:-(see FOUNDATION_S_GIT_REF)} overlay (GPL-3.0). See https:\/\/github.com\/hitsave\/hitsave-archive-theme.\"/" \
  "$THEME_INI"

if [ -f "$OVERLAY/config/theme-hitsave-elements.ini" ]; then
  printf '\n' >> "$THEME_INI"
  cat "$OVERLAY/config/theme-hitsave-elements.ini" >> "$THEME_INI"
fi

echo "Built HitSaveArchive at $OUT"
