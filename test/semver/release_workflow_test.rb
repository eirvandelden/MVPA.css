require_relative "helper"
require "yaml"

# The release workflow is the only place that pushes to main, so its safety settings are pinned here.
class ReleaseWorkflowTest < Minitest::Test
  def test_the_release_runs_one_at_a_time
    concurrency = workflow["concurrency"]

    assert_equal "release", concurrency["group"]
    refute concurrency["cancel-in-progress"]
  end

  def test_the_release_pushes_atomically_from_main
    checkout = steps.find { |step| step["uses"].to_s.start_with?("actions/checkout") }

    assert_equal "main", checkout["with"]["ref"]
    assert_equal 0, checkout["with"]["fetch-depth"]
    assert checkout["with"]["fetch-tags"]
    refute_includes File.read(path), "github.sha"
    assert_includes File.read(File.expand_path("../../script/semver/repository.rb", __dir__)), '"--atomic"'
  end

  def test_the_release_uses_only_the_github_token
    text = File.read(path)

    assert_equal [ "GITHUB_TOKEN" ], text.scan(/secrets\.(\w+)/).flatten.uniq
    assert_equal({ "contents" => "write" }, workflow["jobs"]["release"]["permissions"])
  end

  def test_the_token_reaches_only_the_release_step
    refute workflow["jobs"]["release"].key?("env"), "a job-level env gives every step the write token"
    step = steps.find { |candidate| candidate["run"].to_s.include?("script/semver/release") }

    assert_equal "${{ secrets.GITHUB_TOKEN }}", step["env"]["GH_TOKEN"]
  end

  def test_the_checkout_keeps_no_credentials_for_later_steps
    checkout = steps.find { |step| step["uses"].to_s.start_with?("actions/checkout") }
    release = steps.find { |step| step["run"].to_s.include?("script/semver/release") }

    assert_same false, checkout["with"]["persist-credentials"]
    assert_includes release["run"], "git remote set-url origin"
    assert_includes release["run"], "${GH_TOKEN}"
  end

  def test_every_third_party_action_is_pinned_to_a_commit
    third_party = steps.filter_map { |step| step["uses"] }.reject { |uses| uses.start_with?("actions/") }

    refute_empty third_party
    third_party.each { |uses| assert_match(/@\h{40}\z/, uses, "#{uses} is a mutable reference") }
  end

  def test_the_release_runs_the_script_on_a_push_to_main
    assert_equal [ "main" ], workflow["on"]["push"]["branches"]
    assert(steps.any? { |step| step["run"].to_s.include?("script/semver/release") })
  end

  def test_the_surface_workflow_only_reads_the_repository
    surface = YAML.safe_load_file(File.expand_path("../../.github/workflows/surface.yml", __dir__))

    assert_equal({ "contents" => "read" }, surface["permissions"])
    assert(surface["jobs"].values.first["steps"].any? { |step| step["run"].to_s.include?("script/semver/surface") })
  end

  private

  def workflow
    YAML.safe_load_file(path).tap { |hash| hash["on"] = hash.delete(true) if hash.key?(true) }
  end

  def path
    File.expand_path("../../.github/workflows/release.yml", __dir__)
  end

  def steps
    workflow["jobs"]["release"]["steps"]
  end
end
