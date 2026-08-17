require "minitest/autorun"

# Pressing a button gives feedback: ordinary buttons darken, but a danger
# button lightens instead, so pressing "delete" never reads the same as
# pressing "save".
class ButtonActiveStateTest < Minitest::Test
  def test_a_pressed_danger_button_lightens_instead_of_darkening
    assert_match(/\.button-danger:active\s*\{[^}]*filter:\s*brightness\(1\.\d+\)/m, buttons_css,
      "pressing a danger button does not lighten it")
    assert_match(/\.button-danger:active\s*\{[^}]*filter:\s*brightness\(1\.\d+\)/m, bundle,
      "the bundle is missing the danger button's lighten-on-press rule")
  end

  private

  def buttons_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/5_buttons.css", __dir__))
  end

  def bundle
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
