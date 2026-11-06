# Delivery account: dark-surfaces-darker-than-canvas

## Behaviour delivered

- In every dark rendering of mvpa.css (the system-dark default, `solunized-dark`, `solunized-black`), a surface is darker than the canvas behind it, as in Herdr and Nova. The dark scale mapping now equals the light mapping, value for value.
- Dark themes read links through a new `--color-link` token (`--color-br-blue`, 4.495:1 on the solunized-dark canvas) and visited links through `--color-link-visited` (`--color-br-violet`, 4.94:1). The system-dark `:root` declares those two palette values once; a test pins them equal to the solunized-dark values.
- The current-page sidebar link text uses `var(--color-bg-lightest)`, so it reads on the blue fill in the dark themes (4.69:1). Light and e-ink output changes with it.
- Known cost, accepted in the intent: muted text on the solunized-dark canvas drops from 4.04:1 to 3.25:1. A period navigation inside an article and a mobile tab item read lighter than their surface. The selected segment of a segmented control reads darker than its track.
- Sticker-app needs no code change. It gets the layering when it bumps its pinned mvpa.css `ref:`.

## Evidence

- Browser check of `demo.html` and a minimal inset page in headless Chrome, recorded in `evidence.md`: `solunized-dark` and `solunized-black` show surfaces darker than the page; light looks as on `main`; the three inset cases look as described above.
- Not seen: system dark with no `data-theme`, and a visited link. Headless Chrome could not show either. The unit tests cover both from the CSS.

## Check results

- Tests: 304 runs, 2993 assertions, 0 failures, run per file with `ruby -Itest` because `bundle exec` cannot resolve main's lockfile locally.
- Rubocop: no offenses (run with the earlier lockfile, then restored). Stylelint, browserslist check and yamllint: clean.
- Brakeman and Bundler Audit: this repository is a CSS gem with no Rails app. The change adds no dependency.
- `Gemfile.lock` is unchanged from `main`; an earlier commit's drift was reverted.

## Review outcome

- Round 1 (Claude reviewer): two Important and two Nit findings, all fixed. The Important ones were a false CHANGELOG claim about the selected segment and a missing browser-check record.
- Round 2 (Claude reviewer): no findings. No Codex round, as the intent records `Codex review: no`.
- Plan critiques: four rounds, the last by an Opus agent, every finding closed.
- Note for the PR: the `no-hardwrap` commit hook joined six hard-wrapped README paragraphs, which shows as unrelated whitespace hunks.
