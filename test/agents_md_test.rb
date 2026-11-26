require "minitest/autorun"

# Verifies AGENTS.md tells agents when a change is breaking and how a fragment records it.
class AgentsMdTest < Minitest::Test
  def test_changelog_rule_asks_for_an_upgrading_subsection_when_apps_must_act
    assert(rule_line(/Add a `### Upgrading`/, /`major` fragment/), "no rule asks for an Upgrading subsection")
  end

  def test_changelog_rule_names_what_requires_apps_to_act
    trigger_rule = rule_line(/Set `level: major`/, /app must/)

    %w[markup classes configuration code].each do |trigger|
      assert_match(/\b#{trigger}\b/, trigger_rule.to_s)
    end
  end

  def test_changelog_rule_excludes_entries_without_app_changes
    assert(rule_line(/below major has no `### Upgrading`/, /colour fix/),
"no rule excludes entries such as a colour fix")
  end

  def test_the_changelog_rule_says_a_fragment_states_the_level
    assert_match(%r{changelog\.d/<branch-slug>\.md.*`level`}, changelog_section)
    assert_match(/never write a version number/i, changelog_section)
    assert(rule_line(/Set `level: minor`/, /Set `level: patch`/), "no rule names minor and patch")
    assert(rule_line(/`overrides:/), "no rule explains overrides")
  end

  def test_the_changelog_rule_names_the_public_surface_that_makes_a_change_major
    major = rule_line(/Removing or renaming/).to_s

    [ "--token", "stylesheet", "class selector", "data-", "importmap pin" ].each { |surface|
 assert_includes major, surface }
    assert(rule_line(/element-structure contract/i, /nav\.rail/), "no rule covers markup contracts")
  end

  def test_changelog_rule_shows_an_example_upgrading_subsection
    example = changelog_section[/```markdown\n(.*?)```/m, 1]

    refute_nil example, "no fenced Markdown example"
    assert_match(/\A---\nlevel: major\n---$/, example)
    assert_match(/^### Upgrading$/, example)
    assert_match(/^1\. .*button-old.*button-new/, example)
    example.scan(/^\d+\. .*$/).each { |step| refute_match(/ and /, step, "a step holds two actions: #{step}") }
  end

  private

  # The first rule bullet that matches every pattern, or nil.
  def rule_line(*patterns)
    rules.lines.find { |line| line.start_with?("- ") && patterns.all? { |pattern| line.match?(pattern) } }
  end

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
