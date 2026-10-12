# Intent: changelog entries tell other apps how to upgrade

Author: Etienne van Delden de la Haije. Status: accepted (2026-10-12). Type: chore. Delivery: autonomous.

## Problem

Several of Etienne's apps use mvpa.css, pinned to a git SHA. When mvpa.css changes how an app must write its markup or which classes it uses, the changelog says what changed, but not what an app must do to follow. Upgrading the other apps then means reverse-engineering each change. Nothing tells an agent working in mvpa.css to write those steps down.

## Proposed outcome

`AGENTS.md` tells every agent that a change which requires apps to act adds an "Upgrading" subsection to its dated `CHANGELOG.md` entry. That subsection lists the steps an app takes, written so that Etienne or an agent in another app can follow them without reading the diff.

## Affected users and systems

- Agents and Etienne working in mvpa.css (`AGENTS.md`, and `CLAUDE.md`, which links to it).
- Apps that use mvpa.css, such as journal_administration, when they upgrade.

## Constraints

- The changelog keeps its current format: dated `##` entries with `### Added`, `### Fixed` and similar subsections.
- No permissions are needed under playbook rules 8, 9, 11, 12 or 13.

## In scope

- A rule in `AGENTS.md`: an entry that requires apps to change markup, classes, configuration or code gets a `### Upgrading` subsection with concrete steps. Other entries do not.
- A short example of such a subsection in that rule.

## Out of scope

- Rewriting older changelog entries.
- Any CSS change. The button hierarchy and action row follow in their own change.
- appkit, which gets its own change.

## Acceptance criteria

- An agent that renames a button class in mvpa.css adds a `### Upgrading` subsection to the changelog entry, telling apps which class to replace with which.
- An agent that fixes a colour without any markup change adds no `### Upgrading` subsection.
- A reader of `AGENTS.md` finds the rule and an example of the subsection.

## Open questions

None.
