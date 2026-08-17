require "minitest/autorun"
require "nokogiri"

# The showcase groups related content under a heading, then wraps each
# subsection in its own <section> or <article> — never a loose <h3>
# sitting directly under the top-level, nav-anchored section.
class DemoSubsectionStructureTest < Minitest::Test
  def test_every_subsection_heading_is_wrapped_in_its_own_section_or_article
    loose_headings = document.css("h3").select do |heading|
      top_level_section?(heading.parent)
    end

    assert_empty loose_headings,
      "these <h3> headings sit directly under a top-level section instead of " \
      "their own nested <section>/<article>: " \
      "#{loose_headings.map(&:text).join(', ')}"
  end

  private

  def top_level_section?(element)
    element.name == "section" && element.key?("id")
  end

  def document
    @document ||= Nokogiri::HTML(demo_html)
  end

  def demo_html
    File.read(File.expand_path("../demo.html", __dir__))
  end
end
