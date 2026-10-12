# Plan: changelog entries tell other apps how to upgrade

From `intent.md` (2026-10-12). Status: accepted.

## Context

mvpa.css is a classless CSS gem that other apps pin to a git SHA. `CHANGELOG.md` has dated `## YYYY-MM-DD` entries with `### Added`, `### Changed` and `### Fixed` subsections. It says what changed, not what an app must do to follow. `AGENTS.md` (which `CLAUDE.md` symlinks to) has the sections `What this is`, `Domain`, `Commands` and `Gotchas`, and says nothing about the changelog.

## Design decisions

- Add a new `## Changelog` section to `AGENTS.md`, between `## Commands` and `## Gotchas`. A rule about how to write entries is not a gotcha and not a command, so it gets its own section. `CLAUDE.md` is a symlink to `AGENTS.md` and needs no edit.
- The rule names the trigger the intent names: an entry that requires apps to change markup, classes, configuration or code gets a `### Upgrading` subsection. It states the opposite case in the same section: an entry with no app-side action (for example, a colour fix) gets no `### Upgrading` subsection.
- `### Upgrading` is the last subsection of its dated entry, after whichever change subsections that entry has. The rule says so in those words, so no agent adds an empty `### Changed` or `### Fixed` heading to reach it. Its steps are a numbered list, each step one concrete action an app takes, written so a reader in another app can follow it without the mvpa.css diff.
- Bumping the pinned `ref:` is not an Upgrading step. Every upgrade needs it, so listing it would make the subsection appear on every entry and break the "other entries do not" rule.
- The example is a fenced Markdown block showing one full dated entry with a class rename. It uses placeholder class names, `.button-old` and `.button-new`, so nobody mistakes it for a real rename. The next change (button hierarchy) may rename real button classes; a realistic-looking fake name could be confused with it.
- Prose follows playbook rule 26 (one line per paragraph or list item) and STE style, even though older `CHANGELOG.md` entries are hard-wrapped.
- The rule is proven by a Minitest file that reads `AGENTS.md` as text, in the same style as `test/readme_test.rb`. Acceptance criteria 1 and 2 describe how a future agent behaves. No test in this repository can prove that behaviour. The text test is regression protection: it proves the rule that drives the behaviour is present and says the right thing. The behaviour itself is checked by review of the next changelog entry that needs app-side steps (the button hierarchy change).

## Integration points

- `CLAUDE.md` is a symlink to `AGENTS.md`; Claude sessions pick the rule up through it.
- `Rakefile` runs `test/**/*_test.rb`, so a new test file joins `bundle exec rake test` and CI's `test` job with no config change.
- No CSS, gem code, `demo.html`, README or CI workflow changes.

## Files that change

- `test/agents_md_test.rb` — new. Asserts the `## Changelog` section of `AGENTS.md` holds the rule, the exclusion and the example.
- `AGENTS.md` — new `## Changelog` section with the rule and the fenced example.

## Order of work

1. Write `test/agents_md_test.rb` with `test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act`. Run `bundle exec ruby -Itest test/agents_md_test.rb`. Watch it fail because `AGENTS.md` has no `## Changelog` section.
2. Add the other three tests (below). Run the file; all four fail for the same reason.
3. Add the `## Changelog` section to `AGENTS.md`: the rule, the trigger list (markup, classes, configuration, code), the exclusion, the position and list form, and the fenced example. Run the test file until green.
4. Run `bundle exec rake test`, `bundle exec rubocop`, `yamllint --strict .`. All green.
5. Re-read the diff. Only `AGENTS.md` and `test/agents_md_test.rb` change (plus change-folder artifacts).

## Risks

- A text test can pass while the prose is unclear. Mitigation: the test checks for specific phrases (the `### Upgrading` heading, each of the four trigger words, the exclusion, the example block), and the reviewer reads the prose itself.
- A test tied to exact wording breaks on harmless rewording. Mitigation: match on the heading, the trigger words and the fenced example, not whole sentences.
- Rejected: a test that walks `CHANGELOG.md` and checks every `### Upgrading` subsection's shape. Out of scope for this intent, which adds a rule only; no current entry has the subsection, so the test would prove nothing today.
- Rejected: rewriting older changelog entries or adding a note to `CHANGELOG.md`'s header. The intent puts both out of scope.
- Rejected: putting the rule under `## Gotchas`. It is a writing rule, not a trap in the code.

## Out of scope

- Rewriting older `CHANGELOG.md` entries, or changing its format or header note.
- Any CSS change, including the button hierarchy and action row.
- appkit.

## Proof

The tests below prove that `AGENTS.md` states the rule and example. For criteria 1 and 2 that is the closest automated proof; the agent behaviour is checked by review of the next applicable changelog entry.

- An agent that renames a button class adds a `### Upgrading` subsection telling apps which class to replace with which → `test/agents_md_test.rb` `test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act` and `test_changelog_rule_shows_an_example_upgrading_subsection`
- An agent that fixes a colour without any markup change adds no `### Upgrading` subsection → `test/agents_md_test.rb` `test_changelog_rule_excludes_entries_without_app_changes`
- A reader of `AGENTS.md` finds the rule and an example of the subsection → `test/agents_md_test.rb` `test_changelog_rule_names_what_requires_apps_to_act` and `test_changelog_rule_shows_an_example_upgrading_subsection`

Per changed file, the unit tests expected, named as behaviour:
- `test/agents_md_test.rb`:
  - `test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act` — `AGENTS.md` has a `## Changelog` section that mentions `### Upgrading`.
  - `test_changelog_rule_names_what_requires_apps_to_act` — that section names markup, classes, configuration and code.
  - `test_changelog_rule_excludes_entries_without_app_changes` — that section says entries that need no app change get no `### Upgrading` subsection.
  - `test_changelog_rule_shows_an_example_upgrading_subsection` — that section holds a fenced block with a dated `## ` heading, a `### Upgrading` heading, and a numbered step that names both `button-old` and `button-new`.
- `AGENTS.md`: proven by the tests above.

Test setup: none. The test reads `AGENTS.md` with `File.read` and slices out the `## Changelog` section (from its heading to the next `## ` heading outside a fence), like `test/readme_test.rb` reads `README.md`.

---
Domain skills applied: None (documentation rule; `rails-testing` conventions for Minitest naming).

## Critique

### Round 1 (codex -p terra)

- The plan put `### Upgrading` after `### Added`, `### Changed` and `### Fixed` as if all three were mandatory, while current entries use only the subsections that apply; agents might add empty headings → fixed (the design decision now says it comes after whichever change subsections the entry has, and the rule says so in those words)
- A text test of `AGENTS.md` cannot prove that a future agent adds or omits the subsection, so the Proof overstated what the tests show → fixed (Design decisions and Proof now call the test regression protection for the rule, and name review of the next applicable changelog entry as the behaviour check)
