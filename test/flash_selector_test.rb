require "minitest/autorun"

# Verifies flash styles stay scoped to aside-based flash markup.
class FlashSelectorTest < Minitest::Test
  def test_flash_styles_target_aside_roles
    assert_includes flash_css, 'aside[role="status"]'
    assert_includes flash_css, 'aside[role="alert"]'
    assert_equal false, flash_css.include?("[role=\"status\"],\n[role=\"alert\"]")
    assert_equal false, animation_css.include?("[role=\"alert\"],\n  [role=\"status\"]")
  end

  def test_demo_uses_aside_for_status_flashes
    assert_equal false, demo_html.include?('<section role="status">')
    assert_operator demo_html.scan('<aside role="status">').size, :>=, 2
  end

  private

  def demo_html
    File.read(File.expand_path("../demo.html", __dir__))
  end

  def flash_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/3_flash.css", __dir__))
  end

  def animation_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/0_base/3_animations.css", __dir__))
  end
end
