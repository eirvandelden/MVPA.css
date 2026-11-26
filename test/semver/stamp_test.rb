require_relative "helper"

class StampTest < Minitest::Test
  def test_version_source_rewrites_the_literal
    assert_includes Semver::Stamp.version_source(GitFixture::VERSION_FILE, Semver::Version.parse("2.0.0")),
'VERSION = "2.0.0"'
  end

  def test_changelog_text_inserts_above_the_first_release_heading
    text = Semver::Stamp.changelog_text(GitFixture::CHANGELOG, release("1.0.1"))

    assert_operator text.index("## 1.0.1 - 2026-02-03"), :<, text.index("## 1.0.0 - 2026-01-01")
    assert_equal 2, text.scan(/^## \d/).size
  end

  def test_changelog_text_refuses_a_heading_that_exists
    assert_raises(ArgumentError) { Semver::Stamp.changelog_text(GitFixture::CHANGELOG, release("1.0.0")) }
  end

  private

  def release(version)
    Semver::Release.new(Semver::Version.parse(version), [],
Date.new(2026, version == "1.0.0" ? 1 : 2, version == "1.0.0" ? 1 : 3))
  end
end
