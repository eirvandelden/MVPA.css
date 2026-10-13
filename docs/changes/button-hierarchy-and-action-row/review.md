# Review: button-hierarchy-and-action-row

## Round 1 — 2026-10-13T10:46Z — fa035db

No `REVIEW.md` in the repository; the default Bugs, Security and Compliance passes ran. Baseline: `bundle exec rake test` (144 runs, 0 failures), `yarn lint:css`, `yarn lint:browsers`, `bundle exec rubocop` and `yamllint --strict .` all pass. Every test named in `plan.md`'s Proof exists. No existing test was weakened: the removed e-ink pressed-state test is replaced by per-variant pressed tests, and the `page_header_component_test.rb` flips match the intended removal.

Security: nothing found (CSS, Markdown and static demo markup only; no script added).

- [x] Important: An `<input type="submit">` (Rails `f.submit`, the usual `Save`) or an `<a role="button">` in an action-row footer keeps the shared button rule's `margin-inline-end` and `margin-block-end`. `input[type="submit"]` and `a[role="button"]` (0,1,1) beat the reset `:is(form, dialog) > footer > *` (0,0,2). On desktop `Save` is not flush right and sits higher than `Cancel`, because `align-items: center` counts the bottom margin. On a phone it gets `inline-size: 100%` plus a right margin, so it overflows the footer. The demo and tests only use `<button>`, so nothing catches it. The same gap exists in `dialog > footer button` (`12_dialog.css:40`) for an `input[type="submit"]` inside a dialog form. — `app/assets/stylesheets/mvpa/2_modules/1_forms.css:272` → fixed (Zero the margins of submit inputs and role=button links in action rows)
- [x] Important: On e-ink a button with the paper look but no `type="button"` gets no press feedback. The DELETE-form button (`Uitloggen`, the `button_to … method: :delete` case) and a submit with `.button-secondary` both rest on paper. When pressed they match only the filled-default pressed rule `[data-theme="eink-light"] button:active`, which also sets paper, so nothing changes. Plan decision 12 says destructive buttons invert to ink when pressed; only `button.button-danger:active` does. The old `.button-secondary` submit did invert before this branch. Same in `eink-dark` (`2_eink.css:447`). — `app/assets/stylesheets/mvpa/4_theme/2_eink.css:182` → fixed (Give e-ink secondary and danger links their looks and press feedback)
- [x] Nit: Plan step 10 asks to record the browser-check evidence (B1–B3 screenshots and the `scrollWidth` result) in the review or PR notes. The branch records none. Commit `fa035db` shows the check ran, so put the evidence in the PR body at `finish`. — `docs/changes/button-hierarchy-and-action-row/plan.md:204` → dismissed: no code change; the coordinator re-ran the browser checks on all six themes at 1200px and 600px, and `finish` puts that evidence in the PR body, as the finding asks
- [x] Nit: Every filled button grows by 2px: `border: none` became `border: 1px solid var(--button-border-color)`. That can shift tight layouts in apps. The `### Upgrading` list in the changelog does not mention it. — `app/assets/stylesheets/mvpa/2_modules/1_forms.css:133` → fixed (Mention the new 1px button border in the Upgrading notes)
- [x] Nit: On e-ink, `a[role="button"].button-secondary` and `a[role="button"].button-danger` keep the ink-filled default look. `[data-theme="eink-light"] a[role="button"]` (0,2,1) beats `.button-secondary` (0,2,0), and the destructive rule matches only `button.button-danger`. A destructive or secondary link then looks like the default action on e-ink. — `app/assets/stylesheets/mvpa/4_theme/2_eink.css:158` → fixed (Give e-ink secondary and danger links their looks and press feedback)

## Round 2 — 2026-10-13T10:47Z — fa035db (codex)

- [x] Important: A `main > header nav` link with `role="button"` gets the plain surface background from the header push-button rule, but the later rule gives it the filled button text colour. The text is low contrast, and it contradicts the documented behaviour that a `role="button"` link stays filled. Exclude `[role="button"]` from the plain-background rule or give it a filled background. — `app/assets/stylesheets/mvpa/2_modules/5_buttons.css:50` → dismissed: does not reproduce. `a[role="button"]` (0,1,1) beats `main > header nav a` (0,0,4) for `background-color`, so the link stays filled. Headless Chrome computes `main > header nav a[role="button"]` as primary background with light text on solunized-light, and ink background with paper text on eink-light

## Round 3 — 2026-10-13T10:59Z — 6464d98

No `REVIEW.md` in the repository; the default Bugs, Security and Compliance passes ran. Baseline: `bundle exec rake test` (149 runs, 0 failures), `yarn lint:css`, `yarn lint:browsers`, `bundle exec rubocop` and `yamllint --strict .` all pass. Every test named in `plan.md`'s Proof exists. The round 1 and 2 fixes hold for `<button>` and `a[role="button"]`. No existing test was weakened since round 1.

Security: nothing found (CSS, Markdown and static demo markup only; no script added).

- [x] Important: On e-ink an `<input>` that carries a variant class keeps the wrong look. `[data-theme="eink-light"] input[type="submit"]` (0,2,1) beats `[data-theme="eink-light"] .button-secondary` (0,2,0), and the destructive rule lists only `button.button-danger` and `a[role="button"].button-danger`. Headless Chrome on `eink-light` computes: `<input type="submit" class="button-secondary">` (Rails `f.submit "Cancel", class: "button-secondary"`) ink-filled, like the default action; `<input type="submit" class="button-danger">` ink-filled with a 1px border, no double border; `<input type="button" class="button-danger">` the paper push look. Round 1 named "a submit with `.button-secondary`"; the fix covers it only for `<button>`. `test_pressing_a_secondary_submit_or_link_inks_it_on_eink` (`test/eink_theme_test.rb:271`) checks only the pressed rule, so it passes while a resting secondary submit input is already ink and pressing it changes nothing. Same in `eink-dark` (`2_eink.css:433`). — `app/assets/stylesheets/mvpa/4_theme/2_eink.css:161` → fixed (Cover submit inputs in the e-ink variant looks)
- [x] Nit: `dialog > footer button { margin: 0; }` repeats what `:is(form, dialog) > footer :is(button, input, a[role="button"])` in `1_forms.css` already sets, at lower specificity. The phone rule beside it also splits `dialog > footer button` and `dialog > footer :is(input, a[role="button"])` where one `:is(button, input, a[role="button"])` would do. — `app/assets/stylesheets/mvpa/2_modules/12_dialog.css:40` → fixed (Drop the dialog's duplicate footer margin reset)

## Round 4 — 2026-10-13T11:05Z — 6464d98 (codex)

No findings.

## Round 5 — 2026-10-13T12:09Z — d40db30

No `REVIEW.md` in the repository; the default Bugs, Security and Compliance passes ran. Baseline: `bundle exec rake test` (148 runs, 0 failures), `yarn lint:css`, `yarn lint:browsers`, `bundle exec rubocop` and `yamllint --strict .` all pass. Every test named in `plan.md`'s Proof exists. The count drops from 149 to 148 because `71a0830` merges the two e-ink link tests into `test_variant_looks_cover_inputs_and_links_on_eink`. That is not a weakening: the links now share the `:is(button, input, a).button-*` selectors, so the existing rule-body tests for secondary, danger and pressed danger cover them.

Bugs: the round 3 fix holds. On e-ink, `:is(button, input, a).button-*` (0,2,1) follows the filled and push rules, so it beats `input[type="submit"]` and `a[role="button"]`. Each pressed variant (0,3,1) follows the filled pressed rule, and disabled (0,2,1 and up, last) still wins over every resting look. A plain `<a class="button-*">` without `role="button"` still gets the e-ink look, as on `main`, so that is not a regression. Dropping `dialog > footer button { margin: 0 }` changes nothing: `:is(form, dialog) > footer :is(button, input, a[role="button"])` (0,1,3) zeroes the same margins.

Security: nothing found (CSS, Markdown and static demo markup only; no script added).

- [x] Nit: `test_a_dialog_footer_is_a_right_aligned_row` runs inside `each_source(DIALOG)`, but its new last assertion reads `partial("2_modules/1_forms.css")` both times. The `mvpa.css` pass therefore checks the partial again, never the bundle. `test_submit_inputs_and_role_button_links_in_a_footer_lose_their_margins` (`test/action_row_test.rb:43`) already checks that rule in both files. Drop the assertion, or move it out of the loop. — `test/dialog_test.rb:61` → fixed (Drop the dialog test's duplicate forms-partial assertion)
- [x] Nit: The working tree has an uncommitted `Gemfile.lock` change. It only moves the gem's git-SHA version stamp (`0.1.0.pre.git.cdc8355` → `d40db30`), and every new commit makes it stale. Leave it out of this branch; `main` updates it in its own `chore` commits. — `Gemfile.lock:19` → dismissed: no branch change; `bundle exec` rewrites the stamp locally, the coordinator reverts it after each run and never commits it

## Round 6 — 2026-10-13T12:20Z — d40db30 (codex)

- [x] Important: When a `main > header nav` link has `role="button"`, the header rule's more-specific background declaration overrides the generic button styling, so the link stays outlined instead of filled as documented. Exclude `[role="button"]` or set its filled background explicitly. — `app/assets/stylesheets/mvpa/2_modules/5_buttons.css:50` → dismissed: same finding as round 2, disputed for two rounds and settled by Etienne (dismiss with evidence). `a[role="button"]` (0,1,1) beats `main > header nav a` (0,0,4); headless Chrome computes the link filled on all six themes, e.g. solunized-light `oklch(0.5241 0.1709 254.71)` background with `oklch(0.9898 0.0025 228.78)` text, eink-light `rgb(0, 0, 0)` with `rgb(255, 255, 255)`

## Round 7 — 2026-10-13T12:31Z — 037b9ce

No `REVIEW.md` in the repository; the default Bugs, Security and Compliance passes ran. Baseline: `bundle exec rake test` (148 runs, 0 failures), `yarn lint:css`, `yarn lint:browsers`, `bundle exec rubocop` and `yamllint --strict .` all pass. Since round 5 only `1bda7e6` touched code: it drops the duplicate forms-partial assertion from `test/dialog_test.rb`, as round 5 asked. `test/action_row_test.rb:43` still checks that rule in the partial and in `mvpa.css`, so no coverage is lost. Every test named in `plan.md`'s Proof exists.

Security: nothing found (CSS, Markdown and static demo markup only; no script added).

Compliance: the diff stays inside the intent's scope. No new class, no JavaScript, and `mvpa.css`, `demo.html` and the README stay in sync with the partials.

- [x] Important: On e-ink, a `role="button"` link with `.button-danger` in `main > header nav` loses its text on hover and once visited. `main > header nav a[role="button"]:hover` and `:visited` (0,2,4) set `color: var(--button-fg)` and beat the e-ink destructive rule `:is(button, input, a).button-danger` (0,2,1). `.button-danger` sets `--button-fg` to `--color-bg-lightest`, which e-ink maps to paper. The e-ink destructive look is also paper, so the text vanishes. Headless Chrome with a forced `:hover` computes `rgb(255, 255, 255)` text on `rgb(255, 255, 255)` on `eink-light`, and `rgb(0, 0, 0)` on `rgb(0, 0, 0)` on `eink-dark`. At rest the text is readable, because there the e-ink rule wins. A plain or `.button-secondary` `role="button"` link stays readable. On `main` the e-ink danger button was ink-filled, so white text was correct; this branch introduced both halves. Fix it in the e-ink theme: give the destructive selectors a matching `main > header nav a[role="button"].button-danger:is(:hover, :visited)` colour, or set `--button-fg` there instead of `color`. Add a test for both e-ink themes. — `app/assets/stylesheets/mvpa/2_modules/5_buttons.css:66` → fixed (Keep e-ink destructive header links readable on hover)

## Round 8 — 2026-10-13T12:35Z — 037b9ce (codex)

No findings. The test suite passes: 148 runs, 1055 assertions, no failures.

## Round 9 — 2026-10-13T12:36Z — 1d8de0f

No `REVIEW.md` in the repository; the default Bugs, Security and Compliance passes ran. Baseline: `bundle exec rake test` (149 runs, 1059 assertions, 0 failures), `yarn lint:css`, `yarn lint:browsers`, `bundle exec rubocop` and `yamllint --strict .` all pass. Since round 7 only `6d57e13` touched code. It adds `--button-fg` (ink) to the e-ink destructive rule in `2_eink.css` and `mvpa.css`. It also adds `test_a_destructive_header_link_keeps_ink_text_on_hover_on_eink`, which takes the count from 148 to 149. No existing test was weakened.

Bugs: the round 7 fix holds. The e-ink destructive rule (0,2,1) beats `.button-danger` (0,1,0) for `--button-fg`, so the header link's `:hover` and `:visited` rule (0,2,4) now reads ink. Headless Chrome computes `--button-fg` as `black` on paper on `eink-light` and `white` on ink on `eink-dark`. The colour matches the e-ink destructive text in both themes. Pressing still inverts: the pressed destructive rule (0,3,1) beats the hover rule (0,2,4). Warning and success header links keep a `--button-fg` that contrasts their fill on both e-ink themes. `--button-fg` has no other reader, so the extra declaration on a DELETE form's button changes nothing. Solunized themes are unchanged.

Security: nothing found (CSS, Markdown and static demo markup only; no script added).

Compliance: the diff stays inside the intent's scope. No new class, no JavaScript, and `mvpa.css` stays in sync with the partials.

No findings.
