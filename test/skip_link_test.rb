require "minitest/autorun"

# Verifies the skip link stays off-screen until keyboard focus reveals it.
class SkipLinkTest < Minitest::Test
  def test_skip_link_is_off_screen_until_focused
    assert_includes main_css, ".skip-link {"
    assert_includes main_css, "position: absolute"
    assert_includes main_css, ".skip-link:focus {"
  end

  def test_packaged_manifest_stays_in_sync_with_main_partial
    assert_includes packaged_manifest, ".skip-link {"
    assert_includes packaged_manifest, ".skip-link:focus {"
  end

  private

  def main_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/1_layout/1_main.css", __dir__))
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
