require "minitest/autorun"

# The packaged mvpa.css must contain everything the source partials define.
# 5_buttons.css had drifted: three whole rules existed only in source.
class ButtonVariantsBundleSyncTest < Minitest::Test
  def test_the_destructive_button_to_rule_is_packaged
    assert_match(
      /form:has\(input\[name="_method"\]\[value="delete"\]\) button\s*\{[^}]*--button-bg:\s*var\(--color-danger\)/m,
      bundle
    )
  end

  private

  def bundle
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
