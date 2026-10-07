#!/bin/sh
# Build HitSaveArchive from Foundation + themes/hitsave-archive-overlay (Omeka S theme dir name = folder name).
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
cp -a "$OVERLAY/." "$OUT/"

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
  -e "s/^description = .*/description = \"Hit Save Archive: Foundation S ${FOUNDATION_REF:-(see FOUNDATION_S_GIT_REF)} overlay (GPL-3.0). See https:\/\/github.com\/jonasrosland\/hitsave-archive-theme.\"/" \
  "$THEME_INI"

if [ -f "$OVERLAY/config/theme-hitsave-elements.ini" ]; then
  printf '\n' >> "$THEME_INI"
  cat "$OVERLAY/config/theme-hitsave-elements.ini" >> "$THEME_INI"
fi

echo "Built HitSaveArchive at $OUT"
