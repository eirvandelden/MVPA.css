# Intent: Adopt semantic versioning with release on merge

Author: Etienne van Delden. Status: draft. Type: feature.

## Problem

Apps pin mvpa.css to a git SHA. A SHA does not say whether an upgrade is a breaking change, so an app owner cannot tell a safe bump from one that needs markup changes.
Nothing tells an agent to record or flag a breaking change, and nothing in CI notices when one slips through.
Several branches are open at once and merge in any order, so a version number chosen inside a branch can collide or be wrong.

## Proposed outcome

Every release has a semver version: major for a breaking change, minor for an opt-in feature, patch for a fix and for anything else that merges.
The version is assigned when a change merges to `main`, from the changes that merged, never inside a branch.
Agents have written rules on when a change is breaking and what to record. CI fails a pull request that removes public surface without recording a breaking change.
The history gets versions once, retroactively, so apps can pin any past state.

## Affected users and systems

- Apps that pin mvpa.css by `ref:` SHA, and their agents.
- Agents and people who write changes in this repository.
- `lib/mvpa/css/version.rb`, `mvpa-css.gemspec`, `CHANGELOG.md`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `.github/workflows/`, `test/`.
- Git tags and GitHub releases.
- The sibling repository appkit, which makes the same change and should share the design.

## Constraints

- Bump rule: major when apps must change markup, classes, configuration or code (the fragment then has Upgrading steps); minor for an opt-in feature; patch for a fix and for anything else. A fragment states its level in an explicit `level` field.
- A merge to `main` always releases at least a patch, including a docs, test or CI-only merge with no fragment. This differs from appkit, which has a `none` level and releases nothing for it.
- Branches merge in any order, so no branch holds a version number.
- `main` has no branch protection, and only merge commits are allowed, so a release job may push to `main`.
- Editing `.github/workflows/` needs Etienne's approval (playbook rule 13). The intent's acceptance counts as that approval for the release workflow and the CI check only.
- Apps already pinned to a SHA keep working: SHAs stay valid.
- Share one design with appkit: same fragment format, same level names, same workflow shape. Each repository keeps its own copy of the script and of the CI check, because public surface differs. No shared gem or action (playbook rule 11).

## In scope

- Retroactive versions for every dated changelog entry, starting at 0.1.0 for the first entry with each breaking entry raising the major, and git tags on the matching commits, after Etienne approves an entry-to-commit-to-version table.
- One fragment file per pull request, default `changelog.d/<branch-slug>.md` with front matter `level: major|minor|patch` (appkit may adjust the path or name; the two repositories keep the same), with an explicit level, the Added/Changed/Fixed text and optional Upgrading steps. A pull request never edits a shared changelog section.
- A workflow on push to `main`, one run at a time (concurrency group): it reads all fragments, takes the highest level, stamps the version in `version.rb` and a `## X.Y.Z — YYYY-MM-DD` heading in `CHANGELOG.md`, deletes the fragments, commits, tags `vX.Y.Z` and creates the GitHub release. With no fragment it releases a patch.
- A CI check that fails a pull request whose diff removes or renames public surface while its fragment level is below major. Public surface is: `--token` names in the variables partial, stylesheet and JS files, class selectors, `data-` attribute selectors, importmap pins and files in `app/javascript`. Element-structure contracts such as `nav.rail` have no automatic check; `AGENTS.md` says that changing one needs `level: major`.
- Agent rules in `AGENTS.md` and `CLAUDE.md` on versioning and breaking changes; README and CHANGELOG header changes from "git SHAs" to semver pins.
- `version.rb` stops reading the git SHA.

## Out of scope

- Publishing to rubygems.org.
- Changing the CSS itself.
- Updating consuming apps' pins; the rollout of the new version to apps is separate.
- Rewriting or deleting the four existing SHA-named tags and releases.

## Acceptance criteria

- Two branches that each add a change and merge in either order produce two releases with correct, distinct versions.
- A merged fragment with `level: major` and Upgrading steps raises the major version and resets minor and patch to zero.
- A merged fragment with `level: minor` raises the minor version and resets patch to zero.
- A merged fragment with `level: patch`, or a merge with no fragment, raises the patch version.
- Two fragments in one run, minor and major, release one major version.
- A pull request that removes a public CSS custom property with `level: minor` fails CI; the same pull request with `level: major` passes.
- `Mvpa::Css::VERSION` returns the released version, not a SHA, and `gem build` produces `mvpa-css-X.Y.Z.gem`.
- The changelog shows a version for each of the 15 dated entries, with each Upgrading entry as a major, after Etienne approves the table.
- An app can pin `tag: "vX.Y.Z"` for any entry, and the README says how.
- `AGENTS.md` tells an agent when a change is breaking, where its entry goes and that it never writes a version number.

## Flagged concerns

None.

## Decisions

- One intent covers adopting semver, release automation and breaking-change detection — Etienne chose to keep them together.
- Major when apps must act, minor for an opt-in feature, patch otherwise — reuses the convention in the changelog rules.
- Version every changelog entry retroactively — apps can pin any past state.
- A PR declares its bump in an explicit `level` field in its fragment, not a label or a version number — merge order must not matter, and CI can cross-check the level against the diff.
- Every merge to `main` releases a patch at least — Etienne's choice, no reason given.
- CI fails on removed public surface under a level below major — a test beats memory.
- Fragment files, one per PR, as appkit designs them — Etienne wants the two repositories aligned.
- Share one design with appkit, copy the script per repo — avoids a new shared dependency.
- Public surface for CI is custom properties, files, class and data selectors, importmap pins and controllers; markup contracts stay a manual agent rule — Etienne selected all four.
- Changelog headings read `## X.Y.Z — YYYY-MM-DD` — keeps the date entries use today.
- Start retroactive numbering at 0.1.0 like appkit — Etienne chose it to match appkit.

## Open questions

None.
