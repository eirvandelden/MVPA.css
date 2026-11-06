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
- In the dark themes, link text on the canvas uses `--color-br-blue`, the one existing palette colour with the same hue that does better (4.496:1 against 3.78:1 for `--color-blue` on `bg_1` in solunized-dark).
- The current-page sidebar link text uses `var(--color-bg-lightest)`, so it stays readable on the blue fill in the dark themes (3.78:1 becomes 4.69:1). This also changes it in the light and e-ink themes (4.48:1 becomes 5.09:1 in light).
- A CHANGELOG entry with no `### Upgrading` subsection, because a colour fix needs no action in an app.

## Out of scope

- Light and white page and surface colours. Only the current-page sidebar link text changes there.
- The e-ink themes, unless the plan shows they depend on the dark scale.
- The Solunized `themes.yml` colour values.
- Any change in Sticker-app, Herdr or Nova.

## Acceptance criteria

- In dark mode, the sidebar card and an article are darker than the page behind them.
- The same holds under `data-theme="solunized-dark"` and `data-theme="solunized-black"`.
- In dark mode, text, borders, inputs and code blocks stay readable on their new backgrounds.
- In light mode, the page and surface colours are unchanged.
- In solunized-dark, a link on the canvas scores at least 4.49:1, and the current-page sidebar link text scores at least 4.5:1.

## Flagged concerns

Muted text (`--color-dim-0`) on the solunized-dark canvas drops from 4.04:1 to 3.25:1, and no palette colour replaces it, because it is subdued by design. Chosen side: accept the drop and name the ratios in the CHANGELOG entry. `--color-br-blue` reaches 4.496:1, a hair under the 4.5:1 AA threshold. Chosen side: use it, because it is the best same-hue palette colour, and record the exact ratio.

## Decisions

- Fix it in mvpa.css, not in Solunized or Sticker-app — mvpa.css owns the semantic scale and the apps only consume it.
- Dark default and solunized-dark/black get the new layering — chosen over changing only the `prefers-color-scheme` block.
- Autonomous delivery, no Codex review — no permissions beyond the defaults are needed; Claude reviewer only.
- Widen scope to a dark link colour, only from the existing palette — chosen over accepting 3.78:1; no new colour or palette change.
- Switch the current-page sidebar link text to `var(--color-bg-lightest)` — chosen over keeping `var(--color-bg)`, even though light and e-ink output changes.
- Defaults must be right with no per-app wiring — mvpa.css is mostly classless.

## Open questions

None.
