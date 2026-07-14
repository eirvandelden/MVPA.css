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

  def test_sidebar_floats_with_gutter_and_no_internal_scrollbar
    assert_includes header_css, "padding: var(--shell-gutter);"
    assert_includes header_css, "column-gap: var(--shell-gutter);"
    assert_includes header_css, "min-block-size: calc(100dvh - 2 * var(--shell-gutter));"
    assert_includes header_css, "overflow-y: visible;"
    assert_equal false, header_css.include?("overflow-y: auto;")
    assert_includes packaged_manifest, "min-block-size: calc(100dvh - 2 * var(--shell-gutter));"
  end

  def test_sidebar_uses_border_not_shadow_on_dark_themes
    assert_includes header_css, "[data-theme=\"solunized-dark\"] body > header,"
    assert_includes header_css, "border: 1px solid color-mix(in oklch, var(--color-fg) 14%, transparent);"
  end

  def test_article_has_elevation_shadow
    assert_includes article_css, "box-shadow: 0 1px 3px oklch(0% 0 0 / 0.06);"
    assert_includes packaged_manifest, "box-shadow: 0 1px 3px oklch(0% 0 0 / 0.06);"
  end

  def test_sidebar_links_do_not_get_generic_underline_wiggle
    assert_includes animations_css, "a:not([class]):not(body > header nav a) {"
    assert_equal false, animations_css.include?("a:not([class]) {\n")
    assert_includes packaged_manifest, "a:not([class]):not(body > header nav a) {"
  end

  private

  def variables_css
    read("0_base/0_variables.css")
  end

  def colors_css
    read("4_theme/0_colors.css")
  end

  def header_css
    read("1_layout/0_header.css")
  end

  def article_css
    read("2_modules/8_article.css")
  end

  def animations_css
    read("0_base/3_animations.css")
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def read(relative_path)
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/#{relative_path}", __dir__))
  end
end
