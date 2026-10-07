# Hit Save Archive — Omeka S theme overlay

**HitSaveArchive** is an open-source Omeka S theme for [Hit Save! Archive](https://archive.hitsave.org): family-site chrome (hitsave.org / preserve.games), a discovery hub homepage, dark/light mode, and item citation UX. It is built as a **fork-style overlay** on the official **Foundation S** theme, not a from-scratch theme.

## Built on Foundation S

| | |
|---|---|
| **Upstream** | [omeka-s-themes/foundation](https://github.com/omeka-s-themes/foundation) (**Foundation S**) |
| **Pinned release** | **`v1.5.3`** (Omeka theme version **1.5.3**) |
| **Upstream license** | [GNU GPL v3.0 or later](https://www.gnu.org/licenses/gpl-3.0.html) |
| **Pin files** | `FOUNDATION_S_GIT_REF` (git tag) and [`config/foundation-theme-upstream.yml`](config/foundation-theme-upstream.yml) |

Foundation S provides Omeka view templates, ZURB Foundation CSS/JS, browse/show layouts, and theme settings. This repository **overrides** a small set of views and adds CSS/JS and extra `theme.ini` fields. The rest of Foundation remains in the built theme.

See [COPYING.md](COPYING.md) for attribution and redistribution notes.

## Build the installable theme

1. Clone [Foundation S](https://github.com/omeka-s-themes/foundation) at the tag in **`FOUNDATION_S_GIT_REF`** (or let your CI fetch it).

2. From this repository root:

```bash
git clone --depth 1 --branch "$(tr -d ' \n\r' < FOUNDATION_S_GIT_REF)" \
  https://github.com/omeka-s-themes/foundation.git foundation-theme

./scripts/build-hitsave-archive-theme.sh \
  ./foundation-theme \
  ./HitSaveArchive \
  .
```

3. Copy **`HitSaveArchive`** into your Omeka S `themes/` directory and activate **Hit Save Archive** for your site.

The output folder name becomes the theme id Omeka sees (`HitSaveArchive`).

## What the overlay changes

**Replaced Foundation views (same path):**

- `view/layout/layout.phtml` — family chrome, theme assets, Foundation init
- `view/omeka/site/item/browse.phtml`, `item/show.phtml`, `page/show.phtml`
- `view/common/block-layout/browse-preview.phtml`

**Added partials:** `hitsave-family-bar`, `hitsave-header-dropdown`, `hitsave-discovery-hub`, `hitsave-theme-toggle`, citation/footer/wordmark, etc.

**Assets:** `asset/css/hitsave-archive.css`, `hitsave-theme-modes.css`, `asset/js/hitsave-site-nav.js`, `hitsave-theme-mode.js`.

**Config:** `config/theme-hitsave-elements.ini` appended to `theme.ini` at build time.

Everything else in the merged **`HitSaveArchive`** folder is still upstream Foundation.

Optional default copy for theme settings (family URLs, homepage hero): [`examples/archive-theme.defaults.yaml`](examples/archive-theme.defaults.yaml).

## When Foundation S releases a new version

1. Run `./scripts/check-foundation-theme-upstream.sh` (compares pin to latest GitHub release).

2. Bump the pin in **`FOUNDATION_S_GIT_REF`** and **`config/foundation-theme-upstream.yml`**.

3. Rebuild, diff upstream template changes, merge into the five overridden `.phtml` files if needed, and smoke-test browse, item show, homepage hub, dark/light toggle, and search.

The Omeka **`theme.ini` `version`** field stays aligned with **Foundation S’s version** at the pin so admins can see which upstream base was used.

## License

GPL-3.0-or-later (combined with Foundation S). See [COPYING.md](COPYING.md).
