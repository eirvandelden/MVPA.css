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

- [x] Important: `rv run --no-install bundle outdated` exits 1 on HEAD. It lists rubocop 1.91.0 → 1.92.0 (released 2026-10-10) and json 3.0.2 → 3.1.0 (released 2026-10-13). Both came out after the last gem commit (2026-10-09), so the acceptance criterion and its Proof command are red at review time. Bump both (rubocop is a minor that can add cops), or record why the "day of implementation" wording covers them — `Gemfile.lock:133` → fixed in `cff98d8` (rubocop 1.92.0, json 3.1.0).
- [x] Important: The plan's Proof "a fresh `yarn install --ignore-scripts` of `package.json` produces an identical `yarn.lock`" fails on HEAD. The fresh lockfile resolves newer in-range versions: baseline-browser-mapping 2.11.27 → 2.11.28, electron-to-chromium 1.5.450 → 1.5.453, node-releases 2.0.57 → 2.0.58, nanoid `^3.3.19` → `^3.3.20`, and a newer postcss 8.5.x. Same upstream drift as the finding above — `yarn.lock:174` → fixed in `72a48f9` (`yarn upgrade`; a fresh install now matches).
- [x] Nit: Two commit subjects understate their content. `fc51e09` "bump Rails to 8.1.4" also bumps io-console, rbs and rdoc; `922b09b` "bump rubocop-minitest, rubocop-rails and rubocop-yard" also bumps regexp_parser, unicode-display_width and unicode-emoji. Bundler unlocks the named gems' dependencies, so the content is expected, but no subject or body names these gems and the plan's step 7 commit `chore(deps): bump transitive gems` never appears. The remaining transitive commit `6d4c139` (uri, prettyprint) also lands after the npm commits, out of plan order — `Gemfile.lock:66` → subjects fixed in `266df2d` and `df78a61`. Commit order dismissed: each commit is still one logical change, and reordering only rewrites history for no reader benefit.

## Round 2 — 2026-10-13T13:09:24Z — 72a48f9

Base: `origin/main` (77697d4). The branch is rebased onto it; the merge base is 77697d4. Ruby commands ran through `rv run --no-install` on Ruby 4.0.7.

Current state of the suite: `bundle exec rake test` passes (149 runs, 0 failures). `bundle exec rubocop` (also with `--parallel --cache false`), `yarn lint:css`, `yarn lint:browsers`, `yamllint --strict .`, `yarn install --frozen-lockfile` and `gem build mvpa-css.gemspec` all pass. The engine smoke check prints `Rails::Engine`.

Round 1 findings, checked against `origin/main...HEAD`:

- Important 1 (`bundle outdated` red): closed by `cff98d8`. It bumps rubocop 1.91.0 → 1.92.0 and json 3.0.2 → 3.1.0; the only other lockfile change is rubocop's own `regexp_parser` constraint. `bundle outdated` now prints `Bundle up to date!` and exits 0. RuboCop reports no offenses.
- Important 2 (fresh `yarn.lock` differs): closed by `72a48f9`. A fresh `yarn install --ignore-scripts` of `package.json` in a scratch directory now produces a `yarn.lock` identical to the repository one. `yarn outdated` exits 0.
- Nit (commit subjects): subjects are closed by the rewording in `266df2d` and `df78a61`; each subject now names every gem its commit bumps. The order part stays open by choice: `3c91d33` (uri, prettyprint) still lands after the npm commits. Whoever closes the round-1 nit records that dismissal.

Compliance — acceptance criteria against proof:

- `bundle outdated` lists nothing behind → command check; passes.
- `yarn outdated` lists nothing behind → command check; passes.
- Transitive npm packages at newest in range (plan Proof) → scratch `yarn install`; identical.
- stylelint `^17.16.0` resolving to 17.16.0 → `package.json` and `yarn.lock` grep; passes.
- `.ruby-version` reads 4.0.7, suite passes on 4.0.7 → `test/continuous_integration_test.rb` `test_the_project_pins_the_ruby_it_runs_on`; `ruby -v` prints 4.0.7; suite passes.
- Bundler 4.0.22 (plan Proof) → `BUNDLED WITH 4.0.22`; `Bundler::VERSION` prints 4.0.22.
- rubocop, stylelint, browserslist, yamllint, `gem build` → all pass.
- Same direct dependencies → `git diff origin/main...HEAD -- Gemfile mvpa-css.gemspec .github .rubocop.yml CHANGELOG.md test` is empty; `package.json` changes only the stylelint range; the rubocop-eirvandelden GIT revision stays `1e2e033`.

Bugs and security passes: nothing new. The two fix commits change lockfiles only, from the same sources as before.

No new findings.

## Round 3 — 2026-10-16T18:49:32Z — cdd537a

Base: `origin/main` (77697d4), unchanged since round 2. New since round 2: `7db8400` (round-1 closures), `f6bf932` (intent and plan addendum for the daily hook refetch) and `cdd537a` (`refetch_frequency: 24h`, `test/git_hooks_test.rb`, the `AGENTS.md` gotcha line). Ruby commands ran through `rv run --no-install` on Ruby 4.0.7.

Current state of the suite: `bundle exec rake test` passes (150 runs, 0 failures), and `test/git_hooks_test.rb` passes alone. `bundle exec rubocop` (also with `--parallel --cache false`), `yarn lint:css`, `yarn lint:browsers`, `yamllint --strict .`, `yarn install --frozen-lockfile`, `gem build mvpa-css.gemspec` and `lefthook validate` all pass. The engine smoke check prints `Rails::Engine`. The plan's `lefthook run pre-commit` check was not repeated here, because it runs hook jobs; `lefthook validate` stood in for it.

Addendum check:

- Scope: `cdd537a` touches only `lefthook.yml`, `test/git_hooks_test.rb` and `AGENTS.md`, as the addendum lists, in one commit with the planned subject. `CLAUDE.md` is a symlink to `AGENTS.md`, so it follows.
- Test first: the history cannot show red, because the test and the change share one commit. Run against `origin/main`'s `lefthook.yml` in a scratch copy, the test fails with "lefthook never refetches git@github.com:eirvandelden/dotfiles without refetch_frequency". So it was red before the change.
- Docs: lefthook's `refetch_frequency` docs (evilmartians/lefthook `docs/configuration/refetch_frequency.md`) back every claim. A duration refetches only once that much time has passed since the last fetch. A failed fetch warns and keeps the cached copy. A remote without a `ref` should set a frequency. `refetch: true` refetches on every run. The `AGENTS.md` line matches this.

Compliance — acceptance criteria against proof:

- `bundle outdated` lists nothing behind → command check; red again (see first finding).
- `yarn outdated` lists nothing behind → command check; passes (exit 0).
- Transitive npm packages at newest in range (plan Proof) → scratch `yarn install`; red again (see second finding).
- stylelint `^17.16.0` resolving to 17.16.0 → passes.
- `.ruby-version` reads 4.0.7, suite passes on 4.0.7 → `test/continuous_integration_test.rb` `test_the_project_pins_the_ruby_it_runs_on`; passes.
- Bundler 4.0.22 (plan Proof) → passes.
- rubocop, stylelint, browserslist, yamllint, `gem build` → all pass.
- Same direct dependencies → `git diff origin/main...HEAD -- Gemfile mvpa-css.gemspec .github .rubocop.yml CHANGELOG.md` is empty; `package.json` changes only the stylelint range.
- `lefthook.yml` refetches the shared config every 24 hours → `test/git_hooks_test.rb`; proves the key exists but not the 24-hour value (see third finding).

No existing test was weakened, skipped or deleted; the only change under `test/` is the new `git_hooks_test.rb`.

- [ ] Important: `rv run --no-install bundle outdated` exits 1 again. It lists rubocop-eirvandelden `1e2e033` → `5f82215` (pushed 2026-10-14). The compare between the two revisions changes only that repository's own `Gemfile.lock` (Dependabot bumps of rubocop-minitest and rubocop-rails), so the shipped config does not change. The intent puts this revision out of scope, on the premise "it is already at its GitHub HEAD", which no longer holds. Etienne decides: bump the revision, or record that the out-of-scope line wins — `Gemfile.lock:3` →
- [ ] Important: The plan's Proof "a fresh `yarn install --ignore-scripts` produces an identical `yarn.lock`" fails again. A fresh install resolves baseline-browser-mapping 2.11.28 → 2.11.29 (2026-10-15), electron-to-chromium 1.5.453 → 1.5.458 (2026-10-16) and node-releases 2.0.58 → 2.0.59 (2026-10-15). All three are data packages that release almost daily, so this Proof goes stale within days of any refresh. `yarn outdated` stays green — `yarn.lock:173` →
- [ ] Important: `test/git_hooks_test.rb` asserts only that `refetch_frequency` is present. It does not prove the criterion "refetch every 24 hours". In a scratch copy, `refetch_frequency: never`, which turns fetching off, passes the test. So does `remotes: []`, with 0 assertions. The test name `test_every_shared_hook_config_is_refetched` claims more than it checks. Assert the value, and that at least one remote exists — `test/git_hooks_test.rb:8` →
