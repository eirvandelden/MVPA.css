require_relative "helper"

class FragmentTest < Minitest::Test
  def test_reads_the_level_and_the_sections
    fragment = read("---\nlevel: minor\n---\n\n### Added\n- one\n\n### Fixed\n- two\n")

    assert_equal "minor", fragment.level.to_s
    assert_equal({ "Added" => "- one", "Fixed" => "- two" }, fragment.sections)
    assert_empty fragment.overrides
  end

  def test_a_missing_level_is_invalid
    assert_invalid "---\nother: 1\n---\n### Added\n- x\n"
  end

  def test_an_unknown_level_is_invalid
    assert_invalid "---\nlevel: huge\n---\n### Added\n- x\n"
  end

  def test_a_missing_front_matter_is_invalid
    assert_invalid "### Added\n- x\n"
  end

  def test_a_major_without_upgrading_is_invalid
    assert_invalid "---\nlevel: major\n---\n### Added\n- x\n"
    assert_invalid "---\nlevel: major\n---\n### Upgrading\nDo it.\n"
  end

  def test_a_major_with_numbered_upgrading_is_valid
    assert_equal "major", read("---\nlevel: major\n---\n### Upgrading\n1. Do it.\n").level.to_s
  end

  def test_upgrading_below_major_is_invalid
    assert_invalid "---\nlevel: minor\n---\n### Upgrading\n1. Do it.\n"
  end

  def test_reads_overrides
    fragment = read("---\nlevel: minor\noverrides:\n  token: \"app does not use it\"\n---\n### Added\n- x\n")

    assert_equal({ "token" => "app does not use it" }, fragment.overrides)
  end

  def test_an_unknown_rule_id_is_invalid
    assert_invalid "---\nlevel: minor\noverrides:\n  nope: why\n---\n### Added\n- x\n"
  end

  def test_an_empty_reason_is_invalid
    assert_invalid "---\nlevel: minor\noverrides:\n  token: \"\"\n---\n### Added\n- x\n"
  end

  def test_the_readme_in_changelog_d_is_not_a_fragment
    readme = File.read(File.expand_path("../../changelog.d/README.md", __dir__))

    refute_match(/\A---\n/, readme)
    assert_includes Dir["#{File.expand_path('../../changelog.d', __dir__)}/*.md"].map { |path|
 File.basename(path) }, "README.md"
  end

  private

  def read(text)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "x.md")
      File.write(path, text)
      Semver::Fragment.read(path)
    end
  end

  def assert_invalid(text)
    assert_raises(Semver::Fragment::Invalid) { read(text) }
  end
end
