# Spec: Remove the cspell spell checker

Status: accepted.

## Requirements

The repo has no cspell dependency, script, config, CI step or doc mention; nothing else changes.

## Acceptance criteria

- `git grep -n -i -E '(^|[^a-z])cspell' -- ':!docs/changes'` prints nothing (yarn.lock included).
- `yarn lint:css`, `bundle exec rubocop`, `yarn lint:browsers` and `yamllint --strict .` stay as green as on main.
