# Review: update-dependencies

## Round 1 — 2026-10-13T08:18:23Z — 6d4c139

Base: `origin/main` (412cc74). Ruby commands ran through `rv run --no-install` on Ruby 4.0.7.

Current state of the suite: `bundle exec rake test` passes (90 runs, 0 failures). `bundle exec rubocop` (also with `--parallel --cache false`), `yarn lint:css`, `yarn lint:browsers`, `yamllint --strict .`, `yarn install --frozen-lockfile` and `gem build mvpa-css.gemspec` all pass. The engine smoke check prints `Rails::Engine`.

Bugs pass: no defects in the changed files. Security pass: no new gem or npm source; every `yarn.lock` entry resolves from `registry.yarnpkg.com`, gems come from `gem.coop` and the unchanged rubocop-eirvandelden GIT revision `1e2e033`; `CHECKSUMS` lines are present for every bumped gem.

Compliance — acceptance criteria against proof:

- `bundle outdated` lists nothing behind → command check; red on HEAD (see first finding).
- `yarn outdated` lists nothing behind → command check; passes (exit 0, no table).
- Transitive npm packages at newest in range (plan Proof) → scratch `yarn install`; red on HEAD (see second finding).
- stylelint `^17.16.0` resolving to 17.16.0 → `package.json` and `yarn.lock` grep; passes.
- `.ruby-version` reads 4.0.7, suite passes on 4.0.7 → `test/continuous_integration_test.rb` `test_the_project_pins_the_ruby_it_runs_on` exists; `ruby -v` prints 4.0.7; suite passes.
- Bundler 4.0.22 (plan Proof) → `BUNDLED WITH 4.0.22`; `Bundler::VERSION` prints 4.0.22.
- `rake test` passes → passes.
- rubocop, stylelint, browserslist, yamllint pass → all pass.
- `gem build` succeeds → passes.
- Same direct dependencies → `git diff origin/main...HEAD -- Gemfile mvpa-css.gemspec .github .rubocop.yml CHANGELOG.md` is empty; `package.json` changes only the stylelint range; no `yarn.lock` package name added or removed outright.

No existing test was weakened, skipped or deleted; the diff touches nothing under `test/`.

- [ ] Important: `rv run --no-install bundle outdated` exits 1 on HEAD. It lists rubocop 1.91.0 → 1.92.0 (released 2026-10-10) and json 3.0.2 → 3.1.0 (released 2026-10-13). Both came out after the last gem commit (2026-10-09), so the acceptance criterion and its Proof command are red at review time. Bump both (rubocop is a minor that can add cops), or record why the "day of implementation" wording covers them — `Gemfile.lock:133` →
- [ ] Important: The plan's Proof "a fresh `yarn install --ignore-scripts` of `package.json` produces an identical `yarn.lock`" fails on HEAD. The fresh lockfile resolves newer in-range versions: baseline-browser-mapping 2.11.27 → 2.11.28, electron-to-chromium 1.5.450 → 1.5.453, node-releases 2.0.57 → 2.0.58, nanoid `^3.3.19` → `^3.3.20`, and a newer postcss 8.5.x. Same upstream drift as the finding above — `yarn.lock:174` →
- [ ] Nit: Two commit subjects understate their content. `fc51e09` "bump Rails to 8.1.4" also bumps io-console, rbs and rdoc; `922b09b` "bump rubocop-minitest, rubocop-rails and rubocop-yard" also bumps regexp_parser, unicode-display_width and unicode-emoji. Bundler unlocks the named gems' dependencies, so the content is expected, but no subject or body names these gems and the plan's step 7 commit `chore(deps): bump transitive gems` never appears. The remaining transitive commit `6d4c139` (uri, prettyprint) also lands after the npm commits, out of plan order — `Gemfile.lock:66` →
