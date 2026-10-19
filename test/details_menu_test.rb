require "minitest/autorun"
require_relative "css_source_helper"

# A <details> inside the page header's nav is a pull-down menu: a plain header
# button that opens a surface under it. The sidebar's own details stay untouched.
class DetailsMenuTest < Minitest::Test
  include CssSourceHelper

  DETAILS = "2_modules/2_details.css".freeze
  NAVIGATION = "2_modules/10_navigation.css".freeze
  MENU = "main > header nav details".freeze
  ITEM = "main > header nav details > ul li > a".freeze
  ITEM_BUTTON = "main > header nav details > ul li > form > button".freeze

  def test_header_menu_summary_is_a_plain_button_with_a_decorative_arrow
    each_source(DETAILS) do |name, css|
      summary = rule_body(css, "#{MENU} > summary")

      assert_includes summary, "background-color: var(--color-bg-lighter);", name
      assert_includes summary, "border: 1px solid var(--color-border);", name
      assert_includes summary, "min-block-size: var(--touch-target);", name
      assert_includes rule_body(css, "#{MENU} > summary::after"), %(content: "▾" / "";), name
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

  def test_sidebar_details_are_not_styled_as_a_menu
    refute_includes partial(DETAILS), "body > header"
    refute_includes rule_body(partial(DETAILS), "details"), "position:"
    refute_includes partial(NAVIGATION), "position: absolute", "the sidebar menu was changed"
  end

  def test_every_menu_rule_is_scoped_to_the_page_header
    lines = partial(DETAILS).lines.grep(/\A[^\s\/*@}].*[,{]\s*\z/)
    selectors = lines.map { |line| line.strip.chomp("{").chomp(",").strip }
    menu, base = selectors.partition { |selector| selector.start_with?("main") }

    assert_equal %w[details summary summary:hover], base
    assert_operator menu.size, :>, 5
  end
end
