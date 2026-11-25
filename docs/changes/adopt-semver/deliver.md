# Delivery account: adopt-semver

## Behaviour delivered

Every merge to `main` now releases a semver version. A pull request adds one fragment, `changelog.d/<branch-slug>.md`, with a `level` of patch, minor or major and optional `overrides`. The release workflow reads every fragment from the tip of `main`, takes the highest level, stamps `version.rb` and a `## X.Y.Z - YYYY-MM-DD` heading in `CHANGELOG.md`, deletes the fragments, tests the stamped tree, pushes the release commit and the tag `vX.Y.Z` atomically, and creates the GitHub release. A merge with no fragment releases a patch. A `Surface` workflow fails a pull request that removes or renames public surface (custom properties, stylesheet and JS files, class and `data-` selectors, importmap pins) below `level: major`, unless a fragment override covers that rule. `AGENTS.md` tells agents when a change is breaking and that they never write a version number. The 15 dated changelog entries carry versions 0.1.0 to 6.0.0 from the table Etienne approved. This change's own fragment is major, so the first release is 7.0.0.

## Evidence

- Tests: 439 runs, 4253 assertions, 0 failures.
- Lint: rubocop 82 files with no offenses; stylelint and yamllint clean.
- `gem build` passes.
- First-release simulation: this branch's fragment stamped into a copy of HEAD gives 7.0.0; the full suite and `gem build` pass in that copy.
- Retroactive table: approved by Etienne on 2026-11-25.
- Brakeman and Bundler Audit do not apply: the repository has no Rails application.

## Review

- Round 1: 3 important findings and 5 nits, all fixed.
- Round 2: 1 important finding (the first release would have failed its own changelog test) and 2 nits; one fixed, the stale `Gemfile.lock` nit dismissed with a reason.
- Round 3: no findings. Codex review was off for this plan.

## Limitations

- `release.yml` and `surface.yml` have not run on GitHub; the first real release after merge is their first run, and `workflow_dispatch` is the repair path.
- A release commit does not stamp `Gemfile.lock`, so its `mvpa-css` line goes stale on `main` after each release.
- Retroactive tags `v0.1.0` to `v6.0.0` (14 tags; 0.2.1 shares a commit with 0.3.0 and gets none) are pushed only after the merge.
