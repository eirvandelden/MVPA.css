# Review: rail-hub-column-tiles

## Round 1 — 2026-11-11T13:49Z — cb1a364

Suite and linters green before review: `bundle exec rake test` (347 runs, 0 failures), `bundle exec rubocop`, `npm run lint:css`, `npm run lint:browsers`, `yamllint --strict .`.

Compliance: every acceptance criterion in `intent.md` maps to a test in the diff (criteria 1–17 → `test/rail_test.rb`, `test/landing_tiles_test.rb`, `test/demo_rail_shell_test.rb`), and every test named in `plan.md` `## Proof` exists. No glossary `Avoid:` word, Law of Demeter chain or N+1 loop in production code; no security surface (static CSS and demo markup).

- [ ] Important: an existing test is deleted: `test_the_demo_has_a_landing_tile_link_with_a_badge`. `plan.md` (`## Files that change`) names the removal, because the intent removes the demo's "Landing tile" example; the content-badge case keeps coverage through `test_the_demo_has_a_four_digit_badge`. Raised because every deleted test is ranked Important; close it with the reason if the plan's sanction suffices. — `test/demo_segmented_control_and_badges_test.rb:76` (origin/main) → dismissed: plan.md `## Files that change` sanctions the removal, because the intent removes the demo's "Landing tile" example; the content-badge case stays covered by `test_the_demo_has_a_four_digit_badge`.
- [ ] Nit: the phone landing-tile list sets `overflow: hidden`, which clips the `*:focus-visible` outline (2px at a 2px offset, `0_base/2_typography.css:56`) of each full-width row on its left and right edges, and on the top of the first row and the bottom of the last. The rows paint no background and no transform there, so the clip seems to serve nothing. — `app/assets/stylesheets/mvpa/2_modules/16_rail.css:265` → fixed (Show the whole focus ring on a phone landing tile row)
- [ ] Nit: the new public `CssSourceHelper#media_blocks` is not in `### Signatures` (which states "no Ruby production code"; only `## Design decisions` names it) and has no inline RBS signature. — `test/css_source_helper.rb:34` → fixed (Add an inline RBS signature to CssSourceHelper#media_blocks)
- [ ] Nit: `assert_equal "#landing-page", hub_column.at_css('a[href="#landing-page"]')["href"]` is a tautology: it finds the link by that href, so it can only pass or raise `NoMethodError` on nil. `refute_nil hub_column.at_css('a[href="#landing-page"]')` states the intent and fails as an assertion. — `test/demo_rail_shell_test.rb:58` → fixed (Assert that the hub column links the landing page)

## Round 2 — 2026-11-11T13:53Z — 8919711

Suite and linters green before review: `bundle exec rake test` (347 runs, 0 failures), `bundle exec rubocop`, `npm run lint:css`, `npm run lint:browsers`, `yamllint --strict .` (run with a locally re-resolved `Gemfile.lock`, then restored).

Round 1 closures hold: `overflow: hidden` is gone from the phone tile list in `16_rail.css` and `mvpa.css`, and `test_tiles_become_rows_with_a_trailing_chevron_on_a_phone` now refutes it (d9099f3); `CssSourceHelper#media_blocks` has its inline RBS signature and `### Signatures` lists it (fee1276); `test_the_demo_landing_page_has_four_tiles_with_text_counts` uses `refute_nil` on the hub column link (8919711); the deleted `test_the_demo_has_a_landing_tile_link_with_a_badge` is sanctioned by `plan.md` `## Files that change`.

Compliance: every acceptance criterion in `intent.md` still maps to a test in the diff, and every test named in `plan.md` `## Proof` exists. The bundle's Rail section is byte-identical to `16_rail.css`, and both e-ink themes carry the same seven rail rules in `2_eink.css` and `mvpa.css`. No glossary `Avoid:` word, Law of Demeter chain, N+1 loop or unsigned public method; no security surface.

Nothing found.
