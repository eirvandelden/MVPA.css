require "minitest/autorun"
require "nokogiri"

# demo.html shows the pull-down menu in its real main > header and the stacking tables.
class DemoResponsiveTest < Minitest::Test
  def test_the_demo_title_bar_has_an_actions_menu
    menu = document.at_css("main > header nav > details")

    assert_equal "Actions", menu.at_css("> summary").text.strip
    assert menu.at_css("> ul > li > a")
    assert menu.at_css("> ul > li > form > button")
  end

  def test_the_demo_has_a_nine_column_wide_table_with_labelled_cells
    table = document.at_css('table[data-stack="wide"]')

    assert_equal 9, table.css("thead th").size
    assert table.css("tbody td").all? { |cell| cell["data-label"] }
    assert_equal %w[table rowgroup row columnheader cell], roles(table)
  end

  def test_the_demo_has_a_short_narrow_table
    assert_equal 2, document.at_css('table[data-stack="narrow"]').css("thead th").size
  end

  def test_the_demo_marks_dates_and_amounts_semantically
    table = document.at_css('table[data-stack="wide"]')

    assert table.at_css("td time[datetime]")
    assert table.at_css("td data[value]")
  end

  private

  def document
    @document ||= Nokogiri::HTML(File.read(File.expand_path("../demo.html", __dir__)))
  end

  def roles(table)
    nodes = [ table ] + %w[thead tr th td].map { |selector| table.at_css(selector) }
    nodes.map { |node| node["role"] }
  end
end
