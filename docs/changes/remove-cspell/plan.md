# Plan: Remove the cspell spell checker

Status: accepted.

## Files that change

`yarn remove cspell` (updates package.json and yarn.lock); delete the `lint:spelling` script from package.json; delete `.cspell.json`; delete the spelling step from `.github/workflows/ci.yml`; in `AGENTS.md` line 15 remove the `yarn lint:spelling` (cspell) item from the lint list and keep the rest of the sentence grammatical.

## Proof

- `git grep -n -i -E '(^|[^a-z])cspell' -- ':!docs/changes'` prints nothing (yarn.lock included).
- `yarn lint:css`, `bundle exec rubocop`, `yarn lint:browsers` and `yamllint --strict .` stay as green as on main.
