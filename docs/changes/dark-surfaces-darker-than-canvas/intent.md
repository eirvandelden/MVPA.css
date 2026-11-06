# Intent: Dark-mode surfaces darker than the canvas

Author: Etienne van Delden. Status: accepted. Type: bugfix. Delivery: autonomous. Codex review: no.

## Problem

In dark mode, mvpa.css paints the page with the darkest background (`bg_0`) and every surface on it (header, sidebar card, article, table, dialog, details, navigation) with a lighter one (`bg_1`). Herdr and Nova do the opposite: the layer behind is lighter (`bg_1`) and the active panel is darker (`bg_0`). Sticker-app consumes mvpa.css and shows the reversed layering, so the three apps disagree.

## Proposed outcome

In every dark rendering of mvpa.css, a surface is darker than the layer behind it, as in Herdr and Nova. The default element colours give this without classes or overrides in the consuming app. Light and white themes stay as they are.

## Affected users and systems

- mvpa.css: `4_theme/0_colors.css` and the flattened `mvpa.css` manifest.
- Sticker-app: gets the new layering by bumping its pinned mvpa.css `ref:`. It needs no code change.
- Solunized generator: no change; its `mvpa-css` output exports raw tokens only.

## Constraints

- `mvpa.css` is hand-maintained, so the theme partial and the manifest change together or `test/mvpa_manifest_sync_test.rb` fails.
- mvpa.css is classless: the fix changes defaults, not markup or classes.
- No new dependency. No change to files outside the mvpa.css repository.

## In scope

- The `prefers-color-scheme: dark` default block.
- `[data-theme="solunized-dark"]` and `[data-theme="solunized-black"]`.
- A CHANGELOG entry with no `### Upgrading` subsection, because a colour fix needs no action in an app.

## Out of scope

- Light and white themes.
- The e-ink themes, unless the plan shows they depend on the dark scale.
- The Solunized `themes.yml` colour values.
- Any change in Sticker-app, Herdr or Nova.

## Acceptance criteria

- In dark mode, the sidebar card and an article are darker than the page behind them.
- The same holds under `data-theme="solunized-dark"` and `data-theme="solunized-black"`.
- In dark mode, text, borders, inputs and code blocks stay readable on their new backgrounds.
- In light mode, the page and surface colours are unchanged.

## Decisions

- Fix it in mvpa.css, not in Solunized or Sticker-app — mvpa.css owns the semantic scale and the apps only consume it.
- Dark default and solunized-dark/black get the new layering — chosen over changing only the `prefers-color-scheme` block.
- Autonomous delivery, no Codex review — no permissions beyond the defaults are needed; Claude reviewer only.
- Defaults must be right with no per-app wiring — mvpa.css is mostly classless.

## Open questions

None.
