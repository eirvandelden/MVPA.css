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

  def test_sidebar_does_not_grid_stretch_to_match_main_height
    # Regression: without align-self: start, Grid's default stretch makes
    # header (which spans both grid rows) match main's full content height
    # instead of sizing to its own nav content.
    assert_includes header_css, "align-self: start;"
    assert_includes packaged_manifest, "align-self: start;"
  end

  def test_sidebar_uses_border_not_shadow_on_dark_themes
    assert_includes header_css, "[data-theme=\"solunized-dark\"] body > header,"
    assert_includes header_css, "border: 1px solid color-mix(in oklch, var(--color-fg) 14%, transparent);"
  end

  def test_article_has_elevation_shadow
    assert_includes article_css, "box-shadow: 0 1px 3px oklch(0% 0 0 / 0.06);"
    assert_includes packaged_manifest, "box-shadow: 0 1px 3px oklch(0% 0 0 / 0.06);"
  end

  def test_article_uses_large_radius_in_packaged_manifest
    assert_includes article_rule(article_css), "border-radius: var(--radius-large);"
    assert_includes article_rule(packaged_manifest), "border-radius: var(--radius-large);"
  end

  def test_desktop_main_removes_top_padding_in_packaged_manifest
    assert_includes desktop_main_rule(main_css), "padding-block-start: 0;"
    assert_includes desktop_main_rule(packaged_manifest), "padding-block-start: 0;"
  end

  def test_sidebar_links_do_not_get_generic_underline_wiggle
    assert_includes animations_css, "a:not([class]):not(body > header nav a) {"
    assert_equal false, animations_css.include?("a:not([class]) {\n")
    assert_includes packaged_manifest, "a:not([class]):not(body > header nav a) {"
  end

  def test_sidebar_links_get_hover_lift
    assert_includes navigation_css, "transform: scale(var(--animation-scale-small)) translateY(-2px);"
    assert_includes navigation_css, "box-shadow: 0 3px 8px oklch(0% 0 0 / 0.14);"
    assert_includes navigation_css, "transform 150ms ease-out, box-shadow 150ms ease-out"
    assert_includes packaged_manifest, "transform: scale(var(--animation-scale-small)) translateY(-2px);"
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

  def main_css
    read("1_layout/1_main.css")
  end

  def article_rule(contents)
    contents[/article \{.*?\n\}/m]
  end

  def desktop_main_rule(contents)
    contents[/@media \(min-width: 769px\) \{\n  main \{.*?\n  \}\n\}/m]
  end

  def article_css
    read("2_modules/8_article.css")
  end

  def animations_css
    read("0_base/3_animations.css")
  end

  def navigation_css
    read("2_modules/10_navigation.css")
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def read(relative_path)
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/#{relative_path}", __dir__))
  end
end
