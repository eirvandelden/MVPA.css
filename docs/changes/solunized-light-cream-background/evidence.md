# Evidence: Solunized light cream background

Visual check, 2026-10-26, in headless Chrome at 1200x800, with `demo.html` served from this worktree. The demo restores its theme from `localStorage`, so each run used a scratch copy of `demo.html` with `data-theme` fixed and the same stylesheet links.

- `data-theme="solunized-light"`: the page is a yellowish cream (`#eee8d5`), the sidebar and cards are a lighter cream (`#fdf6e3`).
- No `data-theme`, `data-color-scheme="light"`: the same cream page and lighter cream cards as `solunized-light`.
- `data-theme="solunized-white"`: a cool bluish-white page with white cards, clearly different from `solunized-light`.

Checks: `bundle exec rake test` 202 runs, 0 failures. `bundle exec rubocop`, `npm run lint:css`, `npm run lint:browsers`, `yamllint --strict .` and `gem build` pass.
