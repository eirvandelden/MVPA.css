# Changelog

**Note:** This project uses git SHAs instead of semver. Pin to a specific SHA in your Gemfile (`ref: "e4179e9"`). Each GitHub release is tagged with its commit SHA.

## 2026-10-19

### Added
- **Pull-down menu** — a `<details>` in `main > header nav` is a plain header button with a `▾` and opens its list as a surface under it. Each `li > a` and `li > form > button` fills the menu's width. The menu closes when you click the summary again or load a page, not on an outside click.
- **Stacking tables** — opt in per table with `data-stack="narrow"`, `"medium"` or `"wide"`. The table stacks below 30, 45 or 60rem of content width. Each cell shows its `data-label`. The header row stays in the accessibility tree.

### Changed
- **Table width** — every table has `max-inline-size: 100%`, text cells break anywhere, and `<time>` and `<data>` in a cell never wrap.
- **`main` is a container** — `main` has `container-type: inline-size` and `min-inline-size: 0`, so tables follow the content area instead of the viewport. A child that relied on `main` growing with its content now overflows instead.
- **Title bar is a wrapping row** — `main > header nav` lays its controls out left to right (`flex-direction: row; flex-wrap: wrap`) on every width. On a phone the controls wrap instead of scrolling sideways. It was a column on desktop.

### Upgrading
1. Build a pull-down menu as `<details><summary>Actions</summary><ul><li><a>…</a></li></ul></details>` as a direct child of the `<nav>` of `main > header`. A menu nested deeper, such as in `nav > ul > li`, picks up the sidebar rules instead.
2. On a table that should stack, add `data-stack="narrow"`, `"medium"` or `"wide"` and `role="table"`.
3. Give the stacking table's parts `role="rowgroup"` on `thead` and `tbody`, `role="row"` on each `tr`, `role="columnheader"` on each `th` and `role="cell"` on each `td`.
4. Add `data-label` with the column's name to every `td` of a stacking table.
5. Name a stacking table with a `<caption>` or `aria-labelledby` pointing at its heading.
6. Mark dates with `<time datetime>` and amounts with `<data value>`.
7. Remove your own `overflow-x: auto` wrapper around a table.
8. Check pages whose content relied on `main` growing with its content, such as charts and wide tables.
9. Move your `[data-mvpa-flashes]` notifications container outside `<main>`, as a direct child of `<body>`. `main` is now a size container, and on Safari before 18.4 a fixed child inside it scrolls with the content instead of staying at the viewport corner.
10. Remove your own `flex-direction: row` or `flex-wrap` rule for `main > header nav`, and check that the title-bar controls read left to right.

## 2026-10-13

### Changed
- **Button hierarchy from semantic HTML** — a submit (`<button>`, `type="submit"`, `<input type="submit">`) and `a[role="button"]` stay the filled default. `type="button"` and `type="reset"` buttons are now plain buttons: page-surface background, thin border, normal text colour. `.button-secondary` takes the same look. A `DELETE` form's button stays red.
- **Header nav links are plain** — `main > header nav a` was a filled primary button. It is now a bordered button; a `role="button"` link there stays filled.
- **Button colours are set through tokens** — `--button-bg`, `--button-fg` and the new `--button-border-color`. The defaults have zero specificity, so a class or a `button` rule in your own CSS wins. `.button-success`, `.button-danger` and `.button-warning` now set all three tokens.
- **E-ink button ladder** — filled default, outlined plain button, and a double-bordered destructive button, in both e-ink themes. `.button-secondary` loses its grey border.
- **Only the site footer keeps a view-transition name** — the rule is now `body > footer`, so action-row footers do not stop page transitions.

### Added
- **Action row** — a `<footer>` as the last child of a form lays out its buttons as a right-aligned row. With three or more buttons the first stands apart on the far left. On a phone the row stacks full width, `Save` on top.
- **Dialog styles** (`2_modules/12_dialog.css`) — a centred box with padding, radius and a width cap, a dimmed `::backdrop`, a short open animation (off under `prefers-reduced-motion: reduce` and on e-ink) and a `Cancel`, `Delete` action row that stacks on a phone.
- `demo.html` shows the hierarchy, the action rows and the dialog, with a real `main > header`.

### Removed
- The rule that made every form button in `main > header nav` red. Header buttons follow the general rules: a submit is filled, a `DELETE` form's button is red.

### Upgrading
- Every `type="button"` and `type="reset"` control turns plain, including a `Cancel` in an existing confirm dialog. Make a button the default action by giving it `type="submit"` or no type.
- For a filled `Cancel` in a dialog, use a submit inside a `<form method="dialog">`: `<form method="dialog"><button>Cancel</button></form>`.
- Add `class="button-danger"` to a `type="button"` such as `Delete…` to keep it red.
- Build the edit-page action row with a `<footer>` as the last child of the form, buttons in the order `Delete…`, `Cancel`, `Save`. Leave `Delete…` out on a new page.
- Build the confirmation with a `<dialog>`: a `<footer>` holding the `<form method="dialog">` Cancel, then a `DELETE` form with the red `Delete`.
- A `<footer>` that is a direct child of a `form` or `dialog` becomes an action row. Move help text out of it.
- If your own CSS sets `--button-bg` on `button`, it now wins on every button, including plain ones.
- Every button now has a 1px border, transparent on filled buttons, so each button is 2px taller and wider than before. Check tight layouts.
- Add `12_dialog.css` to your stylesheet links, after `10_navigation.css`. The gem and `mvpa.css` include it already.

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
