require "minitest/autorun"
require_relative "css_source_helper"

# Tables fit their container: width rules for every table, and opt-in stacking
# through data-stack below a container width.
class ResponsiveTablesTest < Minitest::Test
  include CssSourceHelper

  TABLES = "2_modules/0_tables.css".freeze

  def test_table_is_never_wider_than_its_container
    each_source(TABLES) do |name, css|
      assert_includes rule_body(css, "table"), "max-inline-size: 100%;", name
    end
  end

  def test_text_cells_break_anywhere
    each_source(TABLES) do |name, css|
      assert_includes rule_body(css, "th"), "overflow-wrap: anywhere;", name
      assert_includes rule_body(css, "td"), "overflow-wrap: anywhere;", name
    end
  end

  def test_time_and_data_in_a_cell_never_wrap
    each_source(TABLES) do |name, css|
      assert_includes rule_body(css, "td :is(time, data)"), "white-space: nowrap;", name
    end
  end

  def test_table_css_never_declares_a_container
    each_source(TABLES) do |name, css|
      refute_includes css, "container-type", name
    end
  end
end
