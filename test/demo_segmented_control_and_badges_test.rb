require "minitest/autorun"
require "nokogiri"

# demo.html shows every segmented control and count badge case from the intent.
class DemoSegmentedControlAndBadgesTest < Minitest::Test
  PERIODS = [ "Deze maand", "Vorige maand", "Dit kwartaal", "Dit jaar", "Vorig jaar" ].freeze

  def test_the_demo_period_view_switch_has_five_links_with_deze_maand_current
    links = period_menu.css("li > a")

    assert_equal PERIODS, links.map { |link| link.text.strip }
    assert_equal [ "Deze maand" ], links.select { |link| link["aria-current"] == "page" }.map { |link| link.text.strip }
    assert(links.all? { |link| link["href"] })
  end

  def test_the_segmented_controls_carry_no_script_hooks
    controls = document.css("#segmented-control menu")

    assert_operator controls.size, :>=, 4
    controls.each do |menu|
      assert_empty menu.xpath(".//@*[starts-with(name(), 'data-') or starts-with(name(), 'on')]"), menu.to_html
      assert_empty menu.css("script")
    end
  end

  def test_the_demo_filter_view_switch_has_no_current_link
    menu = document.css("#segmented-control menu").find { |m|
 m.css("li > a").map(&:text).map(&:strip) == [ "Alle", "Zonder categorie" ] }

    refute_nil menu
    assert_empty menu.css("[aria-current]")
  end

  def test_the_demo_role_form_choice_has_beheerder_checked
    radios = role_form.css("fieldset legend + menu input[type=radio]")

    assert_equal %w[Lid Beheerder], radios.map { |radio| radio.parent.text.strip }
    assert_equal [ "beheerder" ], radios.select { |radio| radio["checked"] }.map { |radio| radio["value"] }
    assert_equal [ "Rol" ], role_form.css("legend").map { |legend| legend.text.strip }
  end

  def test_the_demo_role_choice_is_one_named_radio_group_in_a_get_form
    radios = role_form.css("input[type=radio]")

    assert_equal "get", role_form["method"]
    assert_equal [ "role" ], radios.map { |radio| radio["name"] }.uniq
    assert_equal radios.size, radios.map { |radio| radio["value"] }.uniq.size
    assert_equal 1, radios.count { |radio| radio["checked"] }
    assert_operator role_form.css("button").size, :>=, 1
  end

  def test_the_demo_has_a_disabled_beheerder_choice
    disabled = document.css("#segmented-control input[type=radio][disabled]")

    assert_equal [ "Beheerder" ], disabled.map { |radio| radio.parent.text.strip }
    assert_equal [ "locked_role" ], disabled.map { |radio| radio["name"] }
  end

  def test_the_sidebar_shows_badges_including_on_the_current_link
    badges = document.css("body > header nav a > data").to_h { |data|
 [ data.parent.text.gsub(data.text, "").strip, data["value"] ] }

    assert_equal "3", badges["🏠 Introduction"]
    assert_equal "12", badges["📋 Forms"]
    assert_equal "page", document.at_css('body > header nav a[href="#introduction"]')["aria-current"]
  end

  def test_the_demo_has_a_zero_badge
    assert_equal "0", document.at_css('body > header nav a[href="#progress"] > data')["value"]
  end

  def test_the_demo_has_a_four_digit_badge
    assert_equal "1234", document.at_css("#count-badges a > data[value='1234']").text
  end

  def test_the_demo_has_a_landing_tile_link_with_a_badge
    assert_equal "5", document.at_css("#count-badges a > data[value='5']").text
  end

  def test_the_demo_title_bar_heading_is_one_long_word
    assert_equal "Hypotheekrenteaftrekberekening", document.at_css("main > header h1").text.strip
  end

  def test_the_demo_links_the_two_new_partials_after_the_dialog
    hrefs = document.css("link[rel=stylesheet]").map { |link| link["href"].split("/").last }

    assert_equal %w[12_dialog.css 13_segmented_control.css 14_count_badge.css], hrefs[hrefs.index("12_dialog.css"), 3]
  end

  private

  def period_menu
    document.css("#segmented-control menu").find { |menu| menu.css("li > a").map { |a| a.text.strip } == PERIODS }
  end

  def document
    @document ||= Nokogiri::HTML(File.read(File.expand_path("../demo.html", __dir__)))
  end

  def role_form
    document.css("#segmented-control form").find { |form| form.at_css("input[name=role]") }
  end
end
