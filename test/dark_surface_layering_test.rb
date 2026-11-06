require "minitest/autorun"
require_relative "css_source_helper"
require_relative "color_contrast_helper"

# In every dark rendering a surface (sidebar card, article) is darker than the canvas behind it,
# as in Herdr and Nova, and text, borders, inputs and code stay readable on the new backgrounds.
class DarkSurfaceLayeringTest < Minitest::Test
  include CssSourceHelper
  include ColorContrastHelper

  COLORS = "4_theme/0_colors.css".freeze
  DARK = [ "system dark", "solunized-dark", "solunized-black" ].freeze
  LIGHT_SCALE = [
    "--color-bg: var(--color-bg-1);",
    "--color-bg-lighter: var(--color-bg-0);",
    "--color-bg-lightest: var(--color-bg-0);",
    "--color-bg-darker: var(--color-bg-1);",
    "--color-bg-darkest: var(--color-bg-2);"
  ].freeze

  def test_dark_mappings_put_the_canvas_on_bg_1_and_surfaces_on_bg_0
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        LIGHT_SCALE.each { |line| assert_includes renderings(css)[dark][:mapping], line, "#{name} #{dark}" }
      end
    end
  end

  def test_surfaces_are_darker_than_the_canvas_in_every_dark_rendering
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        rendering = renderings(css)[dark]

        assert_operator resolved(rendering, "bg-lighter").first, :<, resolved(rendering, "bg").first, "#{name} #{dark}"
      end
    end
  end

  def test_body_text_meets_wcag_aa_on_the_canvas_surfaces_inputs_and_code
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        %w[bg bg-lighter bg-lightest bg-darker].each do |background|
          ratio = contrast_between(renderings(css)[dark], "fg", background)

          assert_operator ratio, :>=, 4.5, "#{name} #{dark} fg on #{background}"
        end
      end
    end
  end

  def test_text_on_accent_fills_meets_wcag_aa
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        %w[red green yellow blue].each do |accent|
          ratio = contrast_between(renderings(css)[dark], "bg-lightest", accent)

          assert_operator ratio, :>=, 4.5, "#{name} #{dark} text on #{accent}"
        end
      end
    end
  end

  def test_borders_differ_from_the_canvas_and_surfaces
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        rendering = renderings(css)[dark]
        border = resolved(rendering, "bg-darkest").first

        assert_operator border, :>, resolved(rendering, "bg").first, "#{name} #{dark} canvas"
        assert_operator border, :>, resolved(rendering, "bg-lighter").first, "#{name} #{dark} surface"
      end
    end
  end

  def test_hairlines_show_on_surfaces
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        rendering = renderings(css)[dark]

        refute_equal resolved(rendering, "bg-darker"), resolved(rendering, "bg-lighter"), "#{name} #{dark}"
      end
    end
  end

  def test_the_page_paints_the_canvas_and_the_sidebar_card_and_articles_paint_the_surface
    painters = {
      "0_base/1_reset.css" => [ "body", "background-color: var(--color-bg);" ],
      "1_layout/0_header.css" => [ "body > header", "background-color: var(--color-bg-lighter);" ],
      "2_modules/8_article.css" => [ "article", "background-color: var(--color-bg-lighter);" ]
    }
    painters.each do |path, (selector, declaration)|
      each_source(path) do |name, css|
        assert rule_bodies(css, selector).any? { |body| body.include?(declaration) }, "#{name} #{selector}"
      end
    end

    each_source("1_layout/0_header.css") do |name, css|
      painted = rule_bodies(css, "body > header > nav:only-child").any? do |body|
        body.include?("background-color: var(--color-bg-lighter);")
      end

      assert painted, "#{name} paints the fill"
    end
  end
end
