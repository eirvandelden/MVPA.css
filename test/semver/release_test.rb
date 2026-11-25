require_relative "helper"

class ReleaseTest < Minitest::Test
  include GitFixture

  def setup = setup_repository
  def teardown = teardown_repository

  def test_a_patch_fragment_releases_a_patch
    assert_equal "1.0.1", plan("patch").version.to_s
  end

  def test_no_fragment_releases_a_patch
    assert_equal "1.0.1", plan.version.to_s
  end

  def test_the_highest_level_wins
    assert_equal "2.0.0", plan("minor", "major", "patch").version.to_s
  end

  def test_notes_number_the_upgrading_steps_continuously
    fragment("major", name: "a", upgrading: "\n### Upgrading\n1. First.\n2. Second.\n")
    fragment("major", name: "b", upgrading: "\n### Upgrading\n1. Third.\n")
    notes = Semver::Release.plan(latest: Semver::Version.parse("1.0.0"), fragments: read(%w[a b]),
date: Date.new(2026, 2, 3)).notes

    assert_includes notes, "## 2.0.0 - 2026-02-03"
    assert_includes notes, "### Upgrading\n1. First.\n2. Second.\n3. Third."
    assert_equal [ "### Added", "### Upgrading" ], notes.scan(/^### \w+/)
  end

  def test_consumed_lists_the_fragment_paths
    release = plan("minor")

    assert_equal [ File.join(@work, "changelog.d/minor.md") ], release.consumed
  end

  private

  def plan(*levels)
    levels.each { |level| fragment(level) }
    Semver::Release.plan(latest: Semver::Version.parse("1.0.0"), fragments: read(levels), date: Date.new(2026, 2, 3))
  end

  def read(names)
    names.map { |name| Semver::Fragment.read(File.join(@work, "changelog.d/#{name}.md")) }
  end
end
