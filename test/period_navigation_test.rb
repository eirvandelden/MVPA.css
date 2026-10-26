require "minitest/autorun"
require_relative "css_source_helper"

# A <nav> outside a <header> that holds a link, a heading and a link is a period navigation.
class PeriodNavigationTest < Minitest::Test
  include CssSourceHelper

  PARTIAL = "2_modules/15_period_navigation.css".freeze
  NAV = "nav:not(header nav):has(> a:first-child + :is(h2, h3, h4, h5, h6) + a:last-child)".freeze
  PHONE = "@media (max-width: 768px) {".freeze

  def test_a_period_navigation_is_a_three_column_bar
    each_source(PARTIAL) do |name, css|
      bar = rule_body(css, NAV)

      assert_includes bar, "display: grid;", name
      assert_includes bar, "grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr);", name
      assert_includes bar, "padding: var(--block-space);", name
      assert_includes bar, "border-radius: var(--radius-small);", name
      assert_includes bar, "background-color: var(--color-bg-lighter);", name
    end
  end

  def test_the_period_label_sits_in_the_centre_column
    each_source(PARTIAL) do |name, css|
      label = rule_body(css, "#{NAV} > :is(h2, h3, h4, h5, h6)")

      assert_includes label, "text-align: center;", name
      assert_includes label, "margin: 0;", name
    end
  end

  def test_the_previous_and_next_links_sit_at_the_ends
    each_source(PARTIAL) do |name, css|
      assert_includes rule_body(css, "#{NAV} > a:first-child"), "justify-self: start;", name
      assert_includes rule_body(css, "#{NAV} > a:last-child"), "justify-self: end;", name
    end
  end

  def test_the_bar_is_tinted_against_the_surface_under_it
    each_source(PARTIAL) do |name, css|
      assert_includes rule_body(css, "article #{NAV}"), "background-color: var(--color-bg);", name
    end
  end

  def test_on_a_phone_the_parts_stack_centred_in_one_column
    each_source(PARTIAL) do |name, css|
      phone = own_rules(css)[own_rules(css).index(PHONE)..]

      assert_includes rule_body(phone, NAV), "grid-template-columns: minmax(0, 1fr);", name
      assert_includes rule_body(phone, NAV), "justify-items: center;", name
      assert_includes rule_body(phone, "#{NAV} > a:first-child"), "justify-self: center;", name
      assert_includes rule_body(phone, "#{NAV} > :is(h2, h3, h4, h5, h6)"), "font-size: var(--text-medium);", name
    end
  end

  def test_a_long_label_wraps_instead_of_scrolling
    each_source(PARTIAL) do |name, css|
      assert_includes rule_body(css, NAV), "overflow-wrap: anywhere;", name
      assert_includes rule_body(css, NAV), "minmax(0, 1fr)", name
    end
  end

  def test_the_recognition_selector_needs_exactly_link_heading_link
    each_source(PARTIAL) do |name, css|
      assert_includes css, ":has(> a:first-child + :is(h2, h3, h4, h5, h6) + a:last-child)", name
      refute_match(/:has\(>\s*(ul|menu)/, css, name)
    end
  end

  def test_no_period_navigation_rule_reaches_a_header_nav
    each_source(PARTIAL) do |name, css|
      selectors = own_rules(css).gsub(%r{/\*.*?\*/}m, "").scan(/([^{};]+)\{/).flatten.map(&:strip)

      selectors.reject { |selector| selector.start_with?("@") }.each do |selector|
        assert_includes selector, ":not(header nav)", "#{name}: #{selector}"
      end
    end
  end

  def test_the_partial_uses_no_class
    refute_match(/\.[a-z]/i, partial(PARTIAL).gsub(%r{/\*.*?\*/}m, "").gsub(/\d+\.\d+/, ""))
  end

  def test_eink_themes_draw_the_bar_as_paper_with_an_ink_border
    each_source("4_theme/2_eink.css") do |name, css|
      light = rule_body(css, %([data-theme="eink-light"] #{NAV}))
      dark = rule_body(css, %([data-theme="eink-dark"] #{NAV}))

      assert_includes light, "background-color: white;", name
      assert_includes light, "border: 1px solid black;", name
      assert_includes dark, "background-color: black;", name
      assert_includes dark, "border: 1px solid white;", name
    end
  end

  private

  # The period navigation rules: the whole partial, or its section of the bundle.
  def own_rules(css)
    css[/ \* Period navigation\n.*?(?=\/\*\n \* Solunized color definitions|\z)/m]
  end
end
