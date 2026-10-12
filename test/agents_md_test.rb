require "minitest/autorun"

# Verifies AGENTS.md tells agents when a changelog entry needs an Upgrading subsection.
class AgentsMdTest < Minitest::Test
  def test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act
    assert_match(/^- Add a `### Upgrading` subsection to the dated entry when an app must/, rules)
  end

  def test_changelog_rule_names_what_requires_apps_to_act
    trigger_rule = rules[/^- Add a `### Upgrading` subsection.*$/]

    %w[markup classes configuration code].each do |trigger|
      assert_match(/\b#{trigger}\b/, trigger_rule.to_s)
    end
  end

  def test_changelog_rule_excludes_entries_without_app_changes
    assert_match(/^- Add no `### Upgrading` subsection when an app needs to do nothing, for example a colour fix\./,
                 rules)
  end

  def test_changelog_rule_appends_to_an_existing_upgrading_subsection
    assert_match(/^- When the dated entry already has a `### Upgrading` subsection, append the new steps to it\./,
                 rules)
  end

  def test_changelog_rule_shows_an_example_upgrading_subsection
    example = changelog_section[/```markdown\n(.*?)```/m, 1]

    refute_nil example, "no fenced Markdown example"
    assert_match(/^## \d{4}-\d{2}-\d{2}$/, example)
    assert_match(/^### Upgrading$/, example)
    assert_match(/^1\. .*button-old.*button-new/, example)
  end

  private

  # The Changelog section without its fenced example, so a rule cannot pass on the example's text.
  def rules
    changelog_section.gsub(/^```.*?^```\n/m, "")
  end

  # The Changelog section up to the next level-two heading outside a fence.
  def changelog_section
    lines = agents_md.lines.drop_while { |line| line != "## Changelog\n" }.drop(1)
    in_fence = false
    lines.take_while do |line|
      in_fence = !in_fence if line.start_with?("```")
      in_fence || !line.start_with?("## ")
    end.join
  end

  def agents_md
    File.read(File.expand_path("../AGENTS.md", __dir__))
  end
end
