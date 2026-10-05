# Intent: Remove the cspell spell checker

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

cspell stops lint runs and commits on correctly spelled technical words and has found no real typo.

## Proposed outcome

Lint and CI no longer run a spell check.

## Affected users and systems

Contributors running lint locally, the CI workflow, and the lint tooling dependencies.

## Constraints

The devDependency removal and the CI edit are approved by Etienne.

## Open questions

None.
