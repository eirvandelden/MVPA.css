require "minitest/autorun"

# Apps must change markup to get the new button hierarchy, action row and
# dialog, so the latest changelog entry tells them how.
class ChangelogUpgradingTest < Minitest::Test
  BUTTONS = "2026-10-13".freeze

  def test_the_latest_entry_tells_apps_how_to_upgrade
    upgrading = entry(BUTTONS)[/^### Upgrading.*?(?=^### |\z)/m]

    refute_nil upgrading, "the latest changelog entry has no ### Upgrading subsection"
    [ 'type="button"', 'type="reset"', "plain", '<form method="dialog">', "button-danger", "<footer>",
"<dialog", "1px border" ].each do |text|
      assert_includes upgrading, text
    end
  end

  def test_the_latest_entry_lists_what_changed_was_added_and_was_removed
    [ "### Changed", "### Added", "### Removed" ].each { |heading| assert_includes entry(BUTTONS), heading }
  end

  def test_the_latest_entry_tells_apps_how_to_adopt_the_menu_and_responsive_tables
    upgrading = latest_entry[/^### Upgrading.*?(?=^### |\z)/m]

    refute_nil upgrading, "the latest changelog entry has no ### Upgrading subsection"
    [ "<details>", "data-mvpa-flashes", "outside `<main>`", "data-stack", "data-label", 'role="table"', "<caption>", "aria-labelledby", "<time datetime>",
"<data value>", "overflow-x: auto" ].each do |text|
      assert_includes upgrading, text
    end
    assert_match(/^1\. /, upgrading)
  end

  def test_the_latest_entry_lists_what_was_added_and_changed_and_ends_with_upgrading
    headings = latest_entry.scan(/^### .*/)

    assert_equal [ "### Added", "### Changed", "### Upgrading" ], headings
  end

  private

  def entry(date)
    File.read(changelog)[/^## #{date}.*?(?=^## \d{4}|\z)/m]
  end

  def changelog
    File.expand_path("../CHANGELOG.md", __dir__)
  end

  def latest_entry
    File.read(changelog)[/^## \d{4}-\d{2}-\d{2}.*?(?=^## \d{4}|\z)/m]
  end
end
