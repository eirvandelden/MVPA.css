require "minitest/autorun"
require_relative "css_source_helper"

# A <details> inside the page header's nav is a pull-down menu: a plain header
# button that opens a surface under it. The sidebar's own details stay untouched.
class DetailsMenuTest < Minitest::Test
  include CssSourceHelper

  DETAILS = "2_modules/2_details.css".freeze
  NAVIGATION = "2_modules/10_navigation.css".freeze
  MENU = "main > header nav details".freeze
  # :root:root (0,2,0) outranks every theme rule for buttons and header links, including :root:not([data-theme]).
  ITEM = ":root:root main > header nav details > ul li > a".freeze
  ITEM_BUTTON = ":root:root main > header nav details > ul li > form > button".freeze
  SUMMARY = "main > header nav details > summary".freeze
  THEMES = %w[solunized-dark solunized-black eink-light eink-dark].freeze

  def test_header_menu_summary_is_a_plain_button_with_a_decorative_arrow
    each_source(DETAILS) do |name, css|
      summary = rule_body(css, "#{MENU} > summary")

      assert_includes summary, "background-color: var(--color-bg-lighter);", name
      assert_includes summary, "border: 1px solid var(--color-border);", name
      assert_includes summary, "min-block-size: var(--touch-target);", name
      assert_includes rule_body(css, "#{MENU} > summary::after"), %(content: "▾" / "";), name
    end
  end

  def test_the_arrow_keeps_a_plain_content_fallback_before_the_alternative_text
    each_source(DETAILS) do |name, css|
      arrow = rule_body(css, "#{MENU} > summary::after")
      plain = arrow.index(%(content: "▾";))

      refute_nil plain, "#{name} has no plain content declaration"
      assert_operator plain, :<, arrow.index(%(content: "▾" / "";)), name
    end
  end

  def test_the_arrow_does_not_rotate_when_the_menu_is_open
    each_source(DETAILS) do |name, css|
      assert_includes rule_body(css, "#{MENU}[open] > summary::after"), "transform: none;", name
    end
  end

  def test_open_header_menu_is_positioned_under_its_summary
    each_source(DETAILS) do |name, css|
      assert_includes rule_body(css, MENU), "position: relative;", name

      list = rule_body(css, "#{MENU} > ul")

      assert_includes list, "position: absolute;", name
      assert_includes list, "inset-block-start: 100%;", name
      assert_includes list, "inset-inline-end: 0;", name
      # The phone rule for "header nav details > ul" pins the list to the bottom and left edges.
      assert_includes list, "inset-block-end: auto;", name
      assert_includes list, "inset-inline-start: auto;", name
      assert_includes list, "z-index: var(--z-dropdown);", name
    end
  end

  # The phone rule for "header nav" scrolls sideways, which would clip an open menu.
  def test_a_header_nav_with_a_menu_does_not_clip_it
    each_source(DETAILS) do |name, css|
      assert_includes rule_body(css, "main > header nav:has(> details)"), "overflow: visible;", name
    end
  end

  def test_each_menu_item_fills_the_width_of_the_menu
    each_source(DETAILS) do |name, css|
      assert_includes rule_body(css, ITEM), "inline-size: 100%;", name
      assert_includes rule_body(css, ITEM_BUTTON), "inline-size: 100%;", name
    end
  end

  def test_menu_items_carry_no_margins_of_their_own
    each_source(DETAILS) do |name, css|
      assert_includes rule_body(css, "main > header nav details > ul li"), "margin: 0;", name
      assert_includes rule_body(css, ITEM_BUTTON), "margin: 0;", name
    end
  end

  def test_menu_items_stay_plain_under_every_theme
    each_source(DETAILS) do |name, css|
      [ ITEM, ITEM_BUTTON ].each do |item|
        body = rule_body(css, item)

        assert_includes body, "border: none;", name
        assert_includes body, "background-color: transparent;", name
        assert_includes body, "box-shadow: none;", name
      end
    end
  end

  def test_menu_item_hover_outranks_theme_hover_rules
    each_source(DETAILS) do |name, css|
      assert_includes rule_body(css, "#{ITEM}:hover"), "background-color: var(--color-bg-darker);", name
    end
  end

  def test_the_summary_drops_its_shadow_where_the_header_buttons_do
    each_source(DETAILS) do |name, css|
      selectors = THEMES.map { |theme| %([data-theme="#{theme}"] #{SUMMARY}) }

      selectors.each { |selector| assert_includes rule_body(css, selector), "box-shadow: none;", "#{name} #{selector}" }
      twin = ":root:not\\(\\[data-theme\\]\\) #{Regexp.escape(SUMMARY)}"
      system_dark = css[/@media \(prefers-color-scheme: dark\) \{\n.*?#{twin}.*?\n\}\n/m]

      assert_includes system_dark.to_s, "box-shadow: none;", name
    end
  end

  def test_sidebar_details_are_not_styled_as_a_menu
    refute_includes partial(DETAILS), "body > header"
    refute_includes rule_body(partial(DETAILS), "details"), "position:"
    without_badge_corner = partial(NAVIGATION).sub(/header nav > ul > li > a > data \{.*?\}/m, "")

    refute_includes without_badge_corner, "position: absolute", "the sidebar menu was changed"
  end

  def test_every_menu_rule_is_scoped_to_the_page_header
    lines = partial(DETAILS).lines.grep(/\A[^\s\/*@}].*[,{]\s*\z/)
    selectors = lines.map { |line| line.strip.chomp("{").chomp(",").strip }
    menu, base = selectors.partition { |selector| selector.include?("main > header nav") }

    assert_equal %w[details summary summary:hover], base
    assert_operator menu.size, :>, 5
  end
end
