require "minitest/autorun"
require_relative "css_source_helper"

# A <dialog> is a centred box over a dimmed page. Its action row puts Cancel
# then the red Delete on the right, and stacks on a phone.
class DialogTest < Minitest::Test
  include CssSourceHelper

  DIALOG = "2_modules/12_dialog.css".freeze
  ANIMATIONS = "0_base/3_animations.css".freeze

  def test_a_dialog_is_a_padded_rounded_box_capped_in_rem
    each_source(DIALOG) do |name, css|
      rule = rule_body(css, "dialog")

      assert_includes rule, "inline-size: min(32rem, 100% - 2rem);", name
      assert_includes rule, "max-inline-size: none;", name
      assert_includes rule, "padding: var(--block-space-double);", name
      assert_includes rule, "border-radius: var(--radius-large);", name
    end
  end

  def test_the_dialog_surface_has_a_border_and_shadow
    each_source(DIALOG) do |name, css|
      rule = rule_body(css, "dialog")

      assert_includes rule, "border: 1px solid var(--color-border);", name
      assert_includes rule, "background-color: var(--color-bg-lighter);", name
      assert_includes rule, "color: var(--color-fg);", name
      assert_includes rule, "box-shadow: var(--shadow-3);", name
    end
  end

  def test_the_dialog_backdrop_dims_the_page
    each_source(DIALOG) do |name, css|
      assert_includes rule_body(css, "dialog::backdrop"), "background-color: oklch(0% 0 0 / 0.45);", name
    end
  end

  def test_the_dialog_backdrop_uses_a_literal_colour
    each_source(DIALOG) do |name, css|
      refute_includes rule_body(css, "dialog::backdrop"), "var(", name
    end
  end

  def test_a_dialog_footer_is_a_right_aligned_row
    each_source(DIALOG) do |name, css|
      rule = rule_body(css, "dialog > footer")

      assert_includes rule, "display: flex;", name
      assert_includes rule, "justify-content: flex-end;", name
      assert_includes rule, "max-inline-size: none;", name
      assert_includes rule, "border: none;", name
      assert_includes rule_body(css, "dialog > footer button"), "margin: 0;", name
    end
  end

  def test_dialog_buttons_stack_cancel_first_on_a_phone
    each_source(DIALOG) do |name, css|
      phone = css[css.index("dialog::backdrop")..][/@media \(max-width: 768px\) \{.*?\n\}\n/m]
      rule = rule_body(phone, "dialog > footer")

      assert_includes rule, "flex-direction: column;", name
      assert_includes rule, "align-items: stretch;", name
      assert_includes rule_body(phone, "dialog form > footer"), "flex-direction: column;", name
      assert_includes rule_body(phone, "dialog > footer > *"), "inline-size: 100%;", name
      assert_includes rule_body(phone, "dialog > footer button"), "inline-size: 100%;", name
    end
  end

  def test_a_dialog_never_exceeds_the_viewport_width
    each_source(DIALOG) do |name, css|
      assert_includes rule_body(css, "dialog"), "min(32rem, 100% - 2rem)", name
    end
  end

  def test_the_dialog_animation_only_runs_without_a_reduced_motion_preference
    each_source(ANIMATIONS) do |name, css|
      motion_start = css.index("@media (prefers-reduced-motion: no-preference)")
      motion = css[motion_start...css.index("@media (prefers-reduced-motion: reduce)")]

      assert_includes motion, "@keyframes dialog-enter", name
      assert_includes motion, "@keyframes backdrop-fade-in", name
      assert_includes rule_body(motion, "dialog[open]"), "animation: dialog-enter", name
      assert_includes rule_body(motion, "dialog[open]::backdrop"), "animation: backdrop-fade-in", name
    end
  end
end
