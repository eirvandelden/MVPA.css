# Plan: Button hierarchy and action row

From `intent.md` (2026-10-13). Status: accepted.

## Context

mvpa.css is a classless CSS framework, shipped as a Ruby gem. The source of truth is the partials under `app/assets/stylesheets/mvpa/`. `app/assets/stylesheets/mvpa/mvpa.css` is a hand-maintained flat copy of all partials; every partial edit must be copied into it. Tests are Minitest files under `test/` that read the CSS, HTML and Markdown files as text (regex and `assert_includes`), or parse `demo.html` with Nokogiri. There is no browser test harness. Baseline before this change: `bundle exec rake test` gives 90 runs, 0 failures.

Today every `button`, `input[type="submit|button|reset"]` and `a[role="button"]` gets `--button-bg: var(--color-primary)` from one rule in `2_modules/1_forms.css`. `main > header nav a` is a filled blue link (`2_modules/5_buttons.css`). `1_layout/0_header.css` makes every `main > header nav form button` red. The e-ink theme (`4_theme/2_eink.css`) outlines every button and fills only the warning and danger variants. There is no `dialog` style and no action-row layout.

## Design decisions

1. **Colour tokens per role, set through `:where()`.** The shared button rule in `1_forms.css` keeps its exact selector list and layout. It drops its `--button-bg`/`--button-fg` declarations and reads three tokens: `background-color: var(--button-bg)`, `color: var(--button-fg)`, `border: 1px solid var(--button-border-color)` (replaces `border: none`). Two zero-specificity rules set the tokens, in this order:
   - Default (filled): `:where(button, input[type="submit"], input[type="button"], input[type="reset"], a[role="button"])` → `--button-bg: var(--color-primary)`, `--button-fg: var(--color-bg-lightest)`, `--button-border-color: transparent`.
   - Push button: `:where(button[type="button"], button[type="reset"], input[type="button"], input[type="reset"])` → `--button-bg: var(--color-bg-lighter)`, `--button-fg: var(--color-fg)`, `--button-border-color: var(--color-border)`.
   - Why `:where()`: a variant class (`.button-danger`, specificity 0,1,0) must beat the push rule on `<button type="button" class="button-danger">`. `button[type="button"]` is 0,1,1 and would win. At zero specificity, every class and the DELETE-form rule win without `!important`.
   - A `<button>` with no `type` is a submit, so it stays filled. `a[role="button"]` stays filled.
   - The transparent border on filled buttons keeps filled and push buttons the same size.
   - Push buttons keep `box-shadow: var(--shadow-1)` and the existing hover/press behaviour. A push hover stays `brightness(1.1)`; the boop animation is the main hover cue.
   - Exception, kept on purpose: the existing dark-theme border swap in `1_forms.css` (`[data-theme="solunized-dark"] button, …` and its `@media (prefers-color-scheme: dark)` `:root:not([data-theme])` twin) sets `border` directly and so overrides `--button-border-color` on every button in dark mode. Filled buttons keep their hairline there, as today, because the shadow does not read on a dark canvas. Push buttons are told apart by their fill. This rule and `test/button_shadow_spacing_spring_test.rb` stay unchanged.
2. **Variants set all three tokens.** `.button-success`, `.button-danger` and `.button-warning` each set `--button-fg: var(--color-bg-lightest)` and `--button-border-color: transparent` beside their `--button-bg`. Without this, `<button type="button" class="button-danger">` inherits the push tokens' dark text and grey border. `.button-secondary` takes the push tokens: `--button-bg: var(--color-bg-lighter)`, `--button-fg: var(--color-fg)`, `--button-border-color: var(--color-border)`. The DELETE-form rule (`form:has(input[name="_method"][value="delete"]) button`) adds `--button-border-color: transparent`.
3. **Header nav link is a push button, set with direct properties.** `main > header nav a` (in `5_buttons.css`) keeps its selector, layout, `box-shadow: var(--shadow-1)` and touch-target floor. It changes to `background-color: var(--color-bg-lighter)`, `color: var(--color-fg)`, `border: 1px solid var(--color-border)`. Its hover/visited rule changes to `main > header nav a:not([role="button"]):hover, main > header nav a:not([role="button"]):visited { color: var(--color-fg); text-decoration: none; }`. Direct properties (not tokens) matter: the shared button rule (0,1,1) beats `main > header nav a` (0,0,3), so an `a[role="button"]` in the header nav keeps the filled background. Its text colour needs one more rule: `header nav a:hover, header nav a:visited` in `2_modules/10_navigation.css` (0,1,2) beats the shared rule's `color` and would put dark text on the filled background. Add `main > header nav a[role="button"], main > header nav a[role="button"]:hover, main > header nav a[role="button"]:visited { color: var(--button-fg); }` (0,2,3 and up) to `5_buttons.css`.
4. **Remove the red header rule.** Delete `main > header nav form button { … }` from `1_layout/0_header.css` and from `mvpa.css`. A `button_to … method: :patch` in the header is then filled. A DELETE form there (`Uitloggen`) stays red through the DELETE-form rule.
5. **Action-row markup: a `<footer>` as the last child of the `<form>`.** It holds the buttons directly, in DOM order left to right: optional left-standing button, `Cancel`, `Save`.

   ```html
   <form>
     …fields…
     <footer>
       <button type="button" class="button-danger">Delete…</button>
       <button type="button">Cancel</button>
       <button>Save</button>
     </footer>
   </form>
   ```

   Rejected: `<menu>` (needs `<li>` wrappers), `<p>` (too generic to style safely), `<nav>` (navigation semantics, and `main > header nav` rules would collide).
6. **Left-standing button = first child of a footer with three or more children.** Selector: `form:not(dialog *) > footer > :first-child:nth-last-child(n + 3)` → `margin-inline-end: auto`. A two-button row (`Cancel`, `Save`) has no left-standing button. The `:not(dialog *)` guard makes the far-left rule never apply inside a dialog, even when the dialog wraps its content in a form.
7. **Action-row rule.** `form > footer, dialog > footer`: `display: flex; flex-wrap: wrap; justify-content: flex-end; align-items: center; gap: var(--block-space-half) var(--inline-space)`. It also resets what the global `footer` rule in `1_layout/2_footer.css` applies to every footer: `max-inline-size: none; margin-inline: 0; padding: 0; border: none; color: inherit`. Children get `margin: 0` (`:is(form, dialog) > footer > *`), so the button's default margins and `form + form` spacing do not break the row. Lives in `2_modules/1_forms.css` (the form footer) and `2_modules/12_dialog.css` (the dialog footer).
8. **Phone layout (`@media (max-width: 768px)`, the repo's existing breakpoint).**
   - `form > footer`: `flex-direction: column-reverse; align-items: stretch`. DOM `[Delete…, Cancel, Save]` renders `Save`, `Cancel`, `Delete…` top to bottom. Buttons get `inline-size: 100%`. The left-standing child gets `margin-inline-end: 0` and `margin-block-start: var(--block-space)` to set it apart.
   - `dialog > footer` (and `dialog form > footer`): `flex-direction: column; align-items: stretch`. DOM `[Cancel, Delete]` renders `Cancel` on top, `Delete` below. Child forms and their buttons get `inline-size: 100%`. The dialog rule must come after the form rule in load order (it does: `12_dialog.css` loads after `1_forms.css`, in `demo.html` and in `mvpa.css`).
9. **Confirmation dialog markup.** `Cancel` is a submit in a `<form method="dialog">`, so it is filled and is the Return-key default. `Delete` is a `button_to … method: :delete` form, so it is red. Two forms are needed: one shared form with a hidden `_method=delete` would also turn `Cancel` red.

   ```html
   <dialog>
     <h2>Delete this journal?</h2>
     <p>This cannot be undone.</p>
     <footer>
       <form method="dialog"><button>Cancel</button></form>
       <form method="post" action="/journals/1">
         <input type="hidden" name="_method" value="delete">
         <button>Delete</button>
       </form>
     </footer>
   </dialog>
   ```
10. **Dialog styles in a new partial `2_modules/12_dialog.css`.** `dialog`: `inline-size: min(32rem, 100% - 2rem)`, `max-inline-size: none`, `padding: var(--block-space-double)`, `border: 1px solid var(--color-border)`, `border-radius: var(--radius-large)`, `background-color: var(--color-bg-lighter)`, `color: var(--color-fg)`, `box-shadow: var(--shadow-3)`. The UA already centres a modal dialog (`showModal()`); the partial does not reposition it. `dialog::backdrop`: `background-color: oklch(0% 0 0 / 0.45)`, a literal colour. Why literal: custom properties are not reliably available inside `::backdrop` across the browserslist floor (Chrome 111, Safari 16.4): older engines do not inherit into it at all. A literal colour works everywhere.
11. **Dialog open animation in `0_base/3_animations.css`.** Two keyframes inside the existing `@media (prefers-reduced-motion: no-preference)` block: `dialog-enter` (opacity 0 → 1, `scale(0.96)` → `scale(1)`) on `dialog[open]`, and `backdrop-fade-in` (opacity 0 → 1) on `dialog[open]::backdrop`, both `var(--animation-duration-fast) var(--animation-ease-out)`. Under `reduce` the rules never apply. `@starting-style` is rejected: it is below the browserslist floor (Chrome 117, Safari 17.5).
12. **E-ink button ladder, without colour.** In both `eink-light` and `eink-dark` (colours inverted for dark):
    - Default (submit, `<button>` without type, `a[role="button"]`): ink fill, paper text, 1px ink border. The existing `[data-theme="eink-light"] button, …` rule becomes this filled rule. It keeps `box-shadow: none; filter: none`. `input[type="button"]` and `input[type="reset"]` leave this rule.
    - Push (`button[type="button"]`, `button[type="reset"]`, `input[type="button"]`, `input[type="reset"]`, `.button-secondary`): paper fill, ink text, 1px solid ink border. `.button-secondary` loses its grey border so it matches the push look, as the intent requires.
    - Destructive (`.button-danger`, DELETE-form button): paper fill, ink text, `3px double` ink border. It differs from the filled default (fill) and from the push button (border shape). Dashed stays reserved for disabled. The DELETE-form selector is `[data-theme="eink-light"] :where(form:has(input[name="_method"][value="delete"])) button` (0,1,1): it follows the filled rule (same specificity, later), and stays below the disabled rule. Without it a `button_to … method: :delete` keeps the filled-default look on e-ink.
    - Warning keeps its look (ink fill, grey border).
    - Pressed: filled default inverts to paper; push and destructive invert to ink; warning inverts to paper. The current combined `.button-warning:active, .button-danger:active` rule splits in two. The destructive pressed rule also sets `filter: none`, because `.button-danger:active { filter: brightness(1.05) }` in `5_buttons.css` (0,2,0) otherwise beats the e-ink button rule's `filter: none`.
    - Specificity: the push rule (`[data-theme] button[type="button"]`, 0,2,1) beats `[data-theme] .button-danger` (0,2,0). So the destructive and warning selectors are element-qualified (`[data-theme="eink-light"] button.button-danger`, 0,2,1) and come after the push rule. Rule order in each e-ink block: filled → push → warning → destructive → disabled. Disabled (`:disabled`, 0,2,1) comes last so it wins over all.
    - Header nav link: it already reads `--color-bg-lighter`, `--color-fg` and `--color-border`, which e-ink maps to paper, ink and ink. It needs no new e-ink rule.
13. **E-ink dialog.** `[data-theme="eink-light"] dialog { border: 2px solid black; box-shadow: none; }` (white for `eink-dark`). `[data-theme="eink-…"] dialog::backdrop { background: none; animation: none !important; }`. The blanket `*` animation kill does not reach `::backdrop`, so it needs its own rule. No alpha dimming on e-ink, because the e-ink theme test refuses translucent fills and grey dither looks muddy on paper.
14. **Only the site footer gets a view-transition name.** `2_modules/11_turbo-transitions.css` gives every `footer` `view-transition-name: footer`. With action rows, a page has several footers, and duplicate names make the browser skip the View Transition. Narrow that selector to `body > footer` in the partial and in `mvpa.css`.
15. **Demo gets a real page header.** `demo.html`'s existing "Page Header" examples sit inside `<article><section>`, so `main > header` never matches them. The plan adds a `<header>` as the first child of `<main>` in `demo.html`, with an `Edit` link, a `button_to`-style PATCH form (`Tonen`) and a DELETE form (`Uitloggen`). This shows the header nav acceptance criteria live.

## Integration points

- Apps that pin mvpa.css: Rails `button_to` emits `<form><button type="submit">` (filled) and, for `method: :delete`, a hidden `_method=delete` input (red). Rails `form.submit` emits `input[type="submit"]` (filled).
- appkit's `_confirm_dialog` uses `<button type="button">` for Cancel; it renders plain until appkit changes its markup (out of scope, covered by the Upgrading entry).
- The global `footer` rule in `1_layout/2_footer.css` styles every `footer` element; the action row resets it locally and does not change that rule.
- `0_base/3_animations.css` reduced-motion blocks and the e-ink blanket animation kill.
- Browser floor `.browserslistrc`: Chrome 111, Firefox 121, Safari 16.4, iOS 16.4. Selectors used: `:where()`, `:is()`, `:has()` (already used), `:not()` with a complex selector, `:nth-last-child()`, `dialog`, `::backdrop`. All are within the floor; `yarn lint:css` (`stylelint-no-unsupported-browser-features`) confirms it.

## Files that change

- `app/assets/stylesheets/mvpa/2_modules/1_forms.css` — shared button rule reads `--button-bg`, `--button-fg`, `--button-border-color`; new `:where()` default and push token rules; form action-row rules (`form > footer`, left-standing child, phone stacking).
- `app/assets/stylesheets/mvpa/2_modules/5_buttons.css` — variants set all three tokens; `.button-secondary` becomes the push look; DELETE rule sets a transparent border; header nav link becomes a push button; hover/visited rule gets `:not([role="button"])`.
- `app/assets/stylesheets/mvpa/1_layout/0_header.css` — remove `main > header nav form button`.
- `app/assets/stylesheets/mvpa/2_modules/12_dialog.css` — new: dialog box, `::backdrop`, dialog footer row, dialog phone stacking.
- `app/assets/stylesheets/mvpa/2_modules/11_turbo-transitions.css` — `footer { view-transition-name: footer; }` becomes `body > footer` (decision 14).
- `app/assets/stylesheets/mvpa/0_base/3_animations.css` — `dialog-enter` and `backdrop-fade-in` keyframes and their application, inside the `no-preference` block.
- `app/assets/stylesheets/mvpa/4_theme/2_eink.css` — new button ladder (filled/push/warning/destructive/disabled, pressed states) and dialog rules, for both e-ink themes.
- `app/assets/stylesheets/mvpa/mvpa.css` — mirror every partial change above; insert the `12_dialog.css` content after the `11_turbo-transitions.css` section and before the theme section.
- `demo.html` — link `12_dialog.css` after `10_navigation.css`; update both "22 files" counts to 23; add the `main > header` page header; in `#buttons` add `<section>`s (each with its own `<h3>`) for "Button hierarchy", "Action row" (edit page with `Delete…`, new page without it, save sheet with `Don't Save`) and "Confirmation dialog" (an opener `<button type="button" class="button-danger" command="show-modal" commandfor="confirm-delete">Delete…</button>` and the dialog markup from decision 9 with `id="confirm-delete"`; declarative Invoker Commands, no script, because the intent keeps JavaScript out of this slice; browsers without Invoker Commands simply do not open it); replace the inline-styled "Link as Button" with `<a href="#" role="button">`.
- `README.md` — add `12_dialog.css` to the stylesheet link list and the file tree; rewrite the "Buttons" section: hierarchy by semantics, variants, action-row markup, dialog markup.
- `CHANGELOG.md` — new top section `## <implementation date>` with `### Changed`, `### Added`, `### Removed` and `### Upgrading`.
- `test/button_hierarchy_test.rb` — new.
- `test/action_row_test.rb` — new.
- `test/dialog_test.rb` — new.
- `test/demo_button_hierarchy_test.rb` — new (Nokogiri).
- `test/changelog_upgrading_test.rb` — new.
- `test/readme_test.rb` — new tests for the rewritten "Buttons" section.
- `test/eink_theme_test.rb` — new e-ink ladder and dialog tests; the pressed-state test changes because danger now starts paper-filled (decision 12).
- `test/page_transitions_test.rb` — new test for the narrowed footer view-transition name.
- `test/page_header_component_test.rb` — the red header rule is removed on purpose: its two `--button-bg: var(--color-danger, red)` / `main > header nav form button` assertion pairs become `refute_includes` for source and bundle; the `main > header` flex assertions stay.

## Order of work

1. Write `test/button_hierarchy_test.rb#test_a_cancel_button_is_a_push_button_beside_a_filled_save` (push token rule present in `1_forms.css` and `mvpa.css`; shared rule reads `var(--button-border-color)`). Run it alone: `bundle exec ruby -Itest test/button_hierarchy_test.rb -n test_a_cancel_button_is_a_push_button_beside_a_filled_save`. Watch it fail.
2. Implement decision 1 in `1_forms.css` and `mvpa.css`. Run the test green. Run the full suite; fix only what this step broke.
3. Add the remaining `button_hierarchy_test.rb` tests one at a time (reset button, submit stays filled, DELETE red with transparent border, header PATCH button not red, header link push look, `a[role="button"]` filled, `.button-secondary` equals push, variants set fg and border). Implement decisions 2–4 red/green each. Update `page_header_component_test.rb` in the same step as the removal of the red header rule.
4. Write `test/action_row_test.rb` tests one at a time; implement decisions 5–8 for `form > footer` in `1_forms.css` and `mvpa.css`.
5. Write `test/page_transitions_test.rb#test_only_the_site_footer_gets_a_view_transition_name`; narrow the selector (decision 14) in the partial and `mvpa.css`. Then write `test/dialog_test.rb` tests one at a time; create `12_dialog.css` (decisions 9–10, dialog phone stacking), add its animations (decision 11), link it in `demo.html` (update the counts), add it to `mvpa.css` and `README.md`.
6. Add the e-ink tests to `test/eink_theme_test.rb`; rewrite the e-ink ladder and add the dialog rules (decisions 12–13) for both themes in `2_eink.css` and `mvpa.css`. Update the pressed-state test.
7. Write `test/demo_button_hierarchy_test.rb`; build the demo sections and the page header (decision 15).
8. Write `test/changelog_upgrading_test.rb` and the new `test/readme_test.rb` tests; write the `CHANGELOG.md` entry and the README "Buttons" section.
9. Run everything: `bundle exec rake test`, `yarn install` (if `node_modules` is missing), `yarn lint:css`, `yarn lint:browsers`, `bundle exec rubocop`, `yamllint --strict .`.
10. Visual check in a real browser (see Proof, "Browser checks"). Record the screenshots and measurements as evidence in the review/PR notes. Fix anything that fails and re-run step 9.
11. Re-read the full diff (playbook rule 21); commit in small logical commits.

## Risks

- **Specificity regressions.** App CSS that sets `--button-bg` on `button` (0,0,1) used to tie with the shared rule; it now beats the `:where()` tokens and wins on every button, including push buttons. That is the intended override path, but it changes results for apps that set it. Call it out in `### Upgrading`.
- **Every existing `type="button"` / `type="reset"` turns plain**, including appkit's confirm `Cancel` and any JS-driven action buttons. Intended; documented in `### Upgrading`.
- **Phone focus order.** `column-reverse` puts `Save` on top while keyboard focus still starts at the bottom (`Delete…`). Accepted: phones rarely use a keyboard, and DOM order stays the desktop reading order. The dialog uses `column`, so its order matches.
- **Global `footer` rule.** Any `footer` direct child of a `form` or `dialog` becomes an action row. A form that already uses `<footer>` for help text now lays it out as a flex row. Rare; mention it in `### Upgrading`. Narrowing the global rule to `body > footer` is a separate change.
- **Left-standing detection by count.** A form footer with three or more children always floats the first one left, even when an app wants three buttons on the right. Accepted per the macOS rule set; apps can drop to two right-hand buttons.
- **Non-modal dialogs.** `dialog.show()` is not centred by the UA; the plan targets `showModal()` only.
- **Rejected: a browser test harness** (Playwright as an npm dev dependency). The intent pre-approves an npm dev dependency for testing, but Playwright also downloads browser binaries outside the repo and needs CI changes; the repo's test style is static. Visual criteria are checked by hand in headless Chrome instead (step 10), and the static tests pin the rules that produce them.
- **Rejected: a new class for the action row or the left-standing button.** The intent forbids new classes.

## Out of scope

- Any JavaScript, in the framework or in `demo.html`: Invoker Commands fallback, confirm-dialog script (slice 2, appkit). The browser checks open the dialog only in throwaway scratchpad copies.
- Markup changes in appkit or journal_administration.
- Sheets, pull-down menu, segmented control, count badges, responsive tables (slice 2).
- An opt-out that makes a submit plain or a DELETE form not red.
- Narrowing the global `footer` rule; styling a plain `<a>` inside an action row.
- Non-modal (`show()`) dialog positioning.

## Proof

- Cancel `type="button"` is a bordered push button, submit Save is filled → `test/button_hierarchy_test.rb` `test_a_cancel_button_is_a_push_button_beside_a_filled_save`
- `type="reset"` Clear is a push button, Send filled → `test/button_hierarchy_test.rb` `test_a_reset_button_is_a_push_button`
- `button_to "Tonen"` (submit) stays filled → `test/button_hierarchy_test.rb` `test_a_submit_without_a_type_stays_filled`
- `button_to "Uitloggen", method: :delete` is red → `test/button_hierarchy_test.rb` `test_a_delete_form_button_is_red_without_a_border`
- `button_to … method: :patch` in `main > header nav` is filled, not red → `test/button_hierarchy_test.rb` `test_a_header_nav_form_button_is_no_longer_forced_red`
- Link "Edit" in `main > header nav` is a bordered push button → `test/button_hierarchy_test.rb` `test_a_header_nav_link_is_a_push_button`
- Link with `role="button"` stays filled → `test/button_hierarchy_test.rb` `test_a_role_button_link_stays_filled_even_in_the_header_nav` (asserts the shared rule and the `main > header nav a[role="button"]` colour rule for normal, hover and visited)
- `<button class="button-secondary">` looks like a plain push button → `test/button_hierarchy_test.rb` `test_button_secondary_uses_the_push_button_tokens`
- Edit page: red `Delete…` far left, `Cancel` and `Save` right, `Save` rightmost → `test/action_row_test.rb` `test_the_first_of_three_or_more_footer_buttons_stands_apart_on_the_left` and `test/button_hierarchy_test.rb` `test_a_danger_push_button_is_red_with_light_text`
- New page without `Delete…`: `Cancel` and `Save` still on the right → `test/action_row_test.rb` `test_a_form_footer_is_a_right_aligned_row`
- Save sheet: plain `Don't Save` apart on the far left → `test/action_row_test.rb` `test_the_first_of_three_or_more_footer_buttons_stands_apart_on_the_left` and `test/demo_button_hierarchy_test.rb` `test_the_demo_shows_a_save_sheet_with_dont_save_first`
- Phone: edit row stacks full width, `Save` top, `Cancel`, `Delete…` bottom and set apart → `test/action_row_test.rb` `test_a_form_footer_stacks_save_first_on_a_phone`
- Open dialog: centred box over a dimmed page, `Cancel` filled, red `Delete` right of it → `test/dialog_test.rb` `test_a_dialog_is_a_padded_rounded_box_capped_in_rem` and `test_the_dialog_backdrop_dims_the_page`, plus `test/demo_button_hierarchy_test.rb` `test_the_demo_confirmation_has_a_dialog_form_cancel_before_a_delete_form`
- Phone: dialog buttons stack full width, `Cancel` top, `Delete` below → `test/dialog_test.rb` `test_dialog_buttons_stack_cancel_first_on_a_phone`
- Inside the dialog, `Delete` never moves far left → `test/action_row_test.rb` `test_the_left_standing_rule_never_applies_inside_a_dialog`
- E-ink: `Save` filled, `Cancel` outlined, `Delete…` differs from both, no dialog animation → `test/eink_theme_test.rb` `test_the_default_button_is_ink_filled_on_eink`, `test_a_push_button_is_outlined_on_eink`, `test_a_destructive_button_has_a_double_border_on_eink`, `test_a_delete_form_button_has_the_destructive_look_on_eink`, `test_the_dialog_opens_without_animation_on_eink`
- Reduced motion: dialog opens without animation → `test/dialog_test.rb` `test_the_dialog_animation_only_runs_without_a_reduced_motion_preference`
- Every Solunized theme and system dark: default, push and destructive distinguishable; dialog stands out → `test/dialog_test.rb` `test_the_dialog_surface_has_a_border_and_shadow` plus browser check B2
- Phone: no page in `demo.html` scrolls sideways → `test/dialog_test.rb` `test_a_dialog_never_exceeds_the_viewport_width` plus browser check B3
- Changelog `### Upgrading` covers plain controls, `<form method="dialog">` Cancel, `.button-danger` on `Delete…`, action-row and dialog markup → `test/changelog_upgrading_test.rb` `test_the_latest_entry_tells_apps_how_to_upgrade`
- Test suite and linters pass → check: `bundle exec rake test && yarn lint:css && yarn lint:browsers && bundle exec rubocop && yamllint --strict .`

Per changed file, the unit tests expected, named as behaviour (each asserts the source partial and `mvpa.css`):

- `1_forms.css`: `test_the_shared_button_rule_reads_bg_fg_and_border_tokens`, `test_the_default_tokens_have_zero_specificity`, `test_the_push_tokens_have_zero_specificity_and_come_after_the_default`, `test_a_form_footer_resets_the_global_footer_rule`, `test_footer_children_lose_their_own_margins`.
- `5_buttons.css`: `test_success_danger_and_warning_set_light_text_and_no_border`, `test_the_header_nav_link_hover_skips_role_button_links`.
- `0_header.css`: `test_a_header_nav_form_button_is_no_longer_forced_red` (refutes the rule in source and bundle).
- `12_dialog.css`: `test_the_dialog_backdrop_uses_a_literal_colour` (no `var(` inside the `::backdrop` rule), `test_a_dialog_footer_is_a_right_aligned_row`.
- `3_animations.css`: `test_the_dialog_animation_only_runs_without_a_reduced_motion_preference`.
- `11_turbo-transitions.css`: `test/page_transitions_test.rb` `test_only_the_site_footer_gets_a_view_transition_name`.
- `2_eink.css`: `test_the_secondary_button_matches_the_push_button_on_eink`, `test_pressing_a_destructive_button_inks_it_without_a_filter_on_eink`, `test_disabled_comes_after_every_other_button_rule_on_eink`, each for `eink-light` and `eink-dark`.
- `README.md`: `test/readme_test.rb` `test_readme_explains_that_a_submit_is_filled_and_type_button_is_plain`, `test_readme_shows_the_action_row_footer_markup`, `test_readme_shows_the_dialog_with_a_method_dialog_cancel`.
- `demo.html`: `test_the_demo_has_a_main_page_header_with_a_link_and_a_patch_form`, `test_the_demo_shows_an_edit_row_with_delete_first`, `test_the_demo_shows_a_new_row_with_only_cancel_and_save`, `test_the_demo_links_the_dialog_partial`. Existing `demo_stylesheet_links_test.rb` and `demo_subsection_structure_test.rb` keep passing.

Browser checks (step 10), in headless Chrome at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`. Build throwaway copies of `demo.html` in the session scratchpad, never in the repo. Each copy sets `data-theme` on `<html>` and, for dialog shots, calls `document.getElementById('confirm-delete').showModal()` on load. Take shots with `--headless=new --screenshot=<file> --window-size=<w>,<h> file://<copy>`.

- B1: at 1280 px and 375 px, Solunized Light: the hierarchy, the three action rows and the open dialog match the acceptance criteria (positions, fill, border, red).
- B2: the same shots for `solunized-dark`, `solunized-white`, `solunized-black`, no `data-theme` with Chrome's `--force-dark-mode` switch (system dark; confirm from the shot that the page renders dark before judging it, and find another emulation if it does not), `eink-light` and `eink-dark`: default, push and destructive are distinguishable; the dialog stands out from the backdrop.
- B3: at 375 px, a copy whose inline script writes `document.documentElement.scrollWidth <= window.innerWidth` into `document.title`, read with `--dump-dom`: `true` for `demo.html`, with and without the dialog open.

Test setup: no fixtures or fakes. Tests read the partials, `mvpa.css`, `demo.html`, `README.md` and `CHANGELOG.md` from disk, as the existing tests do (`File.read(File.expand_path("../…", __dir__))`). Demo tests parse `demo.html` with Nokogiri, already a test dependency (`test/demo_subsection_structure_test.rb`). Each CSS assertion checks both the source partial and `mvpa.css`, so the manifest cannot drift.

---
Domain skills applied: rails-ui (classless semantic markup, interaction placement, accessibility), dependencies (rejected Playwright; no new dependency), rails-testing (Minitest, behaviour-named tests).

## Critique

### Round 1 (codex exec -p terra)

- `header nav a:hover, header nav a:visited` in `10_navigation.css` (0,1,2) beats the shared button rule's colour, so a filled `a[role="button"]` in the page header gets dark text on hover and visited → fixed (decision 3 adds a `main > header nav a[role="button"]` colour rule for normal, hover and visited; the Proof line asserts it)
- The dark-theme border swap in `1_forms.css` sets `border` directly and overrides the planned transparent variant and DELETE borders in dark mode → fixed (decision 1 now names it as a deliberate exception: filled buttons keep the hairline that replaces the shadow on dark canvases; the rule and its test stay unchanged)
- The e-ink destructive look names only `.button-danger`, so a DELETE-form button keeps the filled-default look on e-ink; `.button-danger:active` also applies `filter: brightness(1.05)` there → fixed (decision 12 adds an e-ink selector for the DELETE-form button and `filter: none` on the pressed destructive rule; two Proof tests cover them)
- Action-row footers inherit `view-transition-name: footer` from `11_turbo-transitions.css`, and duplicate names make the browser skip the View Transition → fixed (decision 14 narrows the selector to `body > footer`, with a test in `test/page_transitions_test.rb`)
- An inline `onclick` opener in `demo.html` contradicts the intent's exclusion of JavaScript → fixed (the demo uses declarative Invoker Commands `command="show-modal"`; the browser checks open the dialog only in scratchpad copies; out-of-scope list updated)
- The rewritten README "Buttons" section has no test → fixed (three new `test/readme_test.rb` tests listed under Files that change, Order of work step 8 and Proof)
- The `::backdrop` rationale wrongly ties inheritance to specific browser versions → fixed (decision 10 now says custom properties are not reliably available in `::backdrop` across the floor; the literal colour and its test stay)
