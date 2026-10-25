# Intent: Segmented control, count badges and title-bar heading wrap

Author: Etienne van Delden de la Haije. Status: accepted (2026-10-25). Type: feature. Delivery: autonomous. Codex review: no.

The slug keeps "sheets" from the original slice name. Sheets were dropped during the interview: see Decisions.

## Problem

An app built on mvpa.css cannot show a choice between a few views or values as one segmented row. journal_administration uses a `<select>` plus a Stimulus controller for the dashboard period, a plain link for the journal's "Zonder categorie" filter, and a broken toggle for a user's role. An app cannot show a count of what needs attention beside a navigation link or on a landing tile. A long single-word heading in the title bar widens the page unless the app adds its own rule.

## Proposed outcome

Semantic markup gets a segmented control and a count badge from mvpa.css alone, with no classes and no script. A `<menu>` of links is a view switch. A `<menu>` of radios is a form choice. Both look the same. A `<data>` inside a link is a count badge. The title-bar heading wraps instead of widening the page.

## Affected users and systems

- mvpa.css: the module partials, the flattened `mvpa.css`, `demo.html`, `README.md`, `CHANGELOG.md` and the tests that keep them in sync.
- journal_administration consumes this in later slices: the dashboard period, the journal filter and the user role (segmented control), the hub column and landing tiles of slice 7 (badges), and its local `title_bar.css` heading rule. Those app changes are separate.
- Any other app that pins mvpa.css and already uses `<menu>`, or a `<data>` inside a link, sees a new look after the bump.

## Constraints

- Classless: the looks derive from elements, attributes and context. No new classes.
- No JavaScript ships for these features.
- Browser targets stay Chrome ≥ 111, Firefox ≥ 121, Safari ≥ 16.4, iOS ≥ 16.4. The CSS passes `stylelint-no-unsupported-browser-features`.
- The rails-ui interaction-design reference is binding.
- Every theme reads correctly: the four Solunized themes and both e-ink themes.
- `mvpa.css` stays in sync with the partials, and `demo.html` lists every partial with the right count.
- `CHANGELOG.md` gets a dated entry with an `### Upgrading` subsection, because apps must change markup or remove a local rule.
- Approved permissions: none. Any need for a gem or package, a system tool, a migration, or a deploy or CI file becomes a stop-and-ask.

## In scope

- Segmented control on `<menu>`:
  - A `<menu>` whose items are `<li><a>` links is a view switch. The link with `aria-current` is the selected segment.
  - A `<menu>` whose items are `<li><label><input type="radio">…</label>` is a form choice, normally inside a `<fieldset>` with a `<legend>`. The checked radio's segment is selected.
  - One look for both: joined segments on a tinted track, and the selected segment raised on the page surface (iOS style).
  - Below 45rem of content width (container query), the segments stack into a full-width column, one per line.
  - Defaults: no selection shows every segment plain. The radio dot is visually hidden but stays focusable, so arrow keys and form submission work natively. A focused segment shows a visible focus ring. A disabled radio's segment is dimmed and cannot be chosen.
- Count badge on `<data value>` inside a link (`a data`):
  - A primary-colour pill with light text, after the link text, on one line with tabular numbers. A long number widens the pill.
  - On a link with `aria-current`, the pill inverts: a light pill with primary text.
  - `[value="0"]` is hidden, so the app can always render the badge.
  - A landing tile is a link, so it shows the same badge. mvpa.css adds no tile styles.
- Title-bar heading wrap: `main > header h1` gets `min-inline-size: 0` and `overflow-wrap: anywhere`, moved from journal_administration's `title_bar.css`. No hyphenation.
- `demo.html` shows a period view switch, a role form choice, badges in the sidebar navigation (one on the current page), a zero badge that stays hidden, and a long title-bar heading.
- `README.md` documents the markup for each.
- `CHANGELOG.md` dated entry with the additions, the changed look of existing `<menu>` and of `<data>` in a link, and `### Upgrading` steps.

## Out of scope

- Sheets, and any change to the `<dialog>` look: native dialogs stay the centred box from #41.
- A script that opens dialogs, a backdrop-click close, and an appkit sheet controller.
- journal_administration changes: slices 6 and 7, navigation-hubs and ui-review-bug-fixes.
- The custom confirm dialog: the native confirm stays.
- Landing tile styles.
- Number formatting in a badge, such as "99+": the app formats the text.
- A `<menu>` of buttons, or `<menu>` content other than links and radios: no segmented look.
- A `<data>` outside a link, including in a table cell: it stays as today.

## Acceptance criteria

- A `<menu>` of the five dashboard periods, "Deze maand" through "Vorig jaar", shows one row of joined segments. "Deze maand", with `aria-current="page"`, is the raised segment.
- Clicking "Vorig jaar" in that menu follows its link like any link. No script runs.
- In a `main` narrower than 45rem, the five periods stack into a full-width column, one per line. At 45rem or wider, they sit in one row.
- A `<menu>` with "Alle" and "Zonder categorie" and no `aria-current` shows both segments plain.
- A fieldset "Rol" with a `<menu>` of the radios "Lid" and "Beheerder" looks the same as the period menu. With "Beheerder" checked, that segment is raised, and no radio dot shows.
- Tabbing into the "Rol" choice shows a focus ring on the checked segment. The arrow keys move the choice, and saving the form sends the checked role.
- A disabled "Beheerder" radio shows a dimmed segment that a click does not select.
- The sidebar link `Categoriseren <data value="12">12</data>` shows "12" in a primary pill after the label.
- The same badge on the current page's link (`aria-current="page"`) shows as a light pill with primary text and stays readable.
- `Producten <data value="0">0</data>` shows the link text and no pill.
- `<data value="1234">1234</data>` in a link shows "1234" on one line in a wider pill.
- A `<data value="5000">` in a table cell looks as it did before this change.
- A landing tile link with `<data value="5">5</data>` shows the same pill as the sidebar.
- The title-bar heading "Hypotheekrenteaftrekberekening" on a 320px-wide phone wraps inside the title bar, and the page does not scroll sideways.
- The segmented control and the badge read correctly in every Solunized theme and in both e-ink themes.
- `demo.html` shows each criterion above, the tests and linters pass, and `mvpa.css` matches the partials.
- The `CHANGELOG.md` entry's `### Upgrading` steps tell an app to: replace a `<select>` period filter with a `<menu>` of links if it wants the segmented look; wrap segmented radios in `<menu><li><label>`; put counts in `<data value>` inside the link; check any existing `<menu>`, and any `<data>` inside a link, for the new look; and remove its own `main > header h1` wrap rule.

## Decisions

- One intent and one PR for slice 2 — no reason given.
- Move the title-bar heading wrap rule into mvpa.css in this change — no reason given.
- Keep the browser's native dialogs instead of sheets, and drop the sheet part from this change — no reason given (Etienne changed his mind after first choosing a macOS sheet, an appkit opener and a backdrop-click close).
- The segmented control serves both view switches (links) and form choices (radios), with one look — no reason given; chosen from the examples dashboard period, journal filter and user role.
- A `<menu>` of links is the view switch, and a `<menu>` of radios is the form choice — no reason given.
- Segments that do not fit stack vertically, below a fixed content width of 45rem — no reason given.
- The selected segment is raised and plain, not filled — no reason given.
- The badge is a `<data value>` inside a link, chosen over `<small>` so that mvpa.css can hide `[value="0"]` — rationale: CSS needs the value to hide a zero.
- The badge is an attention pill in the primary colour — no reason given.
- A landing tile shows the same badge, and mvpa.css adds no tile styles — no reason given.
- Autonomous delivery without a Codex review, and no extra permissions — no reason given.
- Badge text is white in every theme, also where it reaches only 3.19:1 on the dark-theme blue (settled 2026-10-25 at the plan escalation) — no reason given.
- A badge inside a segmented control keeps the normal primary pill, also on the selected segment; only an `aria-current` link outside a `<menu>` inverts it (settled 2026-10-25 at the plan escalation) — the inverted pill's edge is faint on the raised segment.

## Open questions

None.
