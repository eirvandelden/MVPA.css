require "minitest/autorun"

# Apps must change markup to get the new button hierarchy, action row and
# dialog, so the latest changelog entry tells them how.
class ChangelogUpgradingTest < Minitest::Test
  BUTTONS = "2026-10-13".freeze
  MENU = "2026-10-19".freeze
  BADGES = "2026-10-25".freeze

  def test_the_buttons_entry_tells_apps_how_to_upgrade
    upgrading = entry(BUTTONS)[/^### Upgrading.*?(?=^### |\z)/m]

    refute_nil upgrading, "the latest changelog entry has no ### Upgrading subsection"
    [ 'type="button"', 'type="reset"', "plain", '<form method="dialog">', "button-danger", "<footer>",
"<dialog", "1px border" ].each do |text|
      assert_includes upgrading, text
    end
  end

  def test_the_buttons_entry_lists_what_changed_was_added_and_was_removed
    [ "### Changed", "### Added", "### Removed" ].each { |heading| assert_includes entry(BUTTONS), heading }
  end

  def test_the_menu_entry_tells_apps_how_to_adopt_the_menu_and_responsive_tables
    upgrading = entry(MENU)[/^### Upgrading.*?(?=^### |\z)/m]

    refute_nil upgrading, "the latest changelog entry has no ### Upgrading subsection"
    assert_includes upgrading, "as a direct child of the `<nav>`"
    [ "<details>", "data-mvpa-flashes", "outside `<main>`", "data-stack", "data-label", 'role="table"', "<caption>",
"aria-labelledby", "<time datetime>", "<data value>", "overflow-x: auto" ].each do |text|
      assert_includes upgrading, text
    end
    assert_match(/^1\. /, upgrading)
  end

  def test_the_menu_entry_lists_what_was_added_and_changed_and_ends_with_upgrading
    assert_equal [ "### Added", "### Changed", "### Upgrading" ], entry(MENU).scan(/^### .*/)
  end

  def test_the_badges_entry_tells_apps_how_to_adopt_segmented_controls_and_badges
    upgrading = entry(BADGES)[/^### Upgrading.*?(?=^### |\z)/m]

    refute_nil upgrading, "the badges changelog entry has no ### Upgrading subsection"
    [ "13_segmented_control.css", "14_count_badge.css", "<select>", "<menu>", "aria-current", "<label>", "<data value",
"value=\"0\"", "main > header h1", "main > header nav" ].each do |text|
      assert_includes upgrading, text
    end
    assert_equal 7, upgrading.scan(/^\d+\. /).size
  end

  def test_the_badges_entry_lists_what_was_added_and_changed_and_ends_with_upgrading
    assert_equal [ "### Added", "### Changed", "### Upgrading" ], entry(BADGES).scan(/^### .*/)
    refute_equal entry(MENU), entry(BADGES)
  end

  def test_the_latest_entry_tells_apps_how_to_replace_their_week_navigation_class
    upgrading = latest_entry[/^### Upgrading.*?(?=^### |\z)/m]

    refute_nil upgrading, "the latest changelog entry has no ### Upgrading subsection"
    [ 'class="week-navigation"', "<h2>", "<header>", "@media (max-width: 768px)", "@import",
"bundle update mvpa-css", "Optional", "15_period_navigation.css" ].each do |text|
      assert_includes upgrading, text
    end
    assert_match(/^1\. /, upgrading)
  end

  def test_the_latest_entry_lists_what_was_added_and_ends_with_upgrading
    assert_equal [ "### Added", "### Upgrading" ], latest_entry.scan(/^### .*/)
    refute_equal entry(BADGES), latest_entry
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
