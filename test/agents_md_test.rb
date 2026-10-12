require "minitest/autorun"

# Verifies AGENTS.md tells agents when a changelog entry needs an Upgrading subsection.
class AgentsMdTest < Minitest::Test
  def test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act
    assert_includes changelog_section, "### Upgrading"
  end

  def test_changelog_rule_names_what_requires_apps_to_act
    %w[markup classes configuration code].each do |trigger|
      assert_includes changelog_section, trigger
    end
  end

  def test_changelog_rule_excludes_entries_without_app_changes
    assert_match(/no .*### Upgrading/i, changelog_section)
  end

  def test_changelog_rule_shows_an_example_upgrading_subsection
    example = changelog_section[/```markdown\n(.*?)```/m, 1]

    refute_nil example, "no fenced Markdown example"
    assert_match(/^## \d{4}-\d{2}-\d{2}$/, example)
    assert_match(/^### Upgrading$/, example)
    assert_match(/^1\. .*button-old.*button-new/, example)
  end

  private

  def changelog_section
    agents_md[/^## Changelog\n(.*?)(?=^## (?!\d{4}-)|\z)/m, 1].to_s
  end

  def agents_md
    File.read(File.expand_path("../AGENTS.md", __dir__))
  end
end
