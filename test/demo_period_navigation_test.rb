require "minitest/autorun"
require "nokogiri"

# demo.html shows a period navigation for a week, a month, a day and a year.
class DemoPeriodNavigationTest < Minitest::Test
  def test_the_demo_shows_a_week_navigation_with_a_today_link
    nav = navigations.find { |candidate| candidate.at_css("> :nth-child(2)").text.include?("Week 43, 2026") }

    refute_nil nav
    assert_equal [ "← Previous week", "Next week →" ], nav.xpath("./a").map { |link| link.text.strip }
    assert_nil nav["class"]
  end

  def test_the_demo_shows_month_day_and_year_navigations_with_the_same_markup
    labels = navigations.map { |nav| nav.at_css("> :nth-child(2)").text.strip.sub(/ Today\z/, "") }

    [ "October 2026", "26 Oct 2026", "2026" ].each { |label| assert_includes labels, label }
  end

  def test_the_today_link_sits_inside_the_period_label
    today = navigations.flat_map { |nav| nav.css("> :nth-child(2) > a") }

    assert_equal [ "Today" ], today.map { |link| link.text.strip }
  end

  def test_the_demo_links_the_period_navigation_partial_right_after_the_count_badge
    hrefs = document.css("link[rel=stylesheet]").map { |link| link["href"].split("/").last }

    assert_equal %w[14_count_badge.css 15_period_navigation.css], hrefs[hrefs.index("14_count_badge.css"), 2]
  end

  private

  def navigations
    document.css("nav").select do |nav|
      next false if nav.ancestors("header").any?

      kids = nav.element_children
      kids.map(&:name).values_at(0, 2) == %w[a a] && kids.size == 3 && kids[1].name.match?(/\Ah[2-6]\z/)
    end
  end

  def document
    @document ||= Nokogiri::HTML(File.read(File.expand_path("../demo.html", __dir__)))
  end
end
