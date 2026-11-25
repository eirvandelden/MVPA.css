require_relative "helper"

# The walking skeleton: two merged fragments end as one release on the remote, with a tag and a GitHub release.
class ReleaseAcceptanceTest < Minitest::Test
  include GitFixture

  def setup = setup_repository
  def teardown = teardown_repository

  def test_two_fragments_release_one_major_version
    merge("minor", name: "feature")
    merge("major", name: "break")
    repository.publish

    assert_equal "Release v2.0.0", origin_log.first
    assert_equal [ "v2.0.0" ], origin_tags
    assert_includes sh(@origin, "git", "show", "main:CHANGELOG.md"), "## 2.0.0 - 2026-02-03"
    assert(@runner.gh_calls.any? { |call| call[1..3] == %w[release create v2.0.0] })
  end
end
