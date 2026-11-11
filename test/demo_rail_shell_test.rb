require "minitest/autorun"
require "nokogiri"

# demo.html shows the rail shell: a rail of hubs, a hub column and a landing page of tiles.
class DemoRailShellTest < Minitest::Test
  HUBS = %w[Introduction Components Content Colors Animations].freeze

  def test_the_demo_shell_is_a_rail_with_a_hub_column
    navs = document.css("body > header > nav")

    assert_equal 2, navs.size
    assert_equal "rail", navs.first["class"]
    assert_nil navs.last["class"]
  end

  def test_the_rail_starts_with_a_search_button
    search = rail.element_children.first

    assert_equal "search", search.name
    assert_equal "Search", search.at_css("button[type=button]")["aria-label"]
  end

  def test_the_rail_has_five_hubs_with_hidden_emoji_and_one_current_hub
    hubs = rail.css("> ul > li > a")

    assert_equal HUBS, hubs.map { |hub| hub.children.last.text.strip }
    assert(hubs.all? { |hub| hub.element_children.first.matches?("span[aria-hidden=true]") })
    assert_equal [ "Introduction" ], rail.css('a[aria-current="true"]').map { |hub| hub.text.strip.split.last }
  end

  def test_the_rail_ends_with_the_account_menu_and_a_log_out_button
    account = rail.css("> ul > li").last.at_css("> details")

    refute_nil account
    assert_equal "Account", account.at_css("> summary").text.strip
    assert_equal [ "Profile", "Preferences", "Admin" ], account.css("ul > li > a").map { |link| link.text.strip }
    assert_equal "Log out", account.at_css("ul > li > form > button").text.strip
  end

  def test_the_hub_column_has_a_heading_and_the_current_page
    assert_equal "MVPA.css", hub_column.at_css("> h2 > a").text.strip
    assert_equal [ "#introduction" ], hub_column.css('a[aria-current="page"]').map { |link| link["href"] }
  end

  def test_the_title_bar_has_a_search
    search = document.at_css("main > header nav > search")

    refute_nil search
    refute_nil search.at_css("button[aria-label]")
  end

  def test_the_demo_landing_page_has_four_tiles_with_text_counts
    tiles = document.css("#landing-page nav > ul > li > a")

    assert_equal 4, tiles.size
    assert_includes tiles.map { |tile| tile.text.strip }, "0 rekeningen nog niet ingedeeld"
    assert_empty document.css("#landing-page nav data")
    assert_equal "#landing-page", hub_column.at_css('a[href="#landing-page"]')["href"]
  end

  def test_the_demo_has_no_landing_tile_example
    refute_includes document.css("h3").map { |heading| heading.text.strip }, "Landing tile"
  end

  def test_the_demo_navigation_example_is_bare_links
    example = document.css("#details section").find { |section| section.at_css("h3")&.text == "Navigation Example" }

    assert_equal %w[a a a a], example.at_css("nav").element_children.map(&:name)
  end

  def test_the_demo_links_the_rail_partial_after_the_period_navigation
    hrefs = document.css("link[rel=stylesheet]").map { |link| link["href"].split("/").last }

    assert_equal %w[15_period_navigation.css 16_rail.css], hrefs[hrefs.index("15_period_navigation.css"), 2]
  end

  private

  def document
    @document ||= Nokogiri::HTML(File.read(File.expand_path("../demo.html", __dir__)))
  end

  def rail
    document.at_css("body > header > nav.rail")
  end

  def hub_column
    document.at_css("body > header > nav.rail + nav")
  end
end
