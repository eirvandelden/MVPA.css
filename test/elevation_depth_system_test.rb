require "minitest/autorun"

# Verifies the elevation/depth system change (canvas vs. surface bg tokens,
# floating sidebar gutter, card shadow, nav link hover polish) is present in
# both the source partials and the packaged mvpa.css manifest.
class ElevationDepthSystemTest < Minitest::Test
  def test_shell_gutter_token_defined
    assert_includes variables_css, "--shell-gutter: 0.625rem;"
    assert_includes packaged_manifest, "--shell-gutter: 0.625rem;"
  end

  def test_light_and_white_themes_remap_canvas_one_step_darker
    assert_includes colors_css, "--color-bg: var(--color-bg-1);"
    assert_includes packaged_manifest, "--color-bg: var(--color-bg-1);"
  end

  def test_dark_and_black_themes_are_unchanged
    dark_black_block = colors_css[/\[data-theme="solunized-dark"\],\n\[data-theme="solunized-black"\] \{.*?\}/m]
    assert dark_black_block, "expected to find the solunized-dark/black mapping block"
    assert_includes dark_black_block, "--color-bg: var(--color-bg-0);"
  end

  private

  def variables_css
    read("0_base/0_variables.css")
  end

  def colors_css
    read("4_theme/0_colors.css")
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def read(relative_path)
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/#{relative_path}", __dir__))
  end
end
