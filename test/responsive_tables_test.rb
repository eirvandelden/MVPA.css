require "minitest/autorun"
require_relative "css_source_helper"

# Tables fit their container: width rules for every table, and opt-in stacking
# through data-stack below a container width.
class ResponsiveTablesTest < Minitest::Test
  include CssSourceHelper

  TABLES = "2_modules/0_tables.css".freeze
  MAIN = "1_layout/1_main.css".freeze

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

  def test_main_is_an_inline_size_container
    each_source(MAIN) do |name, css|
      assert_includes rule_body(css, "main"), "container-type: inline-size;", name
    end
  end

  def test_main_may_shrink_below_its_content
    each_source(MAIN) do |name, css|
      assert_includes rule_body(css, "main"), "min-inline-size: 0;", name
    end
  end

  def test_table_css_never_declares_a_container
    refute_includes partial(TABLES), "container-type"
  end
end
