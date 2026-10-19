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

  STEPS = { "narrow" => "30rem", "medium" => "45rem", "wide" => "60rem" }.freeze
  STACKED = "thead, tbody, tfoot, tr, th, td".freeze

  def test_data_stack_narrow_medium_and_wide_stack_below_30_45_and_60_rem
    each_source(TABLES) do |name, css|
      STEPS.each do |step, width|
        block = container_block(css, width)

        assert_includes block, %(table[data-stack="#{step}"]), "#{name} #{step}"
        (STEPS.keys - [ step ]).each do |other|
          refute_includes block, %(data-stack="#{other}"), "#{name} #{step} holds #{other}"
        end
      end
    end
  end

  def test_a_stacked_table_and_its_parts_are_blocks
    each_source(TABLES) do |name, css|
      STEPS.each do |step, width|
        rule = rule_body(container_block(css, width), %(table[data-stack="#{step}"] :is(#{STACKED})))

        assert_includes rule, "display: block;", "#{name} #{step}"
      end
    end
  end

  def test_stacked_header_is_clipped_not_display_none
    each_source(TABLES) do |name, css|
      STEPS.each do |step, width|
        block = container_block(css, width)
        rule = rule_body(block, %(table[data-stack="#{step}"] thead))

        assert_includes rule, "clip-path: inset(50%);", "#{name} #{step}"
        assert_includes rule, "position: absolute;", "#{name} #{step}"
        refute_includes block, "display: none", "#{name} #{step}"
      end
    end
  end

  def test_stacked_cell_label_is_decorative_attr_data_label
    each_source(TABLES) do |name, css|
      STEPS.each do |step, width|
        rule = rule_body(container_block(css, width), %(table[data-stack="#{step}"] td::before))

        assert_includes rule, %(content: attr(data-label) / "";), "#{name} #{step}"
      end
    end
  end

  def test_the_label_is_not_shown_above_the_breakpoint
    each_source(TABLES) do |name, css|
      outside = css.gsub(/@container.*?\n\}\n/m, "")

      refute_includes outside, "attr(data-label)", name
    end
  end

  def test_table_css_never_declares_a_container
    refute_includes partial(TABLES), "container-type"
  end

  private

  # The body of the @container rule that opens at +width+, up to its closing brace.
  def container_block(css, width)
    css[/@container \(width < #{width}\) \{\n.*?\n\}\n/m].to_s
  end
end
