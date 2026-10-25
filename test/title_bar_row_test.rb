require "minitest/autorun"
require_relative "css_source_helper"

# The page header's nav holds the title-bar controls. The sidebar rule makes every
# "header nav" a column; the page header lays its controls out as a wrapping row.
class TitleBarRowTest < Minitest::Test
  include CssSourceHelper

  HEADER = "1_layout/0_header.css".freeze
  TITLE_BAR = "main > header nav".freeze

  def test_title_bar_controls_form_a_wrapping_row
    each_source(HEADER) do |name, css|
      rule = rule_body(css, TITLE_BAR)

      assert_includes rule, "flex-direction: row;", name
      assert_includes rule, "flex-wrap: wrap;", name
    end
  end

  def test_wrapped_controls_keep_a_gap_and_a_shared_baseline
    each_source(HEADER) do |name, css|
      rule = rule_body(css, TITLE_BAR)

      assert_includes rule, "gap: var(--inline-space-half);", name
      assert_includes rule, "align-items: center;", name
    end
  end

  def test_the_title_bar_heading_wraps_instead_of_widening_the_page
    each_source(HEADER) do |name, css|
      rule = rule_body(css, "main > header h1")

      assert_includes rule, "min-inline-size: 0;", name
      assert_includes rule, "overflow-wrap: anywhere;", name
      refute_includes rule, "hyphens", name
    end
  end

  def test_the_sidebar_nav_stays_a_column
    column = rule_body(partial("2_modules/10_navigation.css"), "header nav")

    assert_includes column, "flex-direction: column;"
  end
end
