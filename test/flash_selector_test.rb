require "minitest/autorun"

# Verifies flash styles stay scoped to aside-based flash markup.
class FlashSelectorTest < Minitest::Test
  def test_flash_styles_target_aside_roles
    assert_includes flash_css, "[data-mvpa-flashes]"
    assert_includes flash_css, 'aside[role="status"]'
    assert_includes flash_css, 'aside[role="alert"]'
    assert_includes flash_css, "display: grid"
    assert_includes flash_css, "margin-block-end: 0"
    assert_includes flash_css, "border: 0"
  end

  def test_flash_styles_leave_other_status_and_alert_roles_alone
    refute_includes flash_css, 'section[aria-label="Notifications"]'
    refute_includes flash_css, "[role=\"status\"],\n[role=\"alert\"]"
    refute_includes animation_css, "[role=\"alert\"],\n  [role=\"status\"]"
  end

  def test_demo_stacks_flash_examples_in_notifications_container
    notifications = demo_html[/<section aria-label="[^"]+" data-mvpa-flashes>.*?<\/section>/m]

    assert notifications, "demo should wrap fixed flashes in a notifications container"
    assert_operator notifications.scan(/<aside role="(?:status|alert)">/).size, :>=, 2
    refute_includes demo_html, '<section role="status">'
  end

  private

  def flash_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/3_flash.css", __dir__))
  end

  def animation_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/0_base/3_animations.css", __dir__))
  end

  def demo_html
    File.read(File.expand_path("../demo.html", __dir__))
  end
end
