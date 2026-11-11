require "minitest/autorun"
require_relative "css_source_helper"

# A rail of hubs and a hub column share one sidebar card on a wide screen.
# Every rule is keyed on nav.rail, so a page with today's single-nav sidebar matches none of them.
class RailTest < Minitest::Test
  include CssSourceHelper

  RAIL_CSS = "2_modules/16_rail.css".freeze
  WIDE = "(min-width: 769px)".freeze
  NARROW = "(max-width: 1023px)".freeze
  PHONE = "(max-width: 768px)".freeze
  RAIL_BODY = "body:has(> header > nav.rail)".freeze
  TRACK = "body > header:has(> nav.rail)".freeze
  RAIL = "body > header > nav.rail".freeze
  HUB_COLUMN = "body > header > nav.rail + nav".freeze
  CARD = "body > header:has(> nav.rail + nav)::before".freeze
  HUB = "nav.rail > ul > li > a".freeze
  EMOJI = "nav.rail > ul > li > a > span[aria-hidden=\"true\"]".freeze
  SEARCH_BUTTON = ":root:root nav.rail > search > button".freeze
  POP_UP = "nav.rail details > ul".freeze
  TITLE_BAR_SEARCH = "body:has(> header > nav.rail) main > header nav > search".freeze
  TITLE_BAR_ACCOUNT = "body:has(> header > nav.rail) main > header nav > details:has(> summary[aria-label])".freeze
  HAIRLINE = "border: 1px solid color-mix(in oklch, var(--color-fg) 14%, transparent);".freeze
  SIDEBAR_TRACK = [
    "align-self: end;",
    "top: auto;",
    "bottom: var(--shell-gutter);",
    "min-block-size: calc(100dvh - 2 * var(--shell-gutter));",
    "border: none;",
    "border-radius: 0;",
    "box-shadow: none;",
    "background-color: transparent;"
  ].freeze

  def test_css_source_helper_media_blocks_returns_every_block_of_one_media_query
    css = "a { color: red; }\n@media (x) { b { c: d; } }\ne { f: g; }\n@media (x) { h { i: j; } }\n@media (y) { k {} }"

    assert_equal [ "@media (x) { b { c: d; } }", "@media (x) { h { i: j; } }" ], media_blocks(css, "(x)")
  end

  def test_the_rail_width_is_a_navigation_token
    each_source("0_base/0_variables.css") do |name, css|
      assert_match(/--nav-width: 240px;\n  --rail-width: 5\.5rem;/, css, name)
    end
    each_source(RAIL_CSS) { |name, css|
 assert_includes rule_body(wide(css), RAIL), "inline-size: var(--rail-width);", name }
  end

  def test_a_rail_and_hub_column_share_one_card_beside_main_on_a_wide_screen
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(wide(css), RAIL_BODY), "grid-template-columns: auto 1fr;", name
      assert_includes rule_body(wide(css), TRACK), "grid-template-columns: auto auto;", name
      assert_includes rule_body(wide(css), RAIL), "grid-column: 1;", name
      assert_includes rule_body(wide(css), HUB_COLUMN), "grid-column: 2;", name
      assert_includes rule_body(wide(css), HUB_COLUMN), "inline-size: var(--nav-width);", name
      assert_includes rule_body(wide(css), HUB_COLUMN), "border-inline-start: 1px solid var(--color-border);", name
      assert_includes rule_body(wide(css), CARD), "grid-column: 1 / -1;", name
      assert_includes rule_body(wide(css), CARD), "background-color: var(--color-bg-lighter);", name
    end
  end

  def test_a_rail_only_header_keeps_the_rail_in_its_place_with_its_own_card
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(wide(css), "#{TRACK} > nav"), "grid-row: 1;", name
      assert_includes rule_body(wide(css), RAIL), "grid-column: 1;", name
      refute_includes rail_section(css), "nav:only-child",
"#{name}: the nav-only card rule of 0_header.css paints a rail-only card"
    end
    each_source("1_layout/0_header.css") do |name, css|
      assert_includes rule_body(wide(css), "body > header > nav:only-child"),
"background-color: var(--color-bg-lighter);", name
    end
  end

  def test_the_joined_card_needs_a_hub_column
    each_source(RAIL_CSS) do |name, css|
      card_selectors = rail_section(css).scan(/^[^{}\n]*body > header[^{}\n]*::before[^{}]*\{/)

      refute_empty card_selectors, name
      card_selectors.each { |selector| assert_includes selector, "nav.rail + nav", name }
      assert_includes rule_body(wide(css), CARD), 'content: "";', name
      assert_includes rule_body(wide(css), CARD), "grid-row: 1;", name
    end
  end

  def test_the_joined_card_is_as_tall_as_the_taller_nav
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(wide(css), TRACK), "align-content: start;", name
      assert_includes rule_body(wide(css), "#{TRACK} > nav"), "min-block-size: auto;", name
      refute_includes rule_body(wide(css), HUB_COLUMN), "align-self", name
    end
  end

  def test_the_rail_is_as_tall_as_its_content
    each_source(RAIL_CSS) { |name, css| assert_includes rule_body(wide(css), RAIL), "align-self: start;", name }
  end

  def test_the_rail_track_matches_the_sidebar_track
    sidebar_track = rule_body(wide(partial("1_layout/0_header.css")), "body > header:has(> nav:only-child)")

    each_source(RAIL_CSS) do |name, css|
      SIDEBAR_TRACK.each do |declaration|
        assert_includes sidebar_track, declaration, "0_header.css"
        assert_includes rule_body(wide(css), TRACK), declaration, name
      end
    end
  end

  def test_a_rail_hub_shows_its_emoji_above_a_small_hyphenated_label
    each_source(RAIL_CSS) do |name, css|
      hub = rule_body(css, HUB)

      [ "flex-direction: column;", "align-items: center;", "font-size: var(--text-x-small);", "text-align: center;",
        "-webkit-hyphens: auto;", "hyphens: auto;", "overflow-wrap: anywhere;" ].each do |declaration|
        assert_includes hub, declaration, name
      end
      assert_includes rule_body(css, EMOJI), "font-size: var(--text-large);", name
    end
  end

  def test_the_current_hub_has_the_current_page_fill
    current_page = rule_body(partial("2_modules/10_navigation.css"), 'header nav ul li > a[aria-current="page"]')

    each_source(RAIL_CSS) do |name, css|
      current_hub = rule_body(css, "#{HUB}[aria-current=\"true\"]")

      [ "background-color: var(--color-primary);", "color: var(--color-bg-lightest);" ].each do |fill|
        assert_includes current_page, fill
        assert_includes current_hub, fill, name
      end
    end
  end

  def test_the_rail_search_button_looks_like_a_rail_item
    each_source(RAIL_CSS) do |name, css|
      button = rule_body(css, SEARCH_BUTTON)

      [ "flex-direction: column;", "background-color: transparent;", "border: none;", "box-shadow: none;",
        "color: var(--color-fg);", "margin: 0;", "animation: none;", "filter: none;" ].each do |declaration|
        assert_includes button, declaration, name
      end
      assert_includes rule_body(css, "#{SEARCH_BUTTON}:hover"), "animation: none;", name
      assert_includes rule_body(css, "#{SEARCH_BUTTON}:hover"),
"transform: scale(var(--animation-scale-small)) translateY(-2px);", name
    end
  end

  def test_the_account_menu_opens_beside_the_rail_over_the_hub_column
    each_source(RAIL_CSS) do |name, css|
      pop_up = rule_body(css, POP_UP)

      assert_includes rule_body(css, "nav.rail > ul > li > details"), "position: relative;", name
      [ "position: absolute;", "inset-inline-start: calc(100% + var(--block-space-half));", "inset-block-end: 0;",
        "inset-block-start: auto;", "min-inline-size: max-content;", "background-color: var(--color-bg-lighter);",
        "box-shadow: var(--shadow-2);", "z-index: var(--z-dropdown);" ].each do |declaration|
        assert_includes pop_up, declaration, name
      end
      assert_includes rule_body(css, "nav.rail details > summary::after"), "display: none;", name
    end
  end

  def test_logout_looks_like_the_other_account_links
    each_source(RAIL_CSS) do |name, css|
      link = rule_body(css, ":root:root #{POP_UP} li > a")

      refute_empty link, name
      assert_equal link, rule_body(css, ":root:root #{POP_UP} li > form > button"), name
      assert_includes link, "background-color: transparent;", name
      assert_includes link, "box-shadow: none;", name
      assert_includes rule_body(css, ":root:root #{POP_UP} li > form > button:hover"), "animation: none;", name
    end
  end

  def test_the_hub_column_hides_below_1024px
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(media_blocks(css, NARROW).join, HUB_COLUMN), "display: none;", name
      refute_includes rule_body(wide(css), HUB_COLUMN), "display: none;", name
    end
  end

  def test_the_phone_tab_bar_holds_only_the_hubs
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(phone(css), "nav.rail > search"), "display: none;", name
      assert_includes rule_body(phone(css), "nav.rail > ul > li:has(> details)"), "display: none;", name
    end
  end

  def test_five_hubs_share_the_phone_width
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(phone(css), "nav.rail > ul > li"), "flex: 1 1 0;", name
      assert_includes rule_body(phone(css), "nav.rail > ul > li"), "min-inline-size: 0;", name
      assert_includes rule_body(phone(css), HUB), "font-size: var(--text-xx-small);", name
      assert_includes rule_body(phone(css), EMOJI), "font-size: var(--text-medium);", name
    end
  end

  def test_the_title_bar_hides_its_search_and_account_copies_beside_a_rail
    each_source(RAIL_CSS) do |name, css|
      assert_includes rule_body(wide(css), TITLE_BAR_SEARCH), "display: none;", name
      assert_includes rule_body(wide(css), TITLE_BAR_ACCOUNT), "display: none;", name
    end
  end

  def test_the_title_bar_copies_show_on_a_phone
    each_source(RAIL_CSS) do |name, css|
      rest = css_without(rail_section(css), WIDE)

      refute_includes rest, "main > header nav > search", name
      refute_includes rest, "summary[aria-label]", name
    end
  end

  def test_the_title_bar_copies_hide_only_on_a_page_with_a_rail
    each_source(RAIL_CSS) do |name, css|
      rail_section(css).scan(/^[^{}\n]*main > header nav > (?:search|details)[^{}]*\{/).each do |selector|
        assert_includes selector, RAIL_BODY, name
      end
    end
  end

  def test_every_rail_rule_needs_a_rail
    each_source(RAIL_CSS) do |name, css|
      rail_rules(css).each { |selector| assert_includes selector, "nav.rail", "#{name}: #{selector}" }
    end
  end

  def test_dark_and_eink_themes_border_the_joined_card
    each_source(RAIL_CSS) do |name, css|
      %w[ solunized-dark solunized-black ].each do |theme|
        assert_card_border(wide(css), theme, "#{name} #{theme}", HAIRLINE)
      end
    end
    each_source("4_theme/2_eink.css") do |name, css|
      { "eink-light" => "black", "eink-dark" => "white" }.each do |theme, color|
        assert_card_border(wide(css), theme, "#{name} #{theme}", "border: 1px solid #{color};")
      end
    end
  end

  def test_the_eink_account_menu_has_an_ink_border_and_no_shadow
    each_source("4_theme/2_eink.css") do |name, css|
      { "eink-light" => "black", "eink-dark" => "white" }.each do |theme, color|
        pop_up = rule_body(css, "[data-theme=\"#{theme}\"] #{POP_UP}")

        assert_includes pop_up, "box-shadow: none;", "#{name} #{theme}"
        assert_includes pop_up, "border: 1px solid #{color};", "#{name} #{theme}"
      end
    end
  end

  private

  def wide(css)
    media_blocks(css, WIDE).join
  end

  # The Rail section of +css+: all of 16_rail.css, or its copy in the bundle up to the next section.
  def rail_section(css)
    section = css[/^ \* Rail\n.*?(?=^\/\*\n \* (?!Rail\n)|\z)/m]

    refute_nil section, "no Rail section"
    section
  end

  def phone(css)
    media_blocks(css, PHONE).join
  end

  def css_without(css, query)
    media_blocks(css, query).reduce(css) { |rest, block| rest.sub(block, "") }
  end

  # Every selector list in the Rail section of +css+.
  def rail_rules(css)
    rail_section(css).gsub(%r{/\*.*?\*/}m, "").scan(/([^{};]+)\{(?=[^{}]*\})/).flatten.map(&:strip)
  end

  def assert_card_border(css, theme, message, border)
    body = rule_body(css, "[data-theme=\"#{theme}\"] #{CARD}")

    assert_includes body, "box-shadow: none;", message
    assert_includes body, border, message
  end
end
