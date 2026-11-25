require_relative "helper"
require "open3"
require "rbconfig"

# The release job tests the stamped tree before it pushes, so a changelog assertion that a new release
# breaks would block every later release. This runs the changelog tests against stamped changelogs.
class StampedChangelogTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  FRAGMENTS = {
    "major" => "---\nlevel: major\n---\n### Changed\n- **x** y\n\n### Upgrading\n1. Do it.\n",
    "minor" => "---\nlevel: minor\n---\n### Added\n- **x** y\n",
    "patch" => "---\nlevel: patch\n---\n### Fixed\n- **x** y\n"
  }.freeze

  def test_the_changelog_assertions_hold_after_each_kind_of_release
    FRAGMENTS.each do |level, text|
      Dir.mktmpdir do |dir|
        output, status = run_changelog_tests(stamped(dir, text))

        assert_predicate status, :success?, "after a #{level} release:\n#{output}"
      end
    end
  end

  private

  def run_changelog_tests(path)
    Open3.capture2e({ "MVPA_CHANGELOG" => path }, RbConfig.ruby, "-Itest", "test/changelog_upgrading_test.rb",
chdir: ROOT)
  end

  def stamped(dir, fragment_text)
    File.write(File.join(dir, "fragment.md"), fragment_text)
    release = Semver::Release.plan(latest: Semver::Version.parse("99.0.0"),
                                   fragments: [ Semver::Fragment.read(File.join(dir, "fragment.md")) ],
                                   date: Date.new(2099, 1, 1))
    File.join(dir, "CHANGELOG.md").tap do |path|
      File.write(path, Semver::Stamp.changelog_text(File.read(File.join(ROOT, "CHANGELOG.md")), release))
    end
  end
end
