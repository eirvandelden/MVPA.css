require "minitest/autorun"
require_relative "css_source_helper"
require_relative "color_contrast_helper"

# Links read the link pair. The dark Solunized themes map it to the brighter blue and violet,
# which stay readable on the lighter canvas; the light themes keep the primary blue and violet.
class LinkColourTest < Minitest::Test
  include CssSourceHelper
  include ColorContrastHelper

  COLORS = "4_theme/0_colors.css".freeze
  TYPOGRAPHY = "0_base/2_typography.css".freeze
  NAVIGATION = "2_modules/10_navigation.css".freeze
  EINK = "4_theme/2_eink.css".freeze
  DARK = [ "system dark", "solunized-dark", "solunized-black" ].freeze
  DARK_PAIR = [ "--color-link: var(--color-br-blue);", "--color-link-visited: var(--color-br-violet);" ].freeze
  LIGHT_PAIR = [ "--color-link: var(--color-primary);", "--color-link-visited: var(--color-violet);" ].freeze

  def test_links_read_the_link_pair
    each_source(TYPOGRAPHY) do |name, css|
      assert rule_bodies(css, "a").any? { |body| body.include?("color: var(--color-link);") }, "#{name} a"
      assert rule_bodies(css, "a:hover").any? { |body| body.include?("color: var(--color-link);") }, "#{name} a:hover"
      assert rule_bodies(css, "a:visited").any? { |body| body.include?("color: var(--color-link-visited);") },
             "#{name} a:visited"
    end
  end

  def test_dark_mappings_use_br_blue_and_br_violet_for_links
    each_source(COLORS) do |name, css|
      [ "system dark", "solunized-dark" ].each do |dark|
        DARK_PAIR.each { |line| assert_includes renderings(css)[dark][:mapping], line, "#{name} #{dark}" }
      end
    end
  end

  def test_light_mappings_follow_primary_and_violet
    each_source(COLORS) do |name, css|
      [ renderings(css)["system light"][:mapping], theme(css, "solunized-light")[:mapping] ].each do |body|
        LIGHT_PAIR.each { |line| assert_includes body, line, name }
      end

      assert_includes semantic_root(css), "--color-primary: var(--color-blue);", name
    end
  end

  def test_the_system_dark_palette_copies_the_solunized_dark_link_accents
    each_source(COLORS) do |name, css|
      system_dark = renderings(css)["system dark"][:palette]

      %w[br-blue br-violet].each do |token|
        refute_nil declared(system_dark, token), "#{name} #{token}"
        assert_equal declared(theme(css, "solunized-dark")[:palette], token), declared(system_dark, token), name
        assert_equal 1, system_dark.scan("--color-#{token}:").size, "#{name} #{token} declared once"
      end
    end
  end

  def test_the_semantic_root_declares_no_link_token
    each_source(COLORS) do |name, css|
      refute_match(/--color-link/, semantic_root(css), name)
    end
  end

  def test_only_mapping_blocks_declare_the_link_pair
    each_source(COLORS) do |name, css|
      assert_equal 4, css.scan("--color-link:").size, "#{name} --color-link"
      assert_equal 4, css.scan("--color-link-visited:").size, "#{name} --color-link-visited"
    end
    other_partials.each { |path| refute_match(/--color-link(-visited)?:/, File.read(path), path) }
  end

  def test_links_on_the_dark_canvas_reach_4_49
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        rendering = renderings(css)[dark]

        assert_includes rendering[:mapping], "--color-link:", "#{name} #{dark}"

        assert_operator contrast_between(rendering, "link", "bg"), :>=, 4.49, "#{name} #{dark}"
      end
    end
  end

  def test_visited_links_on_the_dark_canvas_reach_4_5
    each_source(COLORS) do |name, css|
      DARK.each do |dark|
        rendering = renderings(css)[dark]

        assert_includes rendering[:mapping], "--color-link-visited:", "#{name} #{dark}"

        assert_operator contrast_between(rendering, "link-visited", "bg"), :>=, 4.5, "#{name} #{dark}"
      end
    end
  end

  def test_the_current_page_link_text_reads_on_the_primary_fill
    each_source(NAVIGATION) do |name, css|
      painted = rule_bodies(css, 'header nav ul li > a[aria-current="page"]').any? do |body|
        body.include?("background-color: var(--color-primary);") && body.include?("color: var(--color-bg-lightest);")
      end

      assert painted, "#{name} paints the fill"
    end
    each_source(COLORS) do |name, css|
      (DARK + [ "system light" ]).each do |rendering|
        assert_operator contrast_between(renderings(css)[rendering], "bg-lightest", "blue"), :>=, 4.5,
                        "#{name} #{rendering}"
      end
    end
  end

  def test_eink_themes_resolve_the_link_pair_to_ink
    css = partial(EINK)

    [ "eink-light", "eink-dark" ].each do |name|
      body = rule_bodies(css, %([data-theme="#{name}"])).find { |candidate| candidate.include?("--color-primary:") }
      inks = %w[primary br-blue violet br-violet].map { |token| declared(body, token) }

      refute_includes inks, nil, name
      assert_equal 1, inks.uniq.size, name
    end
  end

  private

  def semantic_root(css)
    body = rule_bodies(css, ":root").find { |candidate| candidate.include?("--color-primary:") }

    assert body, "no :root body declares --color-primary, so the semantic root was not found"
    body
  end

  def other_partials
    Dir.glob(File.join(STYLE_ROOT, "**/*.css")).reject do |path|
      path.end_with?("/mvpa.css", "/4_theme/0_colors.css")
    end
  end
end
