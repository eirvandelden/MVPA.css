require "minitest/autorun"
require_relative "css_source_helper"

# A link styled as a button feels like a button: it brightens on hover, scales
# down on press and never underlines. The two such links are the page-action
# link in `main > header nav` and `a[role="button"]`.
class LinkButtonHoverTest < Minitest::Test
  include CssSourceHelper

  PAGE_ACTION_LINK = "main > header nav a".freeze
  LINK_BUTTON = 'a[role="button"]'.freeze
  # Zero specificity, so a variant such as .button-danger:active wins on a link as it does on a button.
  LINKS = ":where(#{LINK_BUTTON}, #{PAGE_ACTION_LINK})".freeze

  # One rule serves both links, so one test covers a page-action link and an a[role="button"] link.
  def test_a_hovered_link_button_or_page_action_link_brightens_and_never_underlines
    assert_brightens_without_underline("#{LINKS}:hover")
  end

  def test_a_pressed_page_action_link_scales_down
    each_source("2_modules/1_forms.css") do |name, css|
      assert_match(/scale\(var\(--animation-scale-press\)\)/, rule_body(css, "#{LINKS}:active"),
        "#{name}: pressing a page-action link does not scale it down")
    end
  end

  def test_a_page_action_link_animates_its_hover
    each_source("2_modules/5_buttons.css") do |name, css|
      assert_match(/transition:[^;]*filter/, rule_body(css, PAGE_ACTION_LINK),
        "#{name}: the page-action link has no filter transition, so the hover jumps")
    end
  end

  def test_eink_themes_keep_page_action_links_flat_on_hover_and_press
    each_source("4_theme/2_eink.css") do |name, css|
      %w[eink-light eink-dark].each do |theme|
        %w[hover active].each do |state|
          selector = "[data-theme=\"#{theme}\"] #{PAGE_ACTION_LINK}:#{state}"

          assert_match(/filter:\s*none/, rule_body(css, selector),
            "#{name}: #{theme} page-action link filters on #{state}")
        end
      end
    end
  end

  def test_the_hover_wiggle_underline_skips_page_action_links_and_link_buttons
    each_source("0_base/3_animations.css") do |name, css|
      selectors = css.scan(/^\s*(a:not\(\[class\]\):not\(.*?)\s*\{/).flatten

      assert_equal 3, selectors.size, "#{name}: expected the wiggle underline's three selectors"
      selectors.each do |selector|
        assert_includes selector, PAGE_ACTION_LINK, "#{name}: the wiggle underline still draws under a page-action link"
        assert_includes selector, LINK_BUTTON, "#{name}: the wiggle underline still draws under a link button"
      end
    end
  end

  private

  def assert_brightens_without_underline(selector)
    each_source("2_modules/1_forms.css") do |name, css|
      body = rule_body(css, selector)

      assert_match(/filter:\s*brightness\(1\.\d+\)/, body, "#{name}: #{selector} does not brighten")
      assert_match(/text-decoration:\s*none/, body, "#{name}: #{selector} can underline")
    end
  end
end
