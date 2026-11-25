# MVPA.css

## What this is

A personal classless CSS framework: it styles semantic HTML5 elements (`<article>`, `<nav>`, `<aside>`, `<header>`, `<footer>`, etc.) directly, so a Rails app or a plain HTML page looks reasonable without adding classes. It ships as a Ruby gem with a Rails engine (`Mvpa::Css::Engine`) that registers its asset paths for Sprockets, Propshaft, and importmap, and it also works standalone by linking the CSS files straight into any HTML page.

## Domain

Styles are organized SMACSS-style under `app/assets/stylesheets/mvpa/`, in numbered folders (`0_base`, `1_layout`, `2_modules`, `4_theme`) that also encode load order. Each folder's individual partials are the source of truth; `app/assets/stylesheets/mvpa/mvpa.css` is a flattened, hand-maintained manifest that bundles them for single-import use (required for Propshaft, which cannot glob-import). Four themes ("Solunized" palettes: light, dark, white, black) are selected via `data-theme` on `<html>`, with `data-color-scheme` (`system`/`light`/`dark`) controlling automatic dark-mode behavior. Buttons are the one place classes exist (`.button-success`, `.button-danger`, `.button-warning`, `.button-secondary`).

## Commands

- Install: `bundle install` (Ruby gem deps) and `npm install` (lint tooling only — there is no JS runtime dependency, the framework ships plain CSS plus two small Stimulus-style JS files under `app/javascript/`).
- Test: `bundle exec rake test` (Minitest, files in `test/**/*_test.rb`).
- Lint: `bundle exec rubocop` (Ruby), `npm run lint:css` (stylelint), `npm run lint:browsers` (browserslist config check), `yamllint --strict .` (YAML). CI (`.github/workflows/ci.yml`) runs all of these plus a gem build check.
- Preview: open `demo.html` directly in a browser — it links the individual partials, not the flattened manifest.

## Changelog

Other apps pin mvpa.css to a release tag (`tag: "X.Y.Z"`). A merge to `main` releases a version, so never write a version number, a date heading or an edit to `CHANGELOG.md` in a branch. Add one fragment file, `changelog.d/<branch-slug>.md`, with a `level` in its front matter. When a change requires an app to act, its fragment says how.

- Set `level: major` when an app must change markup, classes, configuration or code to follow the change. Removing or renaming a `--token`, a stylesheet or JS file, a class selector, a `data-` attribute selector or an importmap pin is a major change.
- Changing an element-structure contract, such as `nav.rail`, `main > header nav` or the markup a segmented control needs, is a major change. No check catches it, so you must say it.
- Set `level: minor` for an opt-in feature that apps can ignore. Set `level: patch` for a fix and for anything else, such as docs, tests or CI.
- Add a `### Upgrading` section to a `major` fragment, and to no other. A fragment below major has no `### Upgrading` section, for example a colour fix.
- Put `### Upgrading` last in the fragment, after whichever change sections it has. Never add an empty `### Added`, `### Changed` or `### Fixed` heading to reach it.
- Write the steps as a numbered list. Each step is one concrete action, so a reader in another app can follow it without the mvpa.css diff.
- Leave out the bump of the pinned `tag:`. Every upgrade needs it.
- Accept a removal of public surface below major only with an `overrides: {rule_id: "reason"}` front-matter key. The rule ids are `token`, `file`, `class`, `data_attribute` and `importmap_pin`, and the reason is required. The `surface` workflow prints each override.
- A fragment that already exists on `main` is never edited. A new change adds a new fragment.
- The release workflow reads every fragment on `main`, takes the highest level, stamps `lib/mvpa/css/version.rb` and `CHANGELOG.md`, deletes the fragments and tags `X.Y.Z`. A merge with no fragment releases a patch. Merges that land close together can share one release.

Example fragment, with placeholder class names:

```markdown
---
level: major
---

### Changed
- **Button class rename** — the secondary action button has a new class.

### Upgrading
1. Replace `class="button-old"` with `class="button-new"` in every view.
2. Rename every `.button-old` selector in your own stylesheets to `.button-new`.
```

## Gotchas

- `mvpa.css` is not generated — editing a theme or module partial (e.g. `4_theme/0_colors.css`) requires manually applying the same change to `mvpa.css`, or `test/mvpa_manifest_sync_test.rb` fails on selector and semantic-color-mapping mismatches.
- `demo.html` hardcodes both the list of `<link>` tags and a written count of "N files" in its own text; adding or removing a stylesheet partial needs both updated, or `test/demo_stylesheet_links_test.rb` fails.
- README code examples (stylesheet paths, the flash markup snippet) are asserted against the real files by `test/readme_test.rb` — keep them literal and in sync with actual markup/paths.
- `lefthook.yml` in the repo root points at the shared hooks via a `remotes:` entry (`eirvandelden/dotfiles`); lefthook fetches that repo's own `lefthook.yml` into `.git/info/lefthook-remotes/` and refetches it every 24 hours (`refetch_frequency`), so a job removed there stops running here within a day.
- Ruby version comes from `.ruby-version` via `rv`; do not use mise/asdf/rbenv/rvm.
