# MVPA.css

## What this is

A personal classless CSS framework: it styles semantic HTML5 elements (`<article>`, `<nav>`, `<aside>`, `<header>`, `<footer>`, etc.) directly, so a Rails app or a plain HTML page looks reasonable without adding classes. It ships as a Ruby gem with a Rails engine (`Mvpa::Css::Engine`) that registers its asset paths for Sprockets, Propshaft, and importmap, and it also works standalone by linking the CSS files straight into any HTML page.

## Domain

Styles are organized SMACSS-style under `app/assets/stylesheets/mvpa/`, in numbered folders (`0_base`, `1_layout`, `2_modules`, `4_theme`) that also encode load order. Each folder's individual partials are the source of truth; `app/assets/stylesheets/mvpa/mvpa.css` is a flattened, hand-maintained manifest that bundles them for single-import use (required for Propshaft, which cannot glob-import). Four themes ("Solunized" palettes: light, dark, white, black) are selected via `data-theme` on `<html>`, with `data-color-scheme` (`system`/`light`/`dark`) controlling automatic dark-mode behavior. Buttons are the one place classes exist (`.button-success`, `.button-danger`, `.button-warning`, `.button-secondary`).

## Commands

- Install: `bundle install` (Ruby gem deps) and `yarn install` (lint tooling only — there is no JS runtime dependency, the framework ships plain CSS plus two small Stimulus-style JS files under `app/javascript/`).
- Test: `bundle exec rake test` (Minitest, files in `test/**/*_test.rb`).
- Lint: `bundle exec rubocop` (Ruby), `yarn lint:css` (stylelint), `yarn lint:spelling` (cspell), `yarn lint:browsers` (browserslist config check), `yamllint --strict .` (YAML). CI (`.github/workflows/ci.yml`) runs all of these plus a gem build check.
- Preview: open `demo.html` directly in a browser — it links the individual partials, not the flattened manifest.

## Gotchas

- `mvpa.css` is not generated — editing a theme or module partial (e.g. `4_theme/0_colors.css`) requires manually applying the same change to `mvpa.css`, or `test/mvpa_manifest_sync_test.rb` fails on selector and semantic-color-mapping mismatches.
- `demo.html` hardcodes both the list of `<link>` tags and a written count of "N files" in its own text; adding or removing a stylesheet partial needs both updated, or `test/demo_stylesheet_links_test.rb` fails.
- README code examples (stylesheet paths, the flash markup snippet) are asserted against the real files by `test/readme_test.rb` — keep them literal and in sync with actual markup/paths.
- `lefthook.yml` in the repo root is an absolute-path symlink into `~/Developer/dotfiles` on this machine; it only resolves locally and is not portable to another clone.
- Ruby version comes from `.ruby-version` via `rv`; do not use mise/asdf/rbenv/rvm.
