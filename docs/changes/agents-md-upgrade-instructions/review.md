# Review: agents-md-upgrade-instructions

## Round 1 — 2026-10-12T15:00Z — 557795a

Checks: `bundle exec rake test` (94 runs, 0 failures), `bundle exec rubocop` (no offenses), `yamllint --strict .` (clean). The diff only adds a test file, so no existing test is weakened, skipped or deleted.

Compliance:

- An agent that renames a button class adds a `### Upgrading` subsection → `test/agents_md_test.rb` `test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act`, `test_changelog_rule_shows_an_example_upgrading_subsection` (text proof of the rule; behaviour is checked by review of the next applicable entry, as `plan.md` states)
- An agent that fixes a colour adds no `### Upgrading` subsection → `test/agents_md_test.rb` `test_changelog_rule_excludes_entries_without_app_changes` (partial, see the Nit below)
- A reader of `AGENTS.md` finds the rule and an example → `test/agents_md_test.rb` `test_changelog_rule_names_what_requires_apps_to_act`, `test_changelog_rule_shows_an_example_upgrading_subsection`
- Every test named in `plan.md` `## Proof` exists with the planned name.

Findings:

- [x] Nit: `test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act` only checks that the section contains `### Upgrading` anywhere. The fenced example alone satisfies it, so the test stays green if the rule bullet itself is deleted. It does not prove that the rule "asks for" the subsection. — `test/agents_md_test.rb:6` → fixed (Close review round 1 findings for agents-md-upgrade-instructions)
- [x] Nit: `test_changelog_rule_excludes_entries_without_app_changes` matches any line with "no " before `### Upgrading`. It does not check the colour-fix example that acceptance criterion 2 names, so the exclusion could lose its example and stay green. — `test/agents_md_test.rb:16` → fixed (Close review round 1 findings for agents-md-upgrade-instructions)
- [x] Nit: `test_changelog_rule_names_what_requires_apps_to_act` matches each trigger word as a bare substring of the whole section, example included. `code` also matches words such as "encode" or a future example line, so the test can pass while the trigger list drops a word. — `test/agents_md_test.rb:10` → fixed (Close review round 1 findings for agents-md-upgrade-instructions)
- [x] Nit: `changelog_section` ends the section at the next `## ` heading that is not dated. `plan.md` says it ends at the next `## ` heading outside a fence. The two agree today, but an undated heading in the example (for example `## Unreleased`) cuts the section inside the fence, and the example test then fails with "no fenced Markdown example" instead of a clear cause. — `test/agents_md_test.rb:32` → fixed (Close review round 1 findings for agents-md-upgrade-instructions)
- [x] Nit: The rule does not say what to do when a dated entry already exists for the day and already ends in `### Upgrading`. Entries such as 2026-09-04 hold several changes. "Put `### Upgrading` last" can lead an agent to add a second `### Upgrading` heading, or to add a change subsection after it. One sentence such as "Append steps to the existing `### Upgrading` subsection" closes the gap. — `AGENTS.md:24` → fixed (Close review round 1 findings for agents-md-upgrade-instructions)
- [x] Nit: "when no app action is needed" is passive voice, against the STE style the plan names. An active form such as "when an app needs to do nothing" reads the same way. — `AGENTS.md:23` → fixed (Close review round 1 findings for agents-md-upgrade-instructions)

## Round 2 — 2026-10-12T15:01:16Z — 557795a (codex)

No findings. `codex review --base origin/main`: the changelog guidance matches the intent, and the focused tests pass.
