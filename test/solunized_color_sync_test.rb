require "minitest/autorun"

# 0_colors.css is generated from the Solunized palette repository and marked
# "do not edit directly". These values must match what that generator
# produces today — a mismatch means the palette drifted out of sync.
class SolunizedColorSyncTest < Minitest::Test
  def test_solunized_dark_foregrounds_match_the_generator
    assert_includes colors_css, "--color-fg-0: oklch(83.58% 0.0348 208.01);"
    assert_includes colors_css, "--color-fg-1: oklch(89.80% 0.0244 212.91);"
  end

  def test_solunized_light_background_and_foregrounds_match_the_generator
    assert_includes colors_css, "--color-bg-0: oklch(98.98% 0.0025 228.78);"
    assert_includes colors_css, "--color-fg-0: oklch(40.13% 0.0362 217.69);"
    assert_includes colors_css, "--color-fg-1: oklch(28.90% 0.0297 229.45);"
  end

  private

  def colors_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/4_theme/0_colors.css", __dir__))
  end
end
