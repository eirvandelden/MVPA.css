# Intent: Update all dependencies to their latest stable versions

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

The development and CI toolchain runs on dependency versions that are older than the latest stable releases. Dependabot bumps direct dependencies weekly, after a 7-day cooldown. It does not bump transitive gems or npm packages, and it does not bump the Ruby patch version. On 2026-10-06, Rails 8.1.3.1 is behind 8.1.4, several RuboCop plugins and transitive gems are behind, stylelint is behind 17.16.0, and the project pins Ruby 4.0.6 while 4.0.7 is available.

## Proposed outcome

Every gem, npm package and the Ruby version are at their latest stable release on the day of implementation. Tests, linters and the gem build stay green.

## Affected users and systems

- The maintainer's local development environment (Ruby, Bundler, yarn).
- CI (`.github/workflows/ci.yml`), which installs from the lockfiles and reads the Ruby version from the repository.
- Gem consumers are not affected: the gemspec constraint (`railties >= 6.0`) does not change, and the lockfiles do not ship with the gem.

## Constraints

- No dependency is added or removed (playbook rule 11).
- No major version is skipped. parallel 1.28 → 2.3 is a single major step.
- No system tooling is installed or switched. Ruby 4.0.7 is already installed through rv. yarn stays at its current version.
- Gem sources stay as they are: gem.coop, and rubocop-eirvandelden from GitHub.
- Version constraints follow the `dependencies` skill: no new pins and no new upper bounds.

## In scope

- All direct and transitive gems in `Gemfile.lock` move to their latest stable versions, including the parallel 1.x → 2.x major.
- `.ruby-version` moves from 4.0.6 to 4.0.7.
- The `package.json` ranges for direct npm devDependencies move up to the latest versions (stylelint `^17.16.0`).
- Every transitive npm package in `yarn.lock` moves to the newest version its range allows.
- New lint offenses or deprecation warnings that the updates surface get fixed.

## Out of scope

- The gemspec's runtime constraint on railties.
- GitHub Actions versions. actions/checkout v7.0.1 and actions/setup-node v7 are already the latest.
- The rubocop-eirvandelden git revision. It is already at its GitHub HEAD.
- The yarn binary itself, and any other system tool.
- The Dependabot configuration.
- The `mvpa-css` version-string churn in `Gemfile.lock` (the git SHA in `0.1.0.pre.git.<sha>`), apart from what the update itself rewrites.

## Acceptance criteria

- `bundle outdated` lists no gem that is behind its latest stable release.
- `yarn outdated` lists no package that is behind its latest release.
- `package.json` asks for stylelint `^17.16.0`, and `yarn.lock` resolves it to 17.16.0.
- `.ruby-version` reads 4.0.7, and the test suite passes on Ruby 4.0.7.
- `bundle exec rake test` passes.
- `bundle exec rubocop`, `yarn lint:css`, `yarn lint:browsers` and `yamllint --strict .` all pass.
- `gem build mvpa-css.gemspec` succeeds.
- The Gemfile, the gemspec and `package.json` name the same direct dependencies as before the change.

## Flagged concerns

- "Latest stable" conflicts with the 7-day Dependabot cooldown. parallel 2.3.0 (2026-10-03), rubocop-minitest 0.41.0 (2026-10-02) and stylelint 17.16.0 (2026-10-01) are less than 7 days old. Chosen side: latest wins. All three are lint-only tools, so the exposure stays in dev and CI and does not reach gem consumers.

## Open questions

None.
