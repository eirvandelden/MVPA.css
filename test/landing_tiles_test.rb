require "minitest/autorun"
require_relative "css_source_helper"

# On a page with a rail, a <ul> of links in a <nav> in main is a grid of landing tiles.
# A phone shows the same tiles as one list of rows, each ending in ›.
class LandingTilesTest < Minitest::Test
  include CssSourceHelper

  RAIL_CSS = "2_modules/16_rail.css".freeze
  PHONE = "(max-width: 768px)".freeze
  TILES = "body:has(> header > nav.rail) main nav:not(header nav) > ul".freeze
  TILE = "#{TILES} > li > a".freeze
  SURFACE = [
    "background-color: var(--color-bg-lighter);",
    "border: 1px solid var(--color-bg-darker);",
    "border-radius: var(--radius-large);",
    "box-shadow: var(--shadow-1);",
    "text-decoration: none;"
  ].freeze
  EINK = { "eink-light" => "black", "eink-dark" => "white" }.freeze

  def test_tiles_are_surface_tiles_in_a_14rem_grid
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(css, TILES), "display: grid;", name
      assert_includes rule_body(css, TILES),
"grid-template-columns: repeat(auto-fill, minmax(min(14rem, 100%), 1fr));", name
      SURFACE.each { |paint| assert_includes rule_body(css, TILE), paint, name }
      assert_includes rule_body(css, "#{TILES} > li"), "margin: 0;", name
    end
  end

  def test_a_tile_lifts_on_hover
    each_source(RAIL_CSS) do |name, css|
      hover = rule_body(css, "#{TILE}:hover")

      assert_includes hover, "transform: scale(var(--animation-scale-small)) translateY(-2px);", name
      assert_includes hover, "box-shadow: var(--shadow-2);", name
    end
  end

  def test_a_tile_has_no_underline_wiggle
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(css, ":root:root #{TILE}::after"), "content: none;", name
    end
  end

  def test_a_tile_count_is_plain_text
    each_source(RAIL_CSS) do |name, css|
      tile_selectors(css).each { |selector|
 refute_match(/(?:\A|[\s>+~(])data(?![\w-])/, selector, "#{name}: #{selector}") }
    end
  end

  def test_tiles_become_rows_with_a_trailing_chevron_on_a_phone
    each_source(RAIL_CSS) do |name, css|
      phone = media_blocks(css, PHONE).join

      assert_includes rule_body(phone, TILES), "grid-template-columns: 1fr;", name
      assert_includes rule_body(phone, TILES), "background-color: var(--color-bg-lighter);", name
      assert_includes rule_body(phone, "#{TILES} > li + li"), "border-block-start: 1px solid var(--color-border);", name
      assert_includes rule_body(phone, TILE), "box-shadow: none;", name
      assert_includes rule_body(phone, "#{TILE}:hover"), "transform: none;", name
      assert_includes rule_body(phone, "#{TILE}::before"), 'content: "›" / "";', name
      assert_includes rule_body(phone, "#{TILE}::before"), "margin-inline-start: auto;", name
    end
  end

  def test_only_a_nav_with_a_list_of_links_becomes_tiles
    each_source(RAIL_CSS) do |name, css|
      selectors = tile_selectors(css)

      refute_empty selectors, name
      selectors.each { |selector| assert_match(/nav:not\(header nav\) > ul(?: |\z)/, selector, "#{name}: #{selector}") }
    end
  end

  def test_eink_tiles_have_an_ink_border_and_no_shadow
    each_source("4_theme/2_eink.css") do |name, css|
      EINK.each do |theme, color|
        [ TILE, "#{TILE}:hover" ].each do |selector|
          body = rule_body(css, "[data-theme=\"#{theme}\"] #{selector}")

          assert_includes body, "box-shadow: none;", "#{name} #{theme} #{selector}"
          assert_includes body, "border: 1px solid #{color};", "#{name} #{theme} #{selector}"
        end
        assert_includes rule_body(media_blocks(css, PHONE).join, "[data-theme=\"#{theme}\"] #{TILES}"),
          "border: 1px solid #{color};", "#{name} #{theme} phone list"
      end
    end
  end

  private

  # Every selector in the bundle or the partial that styles a landing tile.
  def tile_selectors(css)
    css.scan(/^[^{}\n]*main nav:not\(header nav\)[^{}]*\{/).flat_map { |list| list.delete("{").split(",").map(&:strip) }
  end
end
