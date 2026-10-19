require "minitest/autorun"
require "yaml"
require "json"

# Every check the project relies on must run in CI, where nobody can skip it.
class ContinuousIntegrationTest < Minitest::Test
  def test_every_check_runs_on_every_change
    assert_equal %w[gem stylesheets test yaml], workflow["jobs"].keys.sort
  end

  def test_the_workflow_only_runs_scripts_that_exist
    workflow_scripts.each do |script|
      assert_includes package_scripts, script,
                      "CI runs `npm run #{script}` but package.json defines no such script"
    end
  end

  def test_package_lock_replaces_yarn_lock
    assert File.file?(path("package-lock.json")), "npm ci needs package-lock.json"
    refute File.file?(path("yarn.lock")), "yarn.lock must not sit beside package-lock.json"
  end

  def test_no_tracked_file_names_yarn
    assert_empty yarn_mentions, "tracked files still name yarn:\n#{yarn_mentions.join("\n")}"
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
    read(".github/workflows/ci.yml").scan(/npm run (lint:[\w:-]+)/).flatten.uniq
  end

  def package_scripts
    JSON.parse(read("package.json"))["scripts"].keys
  end

  def yarn_mentions
    `git -C #{path(".")} grep -n -i yarn -- . ':!docs/changes' ':!test/continuous_integration_test.rb'`.lines
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
