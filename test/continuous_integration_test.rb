require "minitest/autorun"
require "yaml"
require "json"

# Every check the project relies on must run in CI, where nobody can skip it.
class ContinuousIntegrationTest < Minitest::Test
  def test_every_check_runs_on_every_change
    assert_equal %w[gem spelling stylesheets test yaml], workflow["jobs"].keys.sort
  end

  def test_the_workflow_only_runs_scripts_that_exist
    workflow_scripts.each do |script|
      assert_includes package_scripts, script,
                      "CI runs `yarn #{script}` but package.json defines no such script"
    end
  end

  def test_dependabot_watches_gems_packages_and_actions
    assert_equal %w[bundler github-actions npm], watched_ecosystems.sort
  end

  def test_the_project_pins_the_ruby_it_runs_on
    assert_match(/\A\d+\.\d+\.\d+\z/, pinned_ruby,
                 "CI asks rv for the 'current' Ruby, which is whatever .ruby-version says")
  end

  def test_the_yaml_rules_ship_with_the_repository
    assert File.file?(path(".yamllint.yml")),
           "without its own config, CI falls back to yamllint defaults and disagrees with the hooks"
  end

  private

  def workflow
    YAML.safe_load(read(".github/workflows/ci.yml"))
  end

  def read(relative_path)
    File.read(path(relative_path))
  end

  def path(relative_path)
    File.expand_path("../#{relative_path}", __dir__)
  end

  def workflow_scripts
    read(".github/workflows/ci.yml").scan(/yarn (lint:[\w:-]+)/).flatten.uniq
  end

  def package_scripts
    JSON.parse(read("package.json"))["scripts"].keys
  end

  def watched_ecosystems
    dependabot["updates"].map { |entry| entry["package-ecosystem"] }
  end

  def dependabot
    YAML.safe_load(read(".github/dependabot.yml"))
  end

  def pinned_ruby
    File.file?(path(".ruby-version")) ? read(".ruby-version").strip : "missing"
  end
end
