require "minitest/autorun"

# 0_colors.css is hand-maintained. These values pin the Solunized palette, so a
# mismatch means the palette drifted.
class SolunizedColorSyncTest < Minitest::Test
  def test_solunized_dark_foregrounds_keep_their_values
    assert_includes colors_css, "--color-fg-0: oklch(83.58% 0.0348 208.01);"
    assert_includes colors_css, "--color-fg-1: oklch(89.80% 0.0244 212.91);"
  end

  def test_solunized_light_background_and_foregrounds_keep_their_values
    assert_includes colors_css, "--color-bg-0: oklch(97.35% 0.0261 90.10);"
    assert_includes colors_css, "--color-fg-0: oklch(40.13% 0.0362 217.69);"
    assert_includes colors_css, "--color-fg-1: oklch(28.90% 0.0297 229.45);"
  end

  private

  def colors_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/4_theme/0_colors.css", __dir__))
  end
end
