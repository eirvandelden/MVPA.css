# Intent: Button hierarchy and action row

Author: Etienne van Delden de la Haije. Status: accepted (2026-10-13). Type: refactor. Delivery: autonomous.

## Problem

mvpa.css fills every `button`, submit and `type="button"`/`type="reset"` control blue, so every button looks like the main action. Every link in a page header nav looks like a filled primary button. Every button in a form inside `main > header nav` is red, whatever the form does. A page cannot show one default action among quieter push buttons. There is no action row: each app decides where Delete, Cancel and Save go. There is no styled `<dialog>`, so the delete confirmation has no shared look.

This is slice 1 of the journal_administration UI review. The agreed placement rules are in dotfiles PR #194 (`claude/.claude/skills/rails-ui/references/interaction-design.md`, sections Action rows, Edit pages and sheets, Confirmation dialogs, Default button).

## Proposed outcome

Button weight comes from semantic HTML. A submit button is the filled default button. A `type="button"` or `type="reset"` button and a header nav link are plain push buttons. A `DELETE` form's button is red.

An edit page's action row follows the macOS save sheet. A red `Delete…` (or a plain `Don't Save`) stands apart on the far left. `Cancel` and `Save` sit together on the right, with `Save` rightmost. On a page without the left button, `Cancel` and `Save` still sit on the right.

The delete confirmation is a styled `<dialog>`: a centred box over a dimmed backdrop. It shows `Cancel | Delete`, with `Cancel` filled as the default and the red `Delete` rightmost.

On a phone-width screen both rows stack full width.

## Affected users and systems

- Every app that pins mvpa.css. They get the new look on the next bump and follow the changelog's `### Upgrading` subsection.
- appkit. Its `_confirm_dialog` uses `<button type="button">` for Cancel, so Cancel stays plain until appkit changes its markup.
- journal_administration, the app the UI review covers.
- Within mvpa.css: the button partials, `0_header.css`, the e-ink theme, the flattened `mvpa.css` manifest, `demo.html`, `README.md` and `CHANGELOG.md`.

## Constraints

- Classless: weight, colour and placement derive from semantic HTML (element, `type`, attributes, structure). This change adds no new class.
- The four existing classes (`.button-success`, `.button-danger`, `.button-warning`, `.button-secondary`) keep working. `.button-danger` is how an app makes a `type="button"` such as `Delete…` red.
- Every theme shows the same hierarchy: the four Solunized themes, system dark, and e-ink. E-ink shows it without colour: filled default, outlined push button, and a destructive look that differs from both.
- Animations are off under `prefers-reduced-motion: reduce` and on e-ink.
- No horizontal page scroll at phone width.
- Browser support stays the current browserslist (Chrome 111, Firefox 121, Safari 16.4, iOS 16.4).
- `CHANGELOG.md` gets an entry with an `### Upgrading` subsection, because apps must change markup to get the new behaviour.
- `mvpa.css`, `demo.html` and the README must stay in sync with the partials; the existing sync tests enforce this.
- Approved permissions for autonomous delivery: adding an npm dev dependency for linting or testing, and editing `.github/workflows/ci.yml`. Anything else under playbook rules 8, 9, 11, 12 or 13 is a stop-and-ask.

## In scope

- Button hierarchy: submit buttons filled; `type="button"` and `type="reset"` buttons plain push buttons (page-surface background, thin border, normal text colour); `a[role="button"]` stays filled.
- `.button-secondary` takes the new plain push-button look. `.button-success`, `.button-warning` and `.button-danger` keep their look.
- `DELETE` forms (`button_to … method: :delete`) stay red automatically, `Uitloggen` included.
- Header nav links (`main > header nav a`) become plain push buttons.
- Remove the rule that makes every form button in `main > header nav` red. Header buttons then follow the general rules.
- The action row for edit pages and sheets: one left-standing button (red `Delete…` or plain `Don't Save`) apart on the far left, `Cancel` and `Save` on the right with `Save` rightmost. On a phone it stacks full width: `Save` on top, then `Cancel`, then the left-standing button at the bottom, set apart.
- Dialog styles: a centred box with padding, radius and a width cap in `rem`, a dimmed `::backdrop`, and a short open animation. Its action row puts `Cancel` then the red `Delete` on the right; the far-left rule never applies in a dialog. On a phone the row stacks: `Cancel` on top, `Delete` below.
- `demo.html` shows the hierarchy, the edit-page action row (with and without `Delete…`, and with `Don't Save`) and the confirmation dialog.
- README button section and `CHANGELOG.md` entry with `### Upgrading`.

## Out of scope

- JavaScript: no Stimulus fallback for Invoker Commands, no confirm-dialog script. That moves into appkit in slice 2.
- Markup changes in appkit or journal_administration. They follow the Upgrading entry later.
- Other slice 2 parts: sheets, pull-down menu, segmented control, count badges, responsive tables.
- An opt-out that makes a submit button plain, or a `DELETE` form not red.

## Acceptance criteria

- On a form with `Cancel` as a `<button type="button">` and `Save` as a submit button, `Save` is filled and `Cancel` is a bordered push button.
- A `<button type="reset">` "Clear" next to a submit "Send" is a bordered push button; "Send" is filled.
- A `button_to "Tonen"` (a submit) stays filled.
- `button_to "Uitloggen", method: :delete` is red.
- A `button_to … method: :patch` inside `main > header nav` is filled, not red.
- A link "Edit" in `main > header nav` is a bordered push button, not a filled one.
- A link with `role="button"` stays filled.
- A `<button class="button-secondary">` looks the same as a plain `type="button"` push button.
- On an edit page, `Delete…` (`<button type="button" class="button-danger">`) is red and stands alone on the far left; `Cancel` and `Save` sit together on the right, `Save` rightmost.
- On a new page that shares the form but has no `Delete…`, `Cancel` and `Save` still sit on the right.
- On a three-button save sheet, `Don't Save` stands apart on the far left as a plain push button; `Cancel` and `Save` sit on the right.
- At phone width the edit-page row stacks full width: `Save` on top, `Cancel` below it, `Delete…` at the bottom, set apart.
- An open confirmation dialog shows a centred box over a dimmed page, with `Cancel` filled and the red `Delete` to its right.
- At phone width the confirmation's buttons stack full width: `Cancel` on top, `Delete` below.
- Inside the dialog, `Delete` never moves to the far left.
- On e-ink, `Save` is filled, `Cancel` is outlined, and `Delete…` looks different from both, without colour; the dialog opens without animation.
- With `prefers-reduced-motion: reduce`, the dialog opens without animation.
- On every Solunized theme and in system dark mode, the default, push and destructive buttons are distinguishable, and the dialog box stands out from the backdrop.
- At phone width no page in `demo.html` scrolls sideways.
- The changelog entry has an `### Upgrading` subsection that tells apps: which controls turn plain, to use a submit in a `<form method="dialog">` for a filled Cancel, to add `.button-danger` to `Delete…`, and which markup builds the action row and the dialog.
- `bundle exec rake test`, `yarn lint:css`, `yarn lint:browsers`, `bundle exec rubocop` and `yamllint --strict .` pass.

## Flagged concerns

- The review asked for "filled only for the default action, red only by choice". This intent chooses the classless rules instead: every submit is filled and every `DELETE` form is red, with no opt-out. Tradeoff: `Tonen`, `← 2026` and `Uitloggen` keep their strong look unless the app changes their markup (a link or `type="button"`). Side chosen: classless rules win.
- The confirmation's `Cancel` is filled only as a submit button in a `<form method="dialog">`. appkit's current `type="button"` Cancel stays plain. Side chosen: semantic markup wins; appkit changes its markup later, guided by the Upgrading entry.

## Open questions

None.
