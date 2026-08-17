require "minitest/autorun"

# A table row's divider must use the framework's semantic border colour, not
# a background shade that happens to equal the page background it sits on.
class TableRowDividerTest < Minitest::Test
  def test_the_row_divider_uses_the_semantic_border_colour
    assert_includes tables_css, "border-block-end: 1px solid var(--color-border)",
      "the row divider does not use --color-border"
  end

  private

  def tables_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/0_tables.css", __dir__))
  end
end
