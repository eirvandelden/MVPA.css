require "minitest/autorun"

# The packaged mvpa.css must contain everything the source partials define.
# 5_buttons.css had drifted: three whole rules existed only in source.
class ButtonVariantsBundleSyncTest < Minitest::Test
  def test_the_touch_target_rule_is_packaged
    assert_includes bundle, "button,\ninput[type=\"submit\"],\ninput[type=\"button\"],\ninput[type=\"reset\"],\na[role=\"button\"] {\n  min-block-size: 2.75rem;\n}"
  end

  def test_the_destructive_button_to_rule_is_packaged
    assert_includes bundle, "form:has(input[name=\"_method\"][value=\"delete\"]) button {\n  --button-bg: var(--color-danger);\n  --button-fg: var(--color-bg-lightest);\n}"
  end

  private

  def bundle
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
