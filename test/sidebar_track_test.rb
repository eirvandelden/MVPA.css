require "minitest/autorun"
require_relative "css_source_helper"

# On desktop a nav-only header is an invisible, viewport-tall track that sticks by its bottom edge,
# and its nav paints the card. A short card stays at the top; a tall one scrolls until its last link shows.
class SidebarTrackTest < Minitest::Test
  include CssSourceHelper

  TRACK = "body > header:has(> nav:only-child)".freeze
  CARD = "body > header > nav:only-child".freeze
  FLOOR = "min-block-size: calc(100dvh - 2 * var(--shell-gutter));".freeze
  HAIRLINE = "border: 1px solid color-mix(in oklch, var(--color-fg) 14%, transparent);".freeze
  CARD_PAINT = [
    "border-radius: var(--radius-large);",
    "box-shadow: var(--shadow-3), var(--shadow-1);",
    "background-color: var(--color-bg-lighter);"
  ].freeze

  def test_a_nav_only_header_is_a_viewport_tall_track_that_sticks_by_its_bottom
    each_source("1_layout/0_header.css") do |name, css|
      track = rule_body(css, TRACK)

      assert_includes track, "align-self: end;", name
      assert_includes track, "bottom: var(--shell-gutter);", name
      assert_includes track, FLOOR, name
    end
  end

  def test_the_track_drops_the_top_inset_so_a_tall_sidebar_reaches_its_last_link
    each_source("1_layout/0_header.css") { |name, css| assert_includes rule_body(css, TRACK), "top: auto;", name }
  end

  def test_the_track_paints_nothing
    each_source("1_layout/0_header.css") do |name, css|
      track = rule_body(css, TRACK)

      [ "border: none;", "border-radius: 0;", "box-shadow: none;", "background-color: transparent;" ].each do |paint|
        assert_includes track, paint, name
      end
    end
  end

  def test_the_nav_card_is_only_as_tall_as_its_links
    each_source("1_layout/0_header.css") do |name, css|
      assert_includes rule_body(css, CARD), "min-block-size: auto;", name
    end
  end

  def test_the_nav_card_carries_the_card_paint
    each_source("1_layout/0_header.css") do |name, css|
      CARD_PAINT.each { |paint| assert_includes rule_body(css, CARD), paint, name }
    end
  end

  def test_the_track_and_card_rules_apply_on_desktop_only
    each_source("1_layout/0_header.css") do |name, css|
      refute_includes css_without_desktop_blocks(css), "> nav:only-child", name
      assert_includes desktop_blocks(css).join, TRACK, name
      assert_includes desktop_blocks(css).join, CARD, name
    end
  end

  def test_the_eink_card_rules_apply_on_desktop_only
    each_source("4_theme/2_eink.css") do |name, css|
      refute_includes css_without_desktop_blocks(css), "> nav:only-child", name
      assert_includes desktop_blocks(css).join, CARD, name
    end
  end

  def test_neither_the_track_nor_the_card_scrolls
    each_source("1_layout/0_header.css") do |name, css|
      [ TRACK, CARD ].each do |selector|
        refute_empty rule_body(css, selector), name
        refute_match(/overflow(-y)?: (auto|scroll)/, rule_body(css, selector), name)
      end
    end
  end

  def test_dark_and_eink_themes_border_the_nav_card
    each_source("1_layout/0_header.css") do |name, css|
      %w[ solunized-dark solunized-black ].each { |theme| assert_card_border(css, theme, name, HAIRLINE) }
    end
    each_source("4_theme/2_eink.css") do |name, css|
      { "eink-light" => "black", "eink-dark" => "white" }.each do |theme, color|
        assert_card_border(css, theme, name, "border: 1px solid #{color};")
      end
    end
  end

  def test_the_readme_says_a_nav_only_header_is_a_track_and_the_nav_paints_the_card
    readme = File.read(File.expand_path("../README.md", __dir__))
    bullet = readme.lines.find { |line| line.include?("only its `<nav>`") }

    refute_nil bullet, "README has no bullet about a header that holds only its <nav>"
    [ "invisible track", "paints the card", "taller than the window" ].each { |text| assert_includes bullet, text }
  end

  private

  def css_without_desktop_blocks(css)
    desktop_blocks(css).reduce(css) { |rest, block| rest.sub(block, "") }
  end

  def desktop_blocks(css)
    css.to_enum(:scan, /@media \(min-width: 769px\) \{/).map { balanced_block(css, Regexp.last_match.begin(0)) }
  end

  def assert_card_border(css, theme, name, border)
    body = rule_body(css, "[data-theme=\"#{theme}\"] #{CARD}")

    assert_includes body, "box-shadow: none;", "#{name} #{theme}"
    assert_includes body, border, "#{name} #{theme}"
  end
end
