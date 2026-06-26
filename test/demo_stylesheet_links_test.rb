require "minitest/autorun"

# Verifies the standalone demo links to existing stylesheet partials.
class DemoStylesheetLinksTest < Minitest::Test
  def test_demo_stylesheet_links_exist
    stylesheet_links.each do |href|
      assert File.file?(File.expand_path("../#{href}", __dir__)), "#{href} does not exist"
    end
  end

  private

  def demo_html
    File.read(File.expand_path("../demo.html", __dir__))
  end

  def stylesheet_links
    demo_html.scan(/<link rel="stylesheet" href="([^"]+\.css)">/).flatten
  end
end
