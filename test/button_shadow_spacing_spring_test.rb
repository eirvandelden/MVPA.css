require "minitest/autorun"

# Buttons were flat and glued to whatever sat next to them: no shadow to lift
# them off the page, no space around stacked forms, and pressing one gave no
# springy feedback.
class ButtonShadowSpacingSpringTest < Minitest::Test
  def test_a_button_casts_a_shadow
    assert_includes button_rule(forms_css), "box-shadow: var(--shadow-1);"
    assert_includes button_rule(bundle), "box-shadow: var(--shadow-1);"
  end

  def test_a_form_keeps_space_from_whatever_follows_it
    assert_includes form_rule(forms_css), "margin-block-end: var(--block-space);"
    assert_includes form_rule(bundle), "margin-block-end: var(--block-space);"
  end

  def test_pressing_a_button_squashes_it_and_springs_back
    assert_includes button_active_rule(forms_css), "transform: scale(0.93);"
    assert_includes button_rule(forms_css), "transform var(--transition-fast) var(--animation-spring)"
    assert_includes button_active_rule(bundle), "transform: scale(0.93);"
    assert_includes button_rule(bundle), "transform var(--transition-fast) var(--animation-spring)"
  end

  private

  def forms_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/1_forms.css", __dir__))
  end

  def bundle
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def form_rule(contents)
    contents[/^form \{.*?\n\}/m]
  end

  def button_rule(contents)
    contents[/^button,\ninput\[type="submit"\],\ninput\[type="button"\],\ninput\[type="reset"\] \{.*?\n\}/m]
  end

  def button_active_rule(contents)
    contents[/^button:active,\ninput\[type="submit"\]:active,\ninput\[type="button"\]:active,\ninput\[type="reset"\]:active \{.*?\n\}/m]
  end
end
