require "minitest/autorun"

# Apps must change markup to get the new button hierarchy, action row and
# dialog, so the latest changelog entry tells them how.
class ChangelogUpgradingTest < Minitest::Test
  def test_the_latest_entry_tells_apps_how_to_upgrade
    upgrading = latest_entry[/^### Upgrading.*?(?=^### |\z)/m]

    refute_nil upgrading, "the latest changelog entry has no ### Upgrading subsection"
    [ 'type="button"', 'type="reset"', "plain", '<form method="dialog">', "button-danger", "<footer>",
"<dialog", "1px border" ].each do |text|
      assert_includes upgrading, text
    end
  end

  def test_the_latest_entry_lists_what_changed_was_added_and_was_removed
    [ "### Changed", "### Added", "### Removed" ].each { |heading| assert_includes latest_entry, heading }
  end

  private

  def latest_entry
    File.read(File.expand_path("../CHANGELOG.md", __dir__))[/^## \d{4}-\d{2}-\d{2}.*?(?=^## \d{4}|\z)/m]
  end
end
