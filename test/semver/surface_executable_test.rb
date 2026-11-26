require_relative "surface_fixture"
require "rbconfig"

class SurfaceExecutableTest < Minitest::Test
  include SurfaceFixture

  SCRIPT = File.expand_path("../../script/semver/surface", __dir__)

  def setup = setup_surface
  def teardown = teardown_repository

  def test_the_check_exits_zero_and_prints_the_rule_id_and_reason
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    write("changelog.d/feature.md",
"---\nlevel: minor\noverrides:\n  token: \"no app uses it\"\n---\n### Changed\n- x\n")
    commit_all("fragment")
    output, status = run_check

    assert_predicate status, :success?
    assert_includes output, "override token: no app uses it"
  end

  def test_the_check_exits_one_below_major_without_an_override
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    write("changelog.d/feature.md", "---\nlevel: minor\n---\n### Changed\n- x\n")
    commit_all("fragment")
    output, status = run_check

    refute_predicate status, :success?
    assert_includes output, "token:--gap"
  end

  def test_a_major_fragment_passes
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    write("changelog.d/feature.md", "---\nlevel: major\n---\n### Upgrading\n1. Stop using it.\n")
    commit_all("fragment")

    assert_predicate run_check.last, :success?
  end

  def test_an_invalid_fragment_fails
    write("changelog.d/feature.md", "---\nlevel: huge\n---\n")
    commit_all("fragment")
    output, status = run_check

    refute_predicate status, :success?
    assert_includes output, "unknown level"
  end

  def test_editing_a_fragment_the_pull_request_did_not_add_fails
    merge_to_main_fragment
    write("changelog.d/old.md", "---\nlevel: patch\n---\n### Fixed\n- changed\n")
    commit_all("edit old fragment")

    refute_predicate run_check.last, :success?
  end

  private

  def run_check
    Open3.capture2e(RbConfig.ruby, SCRIPT, "main", "feature", chdir: @work)
  end

  def merge_to_main_fragment
    sh(@work, "git", "checkout", "-q", "main")
    fragment("patch", name: "old")
    commit_all("old fragment")
    sh(@work, "git", "checkout", "-q", "feature")
    sh(@work, "git", "rebase", "-q", "main")
  end
end
