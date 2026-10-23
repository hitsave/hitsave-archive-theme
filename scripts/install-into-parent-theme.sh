#!/usr/bin/env sh
# Build HitSaveArchive (Foundation S + overlay) and merge into the Omeka theme directory.
#
# Intended layout on the server (e.g. mario):
#   themes/HitSaveArchive/           ← Omeka theme root (install target)
#   themes/hitsave-archive-theme/    ← this git clone (sibling)
#
# Run from the clone:
#   ./scripts/install-into-parent-theme.sh
#
# Optional: ./scripts/install-into-parent-theme.sh /path/to/themes/HitSaveArchive
# Override theme folder name: HITSAVE_OMEKA_THEME_DIR=HitSaveArchive
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
THEME_NAME="${HITSAVE_OMEKA_THEME_DIR:-HitSaveArchive}"

if [ "$#" -ge 1 ]; then
  INSTALL_DIR="$(CDPATH= cd -- "$1" && pwd)"
else
  THEMES_DIR="$(CDPATH= cd -- "$REPO_ROOT/.." && pwd)"
  INSTALL_DIR="$THEMES_DIR/$THEME_NAME"
fi

case "$INSTALL_DIR" in
  /|/usr|/usr/*|/var|/var/*)
    echo "Refusing to install into system path: $INSTALL_DIR" >&2
    exit 1
    ;;
esac

if [ "$INSTALL_DIR" = "$REPO_ROOT" ]; then
  echo "Install directory must be the Omeka theme folder ($THEME_NAME), not this repo." >&2
  exit 1
fi

REPO_PARENT="$(CDPATH= cd -- "$REPO_ROOT/.." && pwd)"
INSTALL_PARENT="$(CDPATH= cd -- "$INSTALL_DIR/.." && pwd)"
if [ "$REPO_PARENT" != "$INSTALL_PARENT" ]; then
  echo "Warning: repo and theme dir are not siblings under the same parent." >&2
  echo "  repo:   $REPO_ROOT" >&2
  echo "  theme:  $INSTALL_DIR" >&2
fi

FOUNDATION="$REPO_ROOT/foundation-theme"
REF="$(tr -d ' \n\r' <"$REPO_ROOT/FOUNDATION_S_GIT_REF")"

if [ ! -d "$FOUNDATION" ]; then
  echo "Cloning Foundation S ${REF} into $FOUNDATION …"
  git clone --depth 1 --branch "$REF" \
    https://github.com/omeka-s-themes/foundation.git "$FOUNDATION"
fi

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/hitsave-archive-theme-stage.XXXXXX")"
cleanup() {
  rm -rf "$STAGE"
}
trap cleanup EXIT INT HUP TERM

echo "Building into staging directory …"
"$SCRIPT_DIR/build-hitsave-archive-theme.sh" "$FOUNDATION" "$STAGE" "$REPO_ROOT"

mkdir -p "$INSTALL_DIR"
echo "Installing into $INSTALL_DIR …"
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$STAGE/" "$INSTALL_DIR/"
else
  echo "rsync is required for install merge." >&2
  exit 1
fi

echo "Done. Omeka theme files updated under: $INSTALL_DIR"
echo "Restart PHP/Omeka if OPcache serves stale templates (e.g. docker compose restart omeka)."
