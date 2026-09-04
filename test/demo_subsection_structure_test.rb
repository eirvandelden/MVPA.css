require "minitest/autorun"
require "nokogiri"

# Every category the navigation links to reads as its own card, and within
# that card, related content is grouped into plain sections — never a loose
# <h3> sitting directly under the card.
class DemoSubsectionStructureTest < Minitest::Test
  def test_every_linked_category_is_wrapped_in_an_article
    non_article_targets = nav_anchor_ids.reject { |id| document.at_css("article##{id}") }

    assert_empty non_article_targets,
      "these navigation targets are not wrapped in an <article>: #{non_article_targets.join(', ')}"
  end

  def test_every_subsection_heading_is_wrapped_in_its_own_section
    loose_headings = document.css("h3").select do |heading|
      top_level_category?(heading.parent)
    end

    assert_empty loose_headings,
      "these <h3> headings sit directly under a top-level category instead of " \
      "their own nested <section>: " \
      "#{loose_headings.map(&:text).join(', ')}"
  end

  private

  def nav_anchor_ids
    document.css('nav[data-controller="nav"] a[href^="#"]').map { |a| a["href"].delete_prefix("#") }
  end

  def document
    @document ||= Nokogiri::HTML(demo_html)
  end

  def demo_html
    File.read(File.expand_path("../demo.html", __dir__))
  end

  def top_level_category?(element)
    element.name == "article" && element.key?("id")
  end
end
