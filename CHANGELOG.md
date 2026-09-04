# Changelog

**Note:** This project uses git SHAs instead of semver. Pin to a specific SHA in your Gemfile (`ref: "e4179e9"`). Each GitHub release is tagged with its commit SHA.

## 2026-09-04

### Added
- **Button elevation and press feedback** — buttons and `a[role="button"]`
  now cast a subtle shadow (`--shadow-1`) and squash slightly
  (`--animation-scale-press`) on press, with a spring-back release.
  `main > header nav a` (the page header's primary action link) gets the
  same shadow and 44px touch-target floor as the button next to it, on
  every theme: a hairline border instead of the shadow on dark themes
  (explicit `data-theme` and the default system dark scheme both), and
  fully flat on the e-ink theme. The squash is suppressed under
  `prefers-reduced-motion: reduce`, and never masks or replays the
  existing hover "boop" animation. Disabled buttons drop the shadow.
- **Spacing between stacked forms** — a `form` directly after another
  `form` (e.g. two `button_to` forms in a row) now gets space above it.

### Fixed
- **Touch target token** — `a[role="button"]` had its own hardcoded
  `min-block-size: 2.75rem` that silently overrode the shared
  `var(--touch-target)` rule below it in source order. Folded into the
  token-based rule instead, so retuning `--touch-target` moves buttons
  again.
- **Packaged `mvpa.css`** was missing three button-variant rules that only
  existed in the source partial (touch-target sizing, the destructive
  `button_to` color override, the page header action link styling).

## 2026-08-14

### Added
- **E-ink theme** (`data-theme="eink-light"` / `"eink-dark"`) — paper white,
  ink black, nothing moves; `eink-dark` inverts every step for e-ink devices
  in dark mode. Four-step ink ramp, all animations and transitions
  suppressed, box-shadows replaced by 1px ink borders, gradients replaced by
  flat fills. Buttons use a fill/outline ladder so action weight is readable
  without colour. Invalid fields use a 2px border instead of a red colour.
  Flash and error blocks use fill contrast instead of hue. Auto-detection via
  `@media (monochrome)` is unreliable on Android e-ink devices; the theme can
  be auto-applied via `matchMedia('(update: slow)')` or selected explicitly.
  Replaces the previous `2_monochrome.css` partial (which was inside a
  `@media (monochrome)` query that never matched on Android e-ink).
- **44px touch target minimum** (all themes) — buttons and navigation links now
  have `min-height: var(--touch-target)` (44px). Buttons use `inline-flex` so
  single-line labels stay vertically centred. Applies on every theme, not just
  e-ink.
- **`demo/eink-probe.html`** — standalone on-device probe page that prints
  media-feature results and grey/colour ladders for photographing. No framework
  dependencies; open from the filesystem or over Wi-Fi.

## 2026-07-15

### Added
- **Direction-aware page transitions** — `main` content now slides down
  when navigating to a sidebar item later in the list, up when navigating
  to one earlier (vertical on desktop, horizontal on mobile, matching the
  sidebar's own responsive breakpoint). Requires one small inline snippet
  copied into your app's layout `<head>` — see README "Page Transitions".
  Deliberately built on sessionStorage + a plain data-attribute rather
  than the View Transitions types API/named-type pseudo-class mechanism,
  which was confirmed during development to not reliably take effect in
  real-world browser testing despite reporting API support.

## 2026-07-14

### Changed
- **Elevation/depth system** — sidebar and `<article>` cards now read as
  elevated surfaces on a recessed page background. In the light/white
  themes, `--color-bg` (page canvas) now sits one step darker than
  `--color-bg-lighter` (sidebar/card surface); dark/black themes already
  had this relationship. The sidebar floats with a `--shell-gutter`
  margin, rounded corners, and a shadow (border on dark/black themes
  instead, since shadows don't read well there), and no longer gets an
  internal scrollbar — it grows with its content instead of clipping to
  viewport height. `<article>` gained a subtle elevation shadow.
- **Sidebar nav link hover** — links no longer inherit the generic
  underline-wiggle hover animation; they now get a small scale+lift
  (`--animation-scale-small` + `translateY(-2px)`) with a matching shadow,
  reusing the existing scale token rather than a new magic number.

## 2026-03-04

### Added
- **App-style navigation** — desktop vertical sidebar, mobile horizontal bottom tab bar
- **Navigation Stimulus controller** (`nav_controller.js`) — accordion behaviour (one submenu open at a time) and auto-close on link click
- **Auto-discovery for importmap-rails** — gem registers its own `config/importmap.rb` so `nav_controller.js` is pinned automatically in consuming apps
- **Page header component** — `main > header` with flex layout for title + action links
- **MonoLisa font preference** — code blocks prefer MonoLisa when installed

### Changed
- **Form fieldset layout** — labels and inputs are now direct `<fieldset>` children (no `<section>` wrapper needed); all labels in a fieldset share the width of the widest label via CSS Grid `max-content`
- **Mobile tab bar styling** — rounded "squircle" buttons (`border-radius: 1rem`), gap between tabs, subtle background colour
- **CSS source consolidation** — removed redundant `css/` directory; `app/assets/stylesheets/mvpa/` is the single source of truth

### Fixed
- Mobile tab bar being hidden by `main > header` page header elements (scoped app-shell header rules to `body > header`)

## 2026-02-13

### Added
- Initial release as Ruby gem
- 19 CSS files in SMACSS structure
- Rails Engine integration for automatic asset path registration
- Support for both Sprockets and Propshaft asset pipelines
- Manifest file (`mvpa.css`) for easy single import
- MIT License
- Git SHA-based automatic versioning (no manual version tracking needed)
