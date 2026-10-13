require "minitest/autorun"
require_relative "css_source_helper"

# Button weight comes from semantic HTML: a submit is the filled default,
# type="button"/"reset" and header nav links are plain push buttons, and a
# DELETE form's button is red.
class ButtonHierarchyTest < Minitest::Test
  include CssSourceHelper

  DEFAULT_SELECTOR = [
    ":where(button", 'input[type="submit"]', 'input[type="button"]', 'input[type="reset"]', 'a[role="button"])'
  ].join(", ").freeze
  PUSH_SELECTOR = [
    ':where(button[type="button"]', 'button[type="reset"]', 'input[type="button"]', 'input[type="reset"])'
  ].join(", ").freeze

  def test_a_cancel_button_is_a_push_button_beside_a_filled_save
    each_source("2_modules/1_forms.css") do |name, css|
      push = rule_body(css, PUSH_SELECTOR)

      assert_includes push, "--button-bg: var(--color-bg-lighter);", name
      assert_includes push, "--button-fg: var(--color-fg);", name
      assert_includes push, "--button-border-color: var(--color-border);", name
      assert_includes shared_button_rule(css), "border: 1px solid var(--button-border-color);", name
    end
  end

  def test_the_shared_button_rule_reads_bg_fg_and_border_tokens
    each_source("2_modules/1_forms.css") do |name, css|
      rule = shared_button_rule(css)

      assert_includes rule, "background-color: var(--button-bg);", name
      assert_includes rule, "color: var(--button-fg);", name
      refute_includes rule, "--button-bg:", name
    end
  end

  def test_the_default_tokens_have_zero_specificity
    each_source("2_modules/1_forms.css") do |name, css|
      default = rule_body(css, DEFAULT_SELECTOR)

      assert_includes default, "--button-bg: var(--color-primary);", name
      assert_includes default, "--button-fg: var(--color-bg-lightest);", name
      assert_includes default, "--button-border-color: transparent;", name
    end
  end

  def test_the_push_tokens_have_zero_specificity_and_come_after_the_default
    each_source("2_modules/1_forms.css") do |name, css|
      assert_operator css.index(PUSH_SELECTOR), :>, css.index(DEFAULT_SELECTOR), name
    end
  end

  def test_a_reset_button_is_a_push_button
    each_source("2_modules/1_forms.css") do |name, css|
      assert_includes css[/#{Regexp.escape(PUSH_SELECTOR)}/], 'button[type="reset"]', name
      assert_includes PUSH_SELECTOR, 'input[type="reset"]'
    end
  end

  def test_a_submit_without_a_type_stays_filled
    each_source("2_modules/1_forms.css") do |name, css|
      assert_includes css, DEFAULT_SELECTOR, name
      refute_includes PUSH_SELECTOR, 'type="submit"'
      refute_includes PUSH_SELECTOR, "button,"
    end
  end

  def test_a_delete_form_button_is_red_without_a_border
    each_source("2_modules/5_buttons.css") do |name, css|
      rule = rule_body(css, 'form:has(input[name="_method"][value="delete"]) button')

      assert_includes rule, "--button-bg: var(--color-danger);", name
      assert_includes rule, "--button-fg: var(--color-bg-lightest);", name
      assert_includes rule, "--button-border-color: transparent;", name
    end
  end

  def test_a_header_nav_form_button_is_no_longer_forced_red
    each_source("1_layout/0_header.css") do |name, css|
      refute_includes css, "main > header nav form button", name
    end
  end

  def test_a_header_nav_link_is_a_push_button
    each_source("2_modules/5_buttons.css") do |name, css|
      rule = rule_body(css, "main > header nav a")

      assert_includes rule, "background-color: var(--color-bg-lighter);", name
      assert_includes rule, "color: var(--color-fg);", name
      assert_includes rule, "border: 1px solid var(--color-border);", name
    end
  end

  def test_the_header_nav_link_hover_skips_role_button_links
    each_source("2_modules/5_buttons.css") do |name, css|
      rule = rule_body(css, 'main > header nav a:not([role="button"]):hover')

      assert_includes rule, "color: var(--color-fg);", name
    end
  end

  def test_a_role_button_link_stays_filled_even_in_the_header_nav
    each_source("2_modules/5_buttons.css") do |name, css|
      %w[a[role="button"] a[role="button"]:hover a[role="button"]:visited].each do |link|
        assert_includes rule_body(css, "main > header nav #{link}"), "color: var(--button-fg);", "#{name} #{link}"
      end
    end
  end

  def test_button_secondary_uses_the_push_button_tokens
    each_source("2_modules/5_buttons.css") do |name, css|
      rule = rule_body(css, ".button-secondary")

      assert_includes rule, "--button-bg: var(--color-bg-lighter);", name
      assert_includes rule, "--button-fg: var(--color-fg);", name
      assert_includes rule, "--button-border-color: var(--color-border);", name
    end
  end

  def test_a_danger_push_button_is_red_with_light_text
    each_source("2_modules/5_buttons.css") do |name, css|
      rule = rule_body(css, ".button-danger")

      assert_includes rule, "--button-bg: var(--color-danger);", name
      assert_includes rule, "--button-fg: var(--color-bg-lightest);", name
      assert_includes rule, "--button-border-color: transparent;", name
    end
  end

  def test_success_danger_and_warning_set_light_text_and_no_border
    each_source("2_modules/5_buttons.css") do |name, css|
      %w[.button-success .button-danger .button-warning].each do |variant|
        rule = rule_body(css, variant)

        assert_includes rule, "--button-fg: var(--color-bg-lightest);", "#{name} #{variant}"
        assert_includes rule, "--button-border-color: transparent;", "#{name} #{variant}"
      end
    end
  end

  private

  def shared_button_rule(css)
    rule_body(css, "button")
  end
end
