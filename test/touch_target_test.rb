require "minitest/autorun"

# Buttons and navigation links must be at least 44px tall on every theme.
class TouchTargetTest < Minitest::Test
  def test_touch_target_token_exists_in_variables
    assert_includes variables_css, "--touch-target: 44px"
  end

  def test_buttons_use_touch_target_token
    assert_includes forms_css, "min-block-size: var(--touch-target)"
    assert_includes forms_css, "display: inline-flex"
  end

  def test_navigation_links_use_touch_target_token
    assert_includes navigation_css, "min-block-size: var(--touch-target)"
  end

  def test_bundle_includes_touch_target_token
    assert_includes bundle, "--touch-target: 44px"
  end

  def test_bundle_applies_touch_target_to_buttons
    assert_includes bundle, "min-block-size: var(--touch-target)"
  end

  private

  def variables_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/0_base/0_variables.css", __dir__))
  end

  def forms_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/1_forms.css", __dir__))
  end

  def navigation_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/10_navigation.css", __dir__))
  end

  def bundle
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
