# Plan: Link buttons get button hover feedback

From `intent.md` (2026-10-23). Status: accepted.

## Design

### Domain terms

Page-action link: an `<a>` in `main > header nav`, styled as a plain push button (`5_buttons.css`). Link button: `a[role="button"]`, styled as a button (`1_forms.css`). Both are existing terms; no new ones.

### Diagrams

Not affected: CSS only, no objects.

### Signatures

Not affected: no Ruby classes change. Not checked: project declined Steep and rbs_rails.

### Complexity

Not affected: two selectors join existing rule lists.

### Invariants

- A link button never underlines in any state. Enforced by `text-decoration: none` on `a[role="button"]` and the hover rule. Proven by a test.
- Eink themes show no brightness change. Enforced by their existing `filter: none` overrides, extended to page-action links.

### Alternatives

- New class such as `.link-button`: rejected, classless-first.
- Separate hover rules in `5_buttons.css`: rejected, duplicates the filter and press values that `1_forms.css` owns.
- Chosen: add the two selectors to the hover and active lists in `1_forms.css`, so links and buttons share one definition.

## Design decisions

- Link buttons and page-action links share the button hover (`filter: brightness(1.1)`) and press (`scale(var(--animation-scale-press))`) rules. Intent left the exact feedback open; the button values keep links and neighbouring buttons identical.
- Departure from the first design: the link selectors sit in their own hover and press rules right after the button ones in `1_forms.css`, not in the shared lists. An existing test locates the button press rule by its exact selector list, and a bug fix does not touch existing tests.
- Review round 1: the underline was the wiggle `::after` bar in `0_base/3_animations.css`, not `text-decoration`. Its three selectors now skip `main > header nav a` and `a[role="button"]`. The link hover and press rules use `:where()`, so `.button-danger:active` wins on a link as on a button. The e-ink themes also reset `filter` on `:active`. Tests that pin the wiggle selector string, and the two changelog tests, follow the selectors and entries they read.
- Review round 3: a link item in a pull-down menu matches `main > header nav a`, so it gets the same hover, press and no wiggle underline. The changelog entry says so; the menu's `form > button` items already behaved this way.
- The `transition` already lives on `a[role="button"]`. Page-action links gain the same `transition` so the hover animates.

## Integration points

`1_forms.css` (hover and active lists), `5_buttons.css` (page-action link), `4_theme/2_eink.css` (flat themes), `mvpa.css` (manifest), `CHANGELOG.md`.

## Files that change

- `app/assets/stylesheets/mvpa/2_modules/1_forms.css` — add `:where(a[role="button"], main > header nav a)` hover and press rules after the button ones.
- `app/assets/stylesheets/mvpa/2_modules/5_buttons.css` — add `transition` to `main > header nav a`; add `text-decoration: none` to the role="button" hover guard.
- `app/assets/stylesheets/mvpa/0_base/3_animations.css` — the wiggle underline's three selectors skip `main > header nav a` and `a[role="button"]`.
- `app/assets/stylesheets/mvpa/4_theme/2_eink.css` — `filter: none` for page-action link hover and press in both eink themes.
- `app/assets/stylesheets/mvpa/mvpa.css` — the same edits.
- `test/link_button_hover_test.rb` — new.
- `CHANGELOG.md` — one bullet at the end of the existing 2026-10-26 entry's `### Fixed` (the sidebar change owns that entry and its `### Upgrading`; this fix adds no upgrade step).

## Order of work

1. Write `test/link_button_hover_test.rb` for the three criteria. Run it. Watch it fail.
2. Edit the `1_forms.css` and `5_buttons.css` rules. Run the test until green.
3. Check the eink themes against `2_eink.css:85,148,188,356,419,459`. Extend the `filter: none` overrides only if the hover would otherwise brighten.
4. Mirror every edit in `mvpa.css`. Run `test/mvpa_manifest_sync_test.rb`.
5. Add the changelog entry. Run `test/changelog_upgrading_test.rb`.
6. Open `demo.html`, hover a page-action link and `a[role="button"]`, and confirm the brightness change, the press and the absent underline.
7. Run the full suite and all linters.

## Risks

- The source shows no underline on hover for these links when `<header>` is a direct child of `<main>`. The reported underline may come from an app pinned to an older SHA, or from an app stylesheet. The fix adds feedback and an explicit guard; step 6 and a note in the changelog entry tell the user to bump the pinned `ref`.
- No browser is installed here, so the visual check uses `open demo.html` by hand. Tests assert the CSS text only.
- Specificity: `main > header nav a:hover` (0,1,4) must beat `header nav a:hover` (0,1,3); the test asserts the filter lives in a rule matching the page-action link.

## Proof

- Hovering a page-action link brightens it and shows no underline → `test/link_button_hover_test.rb` `test_a_hovered_link_button_or_page_action_link_brightens_and_never_underlines`
- Pressing a page-action link scales it down like a button → `test/link_button_hover_test.rb` `test_a_pressed_page_action_link_scales_down`
- Hovering an `a[role="button"]` link brightens it and shows no underline → the same test, because one `:where()` rule serves both links
- Neither link draws the wiggle underline bar → `test/link_button_hover_test.rb` `test_the_hover_wiggle_underline_skips_page_action_links_and_link_buttons`
- A page-action link animates its hover → `test/link_button_hover_test.rb` `test_a_page_action_link_animates_its_hover`
- Invariant: eink themes do not filter a page-action link on hover or press, enforced by `2_eink.css` → `test/link_button_hover_test.rb` `test_eink_themes_keep_page_action_links_flat_on_hover_and_press`
- Every assertion runs against both the partials and `mvpa.css` (`CssSourceHelper#each_source`).
- Visual: → check: open `demo.html`, hover and press a page-action link and `Link as Button`.

Per changed file, the unit tests expected:
- `test/link_button_hover_test.rb`: the five tests named above.

Test setup: Minitest reading CSS text through `test/css_source_helper.rb`; no fixtures.

---
Domain skills applied: rails-ui (CSS and HTML structure), ruby-style.

Reproduction: committed
