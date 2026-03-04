# Changelog

**Note:** This project uses git SHAs instead of semver. Pin to a specific SHA in your Gemfile (`ref: "e4179e9"`). Each GitHub release is tagged with its commit SHA.

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
