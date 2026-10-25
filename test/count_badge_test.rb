require "minitest/autorun"
require_relative "css_source_helper"

# A <data value> inside a link renders as a count pill.
class CountBadgeTest < Minitest::Test
  include CssSourceHelper

  PARTIAL = "2_modules/14_count_badge.css".freeze

  def test_data_in_a_link_is_a_primary_pill
    each_source(PARTIAL) do |name, css|
      tokens = rule_body(css, ":where(a data)")
      pill = rule_body(css, "a data")

      assert_includes tokens, "--badge-contrast: oklch(100% 0 0);", name
      assert_includes tokens, "--badge-bg: var(--color-primary);", name
      assert_includes tokens, "--badge-fg: var(--badge-contrast);", name
      assert_includes pill, "border-radius: 999px;", name
      assert_includes pill, "background-color: var(--badge-bg);", name
      assert_includes pill, "color: var(--badge-fg);", name
    end
  end

  def test_a_long_number_stays_on_one_line_with_tabular_figures
    each_source(PARTIAL) do |name, css|
      pill = rule_body(css, "a data")

      assert_includes pill, "white-space: nowrap;", name
      assert_includes pill, "font-variant-numeric: tabular-nums;", name
      assert_includes pill, "min-inline-size: 1.6em;", name
      assert_includes pill, "display: inline-block;", name
    end
  end

  def test_a_zero_badge_is_hidden
    each_source(PARTIAL) do |name, css|
      assert_includes rule_body(css, 'a data[value="0"]'), "display: none;", name
    end
  end

  def test_the_badge_inverts_on_a_current_link
    each_source(PARTIAL) do |name, css|
      inverted = rule_body(css, 'a[aria-current]:not([aria-current="false"]) data')

      assert_includes inverted, "--badge-bg: var(--badge-contrast);", name
      assert_includes inverted, "--badge-fg: var(--color-primary);", name
    end
  end

  def test_a_badge_in_a_segmented_control_stays_primary
    each_source(PARTIAL) do |name, css|
      kept = rule_body(css, 'menu > li > a[aria-current]:not([aria-current="false"]) data')

      assert_includes kept, "--badge-bg: var(--color-primary);", name
      assert_includes kept, "--badge-fg: var(--badge-contrast);", name
      assert_operator css.index("menu > li > a[aria-current]"), :>,
css.index('a[aria-current]:not([aria-current="false"]) data'), name
    end
  end

  # The hover underline spans the whole link box, so it would run under the pill.
  def test_a_link_with_a_badge_gets_no_wiggle_underline
    each_source("0_base/3_animations.css") do |name, css|
      assert_match(/a:not\(\[class\]\):not\([^{]*, a:has\(> data\)\)::after \{/, css, name)
    end
  end

  def test_every_badge_selector_needs_a_link_ancestor
    selectors = partial(PARTIAL).scan(/([^{}]+)\{/).flatten.map { |s| s.gsub(%r{/\*.*?\*/}m, "") }

    selectors.flat_map { |s| s.split(",") }.map(&:strip).reject(&:empty?).each do |selector|
      assert_match(/\A(:where\()?(a|menu > li > a)[ \[:)]/, selector)
    end
  end
end
