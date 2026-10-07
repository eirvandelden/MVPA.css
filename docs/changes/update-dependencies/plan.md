# Plan: Update all dependencies to their latest stable versions

From `intent.md` (2026-10-06). Status: accepted.

## Context

The development and CI toolchain runs on dependency versions behind the latest stable releases. Dependabot bumps direct dependencies only, after a 7-day cooldown. It never bumps transitive gems, transitive npm packages or the Ruby patch version. This change moves every gem, every npm package and the Ruby version to the latest stable release on the day of implementation. Tests, linters and the gem build stay green. Gem consumers see no change: the gemspec does not change, and the lockfiles do not ship with the gem.

State on 2026-10-06, measured in the worktree with `bundle outdated` and `yarn outdated`:

| Package | Locked | Latest | Kind |
|---|---|---|---|
| actionpack, actionview, activesupport, railties | 8.1.3.1 | 8.1.4 | Rails (railties is the runtime dependency; the rest are transitive) |
| parallel | 1.28.0 | 2.3.0 | transitive (rubocop), major |
| rubocop-minitest | 0.40.0 | 0.41.0 | transitive (rubocop-eirvandelden) |
| rubocop-rails | 2.37.0 | 2.38.0 | transitive (rubocop-eirvandelden) |
| rubocop-yard | 1.2.0 | 1.3.0 | transitive (rubocop-eirvandelden) |
| io-console | 0.9.2 | 0.9.4 | transitive |
| rbs | 4.1.3 | 4.2.0 | transitive |
| rdoc | 8.0.0 | 8.1.0 | transitive |
| regexp_parser | 2.12.0 | 2.13.1 | transitive |
| unicode-display_width | 3.2.0 | 3.3.0 | transitive |
| unicode-emoji | 4.2.0 | 4.3.0 | transitive |
| stylelint (npm) | 17.14.1 (range `^17.14.1`) | 17.16.0 | direct devDependency |
| Ruby (`.ruby-version`) | 4.0.6 | 4.0.7 | toolchain |
| Bundler (`BUNDLED WITH`) | 4.0.17 | 4.0.22 | toolchain |

`yarn outdated` reports only direct packages. The transitive npm packages need their own check (see Order of work, step 9).

## Design decisions

- **Name every gem in `bundle update`.** Playbook rule 11 and the `dependencies` skill forbid `bundle update` for all gems. The implementer runs `bundle update <gem> <gem> ...` with the exact names that `bundle outdated` lists on the day. This also keeps the rubocop-eirvandelden git revision as it is (out of scope).
- **One logical change per commit.** Commits, in order: Ruby; Bundler; Rails; parallel (the only major); RuboCop plugins; other transitive gems; stylelint; transitive npm packages. Lint fixes that a bump surfaces go in their own commit directly after that bump, as in the earlier commit `a690bff style: apply the rules now that they run here`.
- **`BUNDLED WITH` moves to 4.0.22, the latest Bundler.** Etienne decided this on 2026-10-06 during planning. It overrides the intent's "no system tooling is installed" constraint for this one tool only. Installing Bundler 4.0.22 for Ruby 4.0.7 is explicitly approved. The yarn binary, Node and every other tool stay as they are. `bundle outdated` does not list Bundler, so step 3 checks it separately.
- **Run every Ruby command through `rv run --no-install`.** The agent shell inherits a `PATH` and `GEM_HOME` that point at Ruby 4.0.6. `rv run --no-install <command>` reads `.ruby-version`, so after step 2 it runs Ruby 4.0.7. `--no-install` makes rv fail rather than install a Ruby. Verified: `rv run --no-install --ruby 4.0.7 ruby -v` prints `ruby 4.0.7`.
- **No new Minitest tests.** The acceptance criteria are command checks against the package registries. A Minitest test that calls `bundle outdated` or `yarn outdated` needs the network and turns red on every upstream release. A test that pins exact versions duplicates the lockfiles and churns on every bump. The existing suite plus the command checks in `## Proof` are the proof. This conflicts on the surface with playbook rule 3 ("never generate code without a corresponding test"). No code is generated here: only lockfiles, one version range and one version file change. Any code change that a lint fix needs is covered by the existing suite and the linters.
- **No CHANGELOG entry.** The CHANGELOG tracks changes that gem consumers see. Earlier dependency bumps (`916c8d3`, `28f2ce6`) did not touch it.
- **The `mvpa-css` version-string churn stays where Bundler writes it.** `lib/mvpa/css/version.rb` builds the version from the current git SHA, so every `bundle` command rewrites `mvpa-css (0.1.0.pre.git.<sha>)` in `Gemfile.lock`. The intent accepts this churn inside a gem-update commit. In the Ruby-only commit (step 2), revert `Gemfile.lock` so that commit holds `.ruby-version` alone.

## Integration points

- CI (`.github/workflows/ci.yml`): the `test` and `gem` jobs use `spinel-coop/setup-rv@main` with `ruby-version: current`, which reads `.ruby-version`. The `stylesheets` job runs `yarn install --frozen-lockfile`, so `yarn.lock` must match `package.json` exactly. The workflow file does not change.
- `test/continuous_integration_test.rb` `test_the_project_pins_the_ruby_it_runs_on` asserts that `.ruby-version` holds a full `x.y.z` version. `4.0.7` satisfies it.
- `.rubocop.yml` inherits `rubocop-eirvandelden: config/default.yml`. New cops from rubocop-minitest 0.41.0, rubocop-rails 2.38.0 or rubocop-yard 1.3.0 can report new offenses in `test/` or `lib/`.
- `stylelint.config.mjs` ignores `app/assets/stylesheets/mvpa/mvpa.css`. A stylelint fix in a partial must also go into `mvpa.css` by hand, or `test/mvpa_manifest_sync_test.rb` fails.
- No test loads Rails. `lib/mvpa-css.rb` requires the engine only `if defined?(Rails)`. The Rails bump gets a one-off smoke check instead (step 4).

## Files that change

- `.ruby-version` — `4.0.6` → `4.0.7`.
- `Gemfile.lock` — every gem that `bundle outdated` lists moves to its latest version, with new `CHECKSUMS` lines. `BUNDLED WITH` moves from `4.0.17` to `4.0.22`. The `mvpa-css` SHA line changes as a side effect. The `GIT` revision of rubocop-eirvandelden stays `1e2e033`.
- `package.json` — `"stylelint": "^17.14.1"` → `"stylelint": "^17.16.0"`. No other line changes.
- `yarn.lock` — stylelint resolves to 17.16.0, and every transitive entry resolves to the newest version its range allows.
- Only if a bump surfaces offenses or deprecation warnings: the offending files under `test/`, `lib/`, `Rakefile`, or `app/assets/stylesheets/` (partial plus `mvpa.css`), or `stylelint.config.mjs`.

Unchanged, and checked at the end: `Gemfile`, `mvpa-css.gemspec`, `.github/`, `.rubocop.yml`, `CHANGELOG.md`.

## Order of work

1. **Red: record the acceptance checks failing.** Run `rv run --no-install bundle outdated` and `yarn outdated`. Both exit 1. Compare the lists with the table in Context. A package that has a newer release since 2026-10-06 is in scope too. A new major other than parallel is not: stop and ask Etienne. Run `rv run --no-install ruby -v`; it prints 4.0.6.
2. **Ruby.** Set `.ruby-version` to `4.0.7`. Run `rv run --no-install ruby -v`; it prints 4.0.7. Run `rv run --no-install bundle install`, then `rv run --no-install bundle exec rake test`; it passes. Run `git checkout -- Gemfile.lock` to drop the SHA churn. Commit `.ruby-version` alone: `chore: bump Ruby to 4.0.7`.
3. **Bundler 4.0.17 → 4.0.22.** Install it for Ruby 4.0.7 (approved by Etienne): `rv run --no-install gem install bundler -v 4.0.22`. Then `rv run --no-install bundle update --bundler=4.0.22`. Check that `Gemfile.lock` ends with `BUNDLED WITH` `4.0.22`, that no gem version changed, and that `rv run --no-install bundle exec ruby -e 'puts Bundler::VERSION'` prints `4.0.22`. Run the suite. Commit: `chore(deps): bump Bundler to 4.0.22`. Never install any other tool. If the latest Bundler on the day is newer than 4.0.22, stop and ask Etienne.
4. **Rails.** `rv run --no-install bundle update actionpack actionview activesupport railties`. Check that `Gemfile.lock` shows 8.1.4 for all four. Smoke-check the engine: `rv run --no-install bundle exec ruby -Ilib -e 'require "rails"; require "mvpa-css"; puts Mvpa::Css::Engine.superclass'` prints `Rails::Engine`. Run the suite. Commit: `chore(deps): bump Rails to 8.1.4`.
5. **parallel 1.28.0 → 2.3.0.** `rv run --no-install bundle update parallel`. parallel 2.0 requires Ruby >= 3.3 and adds Ractor support; 2.2.0 changes `filter_map` and worker validation. RuboCop is its only user here, so exercise it: `rv run --no-install bundle exec rubocop --parallel --cache false`. It passes. Commit: `chore(deps): bump parallel to 2.3.0`.
6. **RuboCop plugins.** `rv run --no-install bundle update rubocop-minitest rubocop-rails rubocop-yard`. Run `rv run --no-install bundle exec rubocop`. Commit the lockfile: `chore(deps): bump rubocop-minitest, rubocop-rails and rubocop-yard`. If RuboCop reports offenses, fix them in the code in a separate commit directly after (`style: fix offenses from <plugin> <version>`). Never add disable comments, and never change `.rubocop.yml` to silence a cop. If a fix is not obvious, stop and ask Etienne.
7. **Other transitive gems.** `rv run --no-install bundle update io-console rbs rdoc regexp_parser unicode-display_width unicode-emoji`, plus any other gem that `bundle outdated` still lists. Re-run `rv run --no-install bundle outdated` until it reports `Bundle up to date!` and exits 0. If a gem does not move, run `rv run --no-install bundle update <gem> --verbose` to find the constraint that holds it, and report it rather than forcing it. Run the suite and RuboCop. Commit: `chore(deps): bump transitive gems`.
8. **stylelint.** `yarn upgrade stylelint@^17.16.0`. Check that `package.json` now reads `"stylelint": "^17.16.0"` and that `yarn.lock` resolves `stylelint@^17.16.0` to `17.16.0`. Run `yarn lint:css` and `yarn lint:browsers`; both pass with no deprecation warnings. Commit `package.json` and `yarn.lock`: `chore(deps-dev): bump stylelint to 17.16.0`. Fix lint findings or deprecation warnings in a separate commit directly after, and mirror every partial change in `mvpa.css`.
9. **Transitive npm packages.** `yarn upgrade` with no arguments. It recreates `yarn.lock` from the `package.json` ranges. Confirm that `package.json` did not change. Prove the result is the newest set: copy `package.json` into a scratch directory, run `yarn install --ignore-scripts` there, and diff the generated `yarn.lock` against the repository one. They are identical. Run `yarn lint:css`, `yarn lint:browsers` and `yarn install --frozen-lockfile`. If `yarn.lock` changed, commit it: `chore(deps-dev): refresh transitive npm packages`.
10. **Full verification.** Run every command in `## Proof` on the final branch, on Ruby 4.0.7. Delete the `.gem` file that `gem build` writes; never commit it.
11. **Self-review.** Re-read `git diff main...HEAD`. Every hunk belongs to this task. `git diff main...HEAD -- Gemfile mvpa-css.gemspec .github .rubocop.yml CHANGELOG.md` is empty. `git diff main...HEAD -- package.json` shows only the stylelint range line.

## Risks

- **Environment side effect from planning.** While planning, a `bundle exec` under Ruby 4.0.7 auto-installed Bundler 4.0.17 and the locked gems into Ruby 4.0.7's gem home. That run also rewrote the `mvpa-css` SHA line in `Gemfile.lock`; the planner reverted it. Step 2's `bundle install` is therefore mostly a no-op.
- **Mixed gem paths print warnings.** Under `rv run --ruby 4.0.7`, rdoc printed `already initialized constant` warnings, because the inherited `GEM_PATH` still includes the Ruby 4.0.6 gem home with rdoc 7.2.0. These warnings come from the shell environment, not from the update. Do not "fix" them in the repository. If they hide real output, start a fresh shell in the worktree.
- **parallel 2.x is the only major.** Its 2.0 release requires Ruby >= 3.3. The gemspec allows Ruby >= 3.2, but parallel is a development dependency through RuboCop and does not reach gem consumers. A contributor on Ruby 3.2 could no longer `bundle install`; `.ruby-version` pins 4.0.7, so no supported setup is affected.
- **Packages younger than the 7-day cooldown.** parallel 2.3.0, rubocop-minitest 0.41.0 and stylelint 17.16.0 are under 7 days old. The intent chose latest over the cooldown. All three are lint-only.
- **New cops or stylelint rules can widen the diff.** Fixes stay in separate commits, as step 6 and step 8 say. A fix that changes CSS output is a visible change for gem consumers: stop and ask Etienne before making one.
- **The Rails bump has no durable test.** No test loads the engine. The smoke check in step 4 is the evidence.
- **Rejected:** a `RUBY_VERSION == .ruby-version` test. It would make "the suite passes on 4.0.7" self-checking in CI. It also adds a new behaviour outside the intent and fails for anyone who runs the suite on another patch release.
- **Rejected:** a single `bundle update` with no gem names. Playbook rule 11 forbids it without explicit instruction, and it would also touch the rubocop-eirvandelden git source.

## Out of scope

- The gemspec's runtime constraint on railties.
- GitHub Actions versions.
- The rubocop-eirvandelden git revision.
- The yarn binary, Node and every other system tool. Bundler is the one exception (see Design decisions).
- The Dependabot configuration.
- Adding or removing any dependency.

## Proof

- `bundle outdated` lists no gem that is behind its latest stable release → command `rv run --no-install bundle outdated` prints `Bundle up to date!` and exits 0.
- `yarn outdated` lists no package that is behind its latest release → command `yarn outdated` prints no package table and exits 0.
- Transitive npm packages are at the newest version their range allows → command: a fresh `yarn install --ignore-scripts` of `package.json` in a scratch directory produces a `yarn.lock` identical to the repository one.
- `package.json` asks for stylelint `^17.16.0`, and `yarn.lock` resolves it to 17.16.0 → command `grep '"stylelint"' package.json` and `grep -A1 '^stylelint@' yarn.lock`.
- `.ruby-version` reads 4.0.7, and the test suite passes on Ruby 4.0.7 → `test/continuous_integration_test.rb` `test_the_project_pins_the_ruby_it_runs_on`, plus command `rv run --no-install ruby -v` (prints 4.0.7) followed by `rv run --no-install bundle exec rake test`.
- Bundler is at its latest release (Etienne's decision during planning, not an intent criterion) → command `tail -2 Gemfile.lock` shows `BUNDLED WITH` `4.0.22`, and `rv run --no-install bundle exec ruby -e 'puts Bundler::VERSION'` prints `4.0.22`.
- `bundle exec rake test` passes → command `rv run --no-install bundle exec rake test` (all 18 files under `test/`).
- `bundle exec rubocop`, `yarn lint:css`, `yarn lint:browsers` and `yamllint --strict .` all pass → those four commands, the first one through `rv run --no-install`.
- `gem build mvpa-css.gemspec` succeeds → command `rv run --no-install gem build mvpa-css.gemspec`.
- The Gemfile, the gemspec and `package.json` name the same direct dependencies as before → command `git diff main...HEAD -- Gemfile mvpa-css.gemspec` is empty, and `git diff main...HEAD -- package.json` shows only the stylelint range.

Per changed file, the unit tests expected: none. `.ruby-version`, `Gemfile.lock`, `package.json` and `yarn.lock` hold no behaviour of their own. The existing suite covers them indirectly (see Design decisions). A file changed by a lint fix keeps the tests it already has, and they stay green.

Test setup: none. No fixtures and no faked boundaries. The command checks need network access to gem.coop, the GitHub git source and the npm registry.

---
Domain skills applied: dependencies.
