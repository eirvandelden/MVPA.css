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

## Round 3 — 2026-10-12T15:02:48Z — 089aad7

Checks: `bundle exec rake test` (95 runs, 0 failures), `bundle exec ruby -Itest test/agents_md_test.rb` (5 runs, 0 failures), `bundle exec rubocop` (no offenses), `yamllint --strict .` (clean). The diff only adds a test file, so no existing test is weakened, skipped or deleted.

Round 1 fixes hold: the rule tests read the section with the fence removed, the exclusion test names the colour fix, the trigger words match as whole words on the rule line only, the section ends at a `## ` heading outside a fence, the append rule exists with its own test, and the exclusion uses active voice.

Compliance:

- An agent that renames a button class adds a `### Upgrading` subsection → `test/agents_md_test.rb` `test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act`, `test_changelog_rule_shows_an_example_upgrading_subsection` (text proof of the rule; behaviour is checked by review of the next applicable entry, as `plan.md` states)
- An agent that fixes a colour adds no `### Upgrading` subsection → `test/agents_md_test.rb` `test_changelog_rule_excludes_entries_without_app_changes`
- A reader of `AGENTS.md` finds the rule and an example → `test/agents_md_test.rb` `test_changelog_rule_names_what_requires_apps_to_act`, `test_changelog_rule_shows_an_example_upgrading_subsection`
- Every test named in `plan.md` `## Proof` exists with the planned name. One extra test, `test_changelog_rule_appends_to_an_existing_upgrading_subsection`, covers the round 1 append rule.

Findings:

- [ ] Nit: Three tests now match whole rule sentences, up to the final full stop. `plan.md` `## Risks` names this as the risk to avoid ("match on the heading, the trigger words and the fenced example, not whole sentences"). A harmless rewording such as "for example, a colour fix" turns them red. Matching on the bullet's start and its key words keeps the round 1 fix and the plan's mitigation both. — `test/agents_md_test.rb:6` →
- [ ] Nit: Example step 2, "Search your own stylesheets for `.button-old` and rename each selector", is the step that agents will copy, but it holds two actions. The rule on line 26 says each step is one concrete action. A single action such as "Rename each `.button-old` selector in your own stylesheets to `.button-new`" matches the rule. — `AGENTS.md:39` →

## Round 4 — 2026-10-12T15:03:18Z — 089aad7 (codex)

No findings. `codex review --base origin/main`: the guidance matches the intent, and the new tests check its key rules and example.
