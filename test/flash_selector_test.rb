require "minitest/autorun"

# Verifies flash styles stay scoped to aside-based flash markup.
class FlashSelectorTest < Minitest::Test
  def test_flash_styles_target_aside_roles
    assert_includes flash_css, 'section[aria-label="Notifications"]'
    assert_includes flash_css, 'aside[role="status"]'
    assert_includes flash_css, 'aside[role="alert"]'
    assert_includes flash_css, "display: grid"
    assert_includes flash_css, "margin-block-end: 0"
    assert_includes flash_css, "border: 0"
    assert_equal false, flash_css.include?("[role=\"status\"],\n[role=\"alert\"]")
    assert_equal false, animation_css.include?("[role=\"alert\"],\n  [role=\"status\"]")
  end

  def test_demo_stacks_flash_examples_in_notifications_container
    notifications = demo_html[/<section aria-label="Notifications">.*?<\/section>/m]

    assert notifications, "demo should wrap fixed flashes in a notifications container"
    assert_operator notifications.scan(/<aside role="(?:status|alert)">/).size, :>=, 2
    assert_equal false, demo_html.include?('<section role="status">')
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
