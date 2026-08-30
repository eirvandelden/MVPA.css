require "minitest/autorun"

# Buttons were flat and glued to whatever sat next to them: no shadow to lift
# them off the page, no space around stacked forms, and pressing one gave no
# springy feedback.
class ButtonShadowSpacingSpringTest < Minitest::Test
  def test_a_button_casts_a_shadow
    assert_includes button_rule(forms_css), "box-shadow: var(--shadow-1);"
    assert_includes button_rule(bundle), "box-shadow: var(--shadow-1);"
  end

  def test_a_form_stacked_directly_after_another_form_gets_space_above_it
    assert_includes forms_css, "form + form {\n  margin-block-start: var(--block-space);\n}"
    assert_includes bundle, "form + form {\n  margin-block-start: var(--block-space);\n}"
  end

  def test_a_lone_form_in_a_page_header_gets_no_extra_space
    # form + form only matches when a form follows a form, so a single
    # button_to form sitting in a page header's nav (see 1_layout/0_header.css)
    # is untouched — it can't inherit the destroy-form-must-space-out rule.
    refute_includes forms_css, "form {\n  margin-block-end"
    refute_includes bundle, "form {\n  margin-block-end"
  end

  def test_the_press_transition_carries_only_one_easing_function_per_layer
    # --transition-fast already bundles a duration and an easing function
    # (150ms ease-in-out). Reusing it alongside --animation-spring would
    # stack two easing functions in one layer, which is invalid and makes
    # the browser discard the whole declaration.
    assert_includes button_rule(forms_css), "transition: filter var(--transition-fast), transform 150ms var(--animation-spring);"
    assert_includes button_rule(bundle), "transition: filter var(--transition-fast), transform 150ms var(--animation-spring);"
  end

  def test_pressing_a_button_squashes_it
    assert_includes button_active_rule(forms_css), "transform: scale(0.93);"
    assert_includes button_active_rule(bundle), "transform: scale(0.93);"
  end

  def test_a_mouse_press_still_squashes_a_hovered_button
    # The hover boop keeps its own scale as long as the pointer merely hovers,
    # but a press always also counts as a hover, so the boop must step aside
    # the moment :active starts or the press never shows for mouse users.
    assert_includes animations_css, "button:not(:disabled):hover:not(:active) {"
    assert_includes bundle, "button:not(:disabled):hover:not(:active) {"
  end

  def test_the_page_header_action_link_lifts_like_the_button_beside_it
    # main > header nav pairs a primary action link with a real button (e.g.
    # Show + Destroy). The link is styled to look like a button, so it should
    # carry the same elevation or it reads as flat next to a raised button.
    #
    # Source-only: the packaged mvpa.css is already missing this whole rule
    # on main, independent of this branch — a separate sync gap to fix on
    # its own, not asserted here.
    assert_includes header_nav_link_rule(buttons_css), "box-shadow: var(--shadow-1);"
  end

  private

  def forms_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/1_forms.css", __dir__))
  end

  def bundle
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def animations_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/0_base/3_animations.css", __dir__))
  end

  def buttons_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/5_buttons.css", __dir__))
  end

  def header_nav_link_rule(contents)
    contents[/^main > header nav a \{.*?\n\}/m]
  end

  def button_rule(contents)
    contents[/^button,\ninput\[type="submit"\],\ninput\[type="button"\],\ninput\[type="reset"\] \{.*?\n\}/m]
  end

  def button_active_rule(contents)
    contents[/^button:active,\ninput\[type="submit"\]:active,\ninput\[type="button"\]:active,\ninput\[type="reset"\]:active \{.*?\n\}/m]
  end
end
