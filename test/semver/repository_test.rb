require_relative "helper"

class RepositoryTest < Minitest::Test
  include GitFixture

  def setup = setup_repository
  def teardown = teardown_repository

  def test_unreleased_is_true_before_any_release_commit
    assert_predicate repository, :unreleased?
  end

  def test_a_release_commit_tip_releases_nothing
    merge("minor")
    repository.publish
    calls = @runner.gh_calls.size
    before = origin_log
    repository.publish

    refute_predicate repository, :unreleased?
    assert_equal before, origin_log
    assert_equal calls + 1, @runner.gh_calls.size, "only the release list runs"
  end

  def test_publish_returns_the_released_version_and_nil_when_nothing_is_released
    merge("minor")

    assert_equal "1.1.0", repository.publish.to_s
    assert_nil repository.publish
  end

  def test_latest_version_is_the_max_of_the_file_and_the_tags
    assert_equal "1.0.0", repository.latest_version.to_s
    sh(@work, "git", "update-ref", "refs/tags/v1.4.0", "HEAD")
    sh(@work, "git", "update-ref", "refs/tags/v0.9.0", "HEAD")
    sh(@work, "git", "update-ref", "refs/tags/not-a-version", "HEAD")

    assert_equal "1.4.0", repository.latest_version.to_s
  end

  def test_a_minor_merge_releases_the_next_minor_and_deletes_the_fragment
    merge("minor")
    repository.publish

    assert_equal "Release v1.1.0", origin_log.first
    assert_includes origin_tags, "v1.1.0"
    assert_includes sh(@origin, "git", "show", "main:CHANGELOG.md"), "## 1.1.0 - 2026-02-03"
    assert_includes sh(@origin, "git", "show", "main:lib/mvpa/css/version.rb"), 'VERSION = "1.1.0"'
    assert_equal "changelog.d/README.md",
sh(@origin, "git", "ls-tree", "-r", "--name-only", "main", "changelog.d").strip
    assert(@runner.gh_calls.any? { |call| call[1..3] == %w[release create v1.1.0] })
  end

  def test_a_merge_without_a_fragment_releases_a_patch
    write("README.md", "docs\n")
    commit_all("docs only")
    sh(@work, "git", "push", "-q", "origin", "HEAD:main")
    repository.publish

    assert_includes origin_tags, "v1.0.1"
  end

  def test_a_second_merge_after_a_release_makes_a_second_release
    merge("minor", name: "first")
    repository.publish
    merge("patch", name: "second")
    repository.publish

    assert_equal %w[v1.1.0 v1.1.1], origin_tags.sort
  end

  def test_fragments_from_several_merges_share_one_release
    merge("minor", name: "one")
    merge("major", name: "two")
    merge("patch", name: "three")
    repository.publish
    notes = sh(@origin, "git", "show", "main:CHANGELOG.md")

    assert_equal %w[v2.0.0], origin_tags
    assert_equal 1, origin_log.count { |subject| subject.start_with?("Release") }
    %w[one two three].each { |name| assert_includes notes, "**#{name}**" }
  end

  def test_failing_tests_push_no_commit_and_no_tag
    merge("minor")
    @runner.tests_pass = false
    before = origin_log

    assert_raises(Semver::Shell::Failed) { repository.publish }
    assert_equal before, origin_log
    assert_empty origin_tags
    assert_path_exists File.join(@work, "changelog.d/minor.md")
  end

  def test_a_rejected_push_leaves_the_branch_and_the_tag_unchanged
    merge("minor")
    reject_pushes
    before = origin_log

    assert_raises(Semver::Shell::Failed) { repository.publish }
    assert_equal before, origin_log
    assert_empty origin_tags
    assert_empty sh(@work, "git", "tag", "--list").strip
  end

  def test_a_major_fragment_arriving_mid_run_is_in_the_retried_release
    merge("minor")
    raced = false
    @runner.before_push = lambda do
      next if raced

      raced = true
      other = File.join(@tmp, "other")
      sh(@tmp, "git", "clone", "-q", @origin, other)
      configure(other)
      fragment("major", name: "late", dir: other)
      commit_all("late major", dir: other)
      sh(other, "git", "push", "-q", "origin", "HEAD:main")
    end
    repository.publish

    assert_equal %w[v2.0.0], origin_tags
    assert_includes sh(@origin, "git", "show", "main:CHANGELOG.md"), "**late**"
  end

  def test_the_push_command_is_atomic
    pushes = []
    @runner.before_push = -> { }
    recorder = Object.new
    recorder.define_singleton_method(:call) do |command|
      pushes << command if command[1] == "push"
      @inner.call(command)
    end
    recorder.instance_variable_set(:@inner, @runner)
    merge("minor")
    Semver::Repository.new(root: @work, runner: recorder, clock: -> { Date.new(2026, 2, 3) }).publish

    assert_equal [ %w[git push --atomic origin HEAD:refs/heads/main refs/tags/v1.1.0] ], pushes.select { |command|
 command.include?("--atomic") }
  end

  def test_a_tag_on_another_commit_stops_the_release
    merge("minor")
    repository.publish
    sh(@work, "git", "tag", "-d", "v1.1.0")
    sh(@origin, "git", "tag", "-d", "v1.1.0")
    sh(@origin, "git", "update-ref", "refs/tags/v1.1.0", sh(@origin, "git", "rev-parse", "main~1").strip)
    @runner.releases

    assert_raises(Semver::Shell::Failed) { repository.reconcile }
    assert_equal sh(@origin, "git", "rev-parse", "main~1").strip, sh(@origin, "git", "rev-parse", "v1.1.0").strip
  end

  def test_a_missing_release_is_repaired_before_the_next_release
    merge("minor", name: "first")
    @runner.create_fails = true
    assert_raises(Semver::Shell::Failed) { repository.publish }
    assert_equal %w[v1.1.0], origin_tags

    @runner.create_fails = false
    merge("patch", name: "second")
    repository.publish
    created = @runner.gh_calls.select { |call| call[1..2] == %w[release create] }.map { |call| call[3] }

    assert_equal %w[v1.1.0 v1.1.1], created.last(2)
  end

  def test_reconcile_repairs_every_release_commit_without_a_tag_or_release_oldest_first
    merge("minor", name: "first")
    repository.publish
    merge("patch", name: "second")
    repository.publish
    sh(@origin, "git", "tag", "-d", "v1.1.0")
    sh(@origin, "git", "tag", "-d", "v1.1.1")
    sh(@work, "git", "tag", "-d", "v1.1.0")
    sh(@work, "git", "tag", "-d", "v1.1.1")
    @runner.gh_calls.clear
    @runner.releases
    repository.reconcile

    created = @runner.gh_calls.select { |call| call[1..2] == %w[release create] }.map { |call| call[3] }

    assert_equal %w[v1.1.0 v1.1.1], created
    assert_equal %w[v1.1.0 v1.1.1], origin_tags.sort
  end

  def test_reconcile_fails_closed_on_a_gh_error
    merge("minor")
    repository.publish
    @runner.list_fails = true

    assert_raises(Semver::Shell::Failed) { repository.reconcile }
  end

  def test_the_release_commit_holds_only_the_stamped_paths
    merge("minor")
    write("stray.txt", "x\n")
    repository.publish
    changed = sh(@origin, "git", "diff-tree", "--no-commit-id", "--name-only", "-r", "main").lines.map(&:chomp)

    assert_equal %w[CHANGELOG.md changelog.d/minor.md lib/mvpa/css/version.rb], changed.sort
  end

  private

  def reject_pushes
    hook = File.join(@origin, "hooks/pre-receive")
    File.write(hook, "#!/bin/sh\nexit 1\n")
    FileUtils.chmod(0o755, hook)
  end
end
