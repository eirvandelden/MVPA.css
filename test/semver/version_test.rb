require_relative "helper"

class VersionTest < Minitest::Test
  def test_parse_reads_x_y_z
    assert_equal "1.2.3", Semver::Version.parse("1.2.3").to_s
  end

  def test_parse_refuses_text_that_is_not_x_y_z
    assert_raises(ArgumentError) { Semver::Version.parse("1.2") }
  end

  def test_major_resets_minor_and_patch
    assert_equal "2.0.0", bump("1.4.9", "major")
  end

  def test_minor_resets_patch
    assert_equal "1.5.0", bump("1.4.9", "minor")
  end

  def test_patch_raises_the_patch
    assert_equal "1.4.10", bump("1.4.9", "patch")
  end

  def test_versions_compare_numerically
    assert_operator Semver::Version.parse("1.10.0"), :>, Semver::Version.parse("1.9.0")
  end

  private

  def bump(text, level)
    Semver::Version.parse(text).bump(Semver::Level.parse(level)).to_s
  end
end
