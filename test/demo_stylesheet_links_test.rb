require "minitest/autorun"

# Verifies the standalone demo links to existing stylesheet partials.
class DemoStylesheetLinksTest < Minitest::Test
  def test_demo_stylesheet_links_exist
    stylesheet_links.each do |href|
      assert File.file?(File.expand_path("../#{href}", __dir__)), "#{href} does not exist"
    end
  end

  def test_demo_stylesheet_count_matches_links
    assert_includes demo_html, "#{stylesheet_links.count} files organized in SMACSS structure"
    assert_includes demo_html, "Import all #{stylesheet_links.count} CSS files in the correct order"
  end

  private

  def stylesheet_links
    demo_html.scan(/<link rel="stylesheet" href="([^"]+\.css)">/).flatten
  end

  def demo_html
    File.read(File.expand_path("../demo.html", __dir__))
  end
end
