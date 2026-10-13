require "minitest/autorun"
require_relative "css_source_helper"

# An edit page's action row follows the macOS save sheet: one left-standing
# button apart on the far left, Cancel and Save together on the right.
class ActionRowTest < Minitest::Test
  include CssSourceHelper

  FORMS = "2_modules/1_forms.css".freeze
  FOOTER_CONTROLS = ':is(form, dialog) > footer :is(button, input, a[role="button"])'.freeze
  LEFT_STANDING = "form:not(dialog *) > footer > :first-child:nth-last-child(n + 3)".freeze

  def test_a_form_footer_is_a_right_aligned_row
    each_source(FORMS) do |name, css|
      rule = rule_body(css, "form > footer")

      assert_includes rule, "display: flex;", name
      assert_includes rule, "flex-wrap: wrap;", name
      assert_includes rule, "justify-content: flex-end;", name
      assert_includes rule, "align-items: center;", name
      assert_includes rule, "gap: var(--block-space-half) var(--inline-space);", name
    end
  end

  def test_a_form_footer_resets_the_global_footer_rule
    each_source(FORMS) do |name, css|
      rule = rule_body(css, "form > footer")

      [ "max-inline-size: none;", "margin-inline: 0;", "padding: 0;", "border: none;",
"color: inherit;" ].each do |reset|
        assert_includes rule, reset, "#{name} #{reset}"
      end
    end
  end

  def test_footer_children_lose_their_own_margins
    each_source(FORMS) do |name, css|
      assert_includes rule_body(css, ":is(form, dialog) > footer > *"), "margin: 0;", name
    end
  end

  # input[type="submit"] (f.submit) and a[role="button"] carry (0,1,1) margins that beat "> *".
  def test_submit_inputs_and_role_button_links_in_a_footer_lose_their_margins
    each_source(FORMS) do |name, css|
      assert_includes rule_body(css, FOOTER_CONTROLS), "margin: 0;", name
    end
  end

  def test_the_first_of_three_or_more_footer_buttons_stands_apart_on_the_left
    each_source(FORMS) do |name, css|
      assert_includes rule_body(css, LEFT_STANDING), "margin-inline-end: auto;", name
    end
  end

  def test_the_left_standing_rule_never_applies_inside_a_dialog
    each_source(FORMS) do |name, css|
      assert_includes css, "form:not(dialog *) > footer", name
      refute_includes css, "dialog > footer > :first-child", name
    end
  end

  def test_a_form_footer_stacks_save_first_on_a_phone
    each_source(FORMS) do |name, css|
      phone = css[css.index("/* Action row")..][/@media \(max-width: 768px\) \{.*?\n\}\n/m]
      rule = rule_body(phone, "form > footer")

      assert_includes rule, "flex-direction: column-reverse;", name
      assert_includes rule, "align-items: stretch;", name
      assert_includes rule_body(phone, "form > footer > *"), "inline-size: 100%;", name
      assert_includes rule_body(phone, LEFT_STANDING), "margin-block-start: var(--block-space);", name
      assert_includes rule_body(phone, LEFT_STANDING), "margin-inline-end: 0;", name
    end
  end
end
