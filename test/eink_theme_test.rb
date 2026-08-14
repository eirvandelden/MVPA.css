require "minitest/autorun"

# An e-ink reader uses a slow, grey, paper-like screen with no colour.
# The eink theme must be readable on such a screen without any colour perception.
class EinkThemeTest < Minitest::Test
  def test_an_eink_reader_can_choose_the_eink_theme
    assert_includes eink_partial, '[data-theme="eink"]',
      "eink theme selector missing from source partial"
    assert_includes bundle, '[data-theme="eink"]',
      "eink theme selector missing from packaged bundle"
  end

  def test_the_eink_theme_prints_ink_black_on_paper_white
    assert_includes eink_partial, "--color-bg:", "no background colour override"
    assert_includes eink_partial, "--color-fg:", "no foreground colour override"
    assert_match(/--color-bg[^:]*:\s*(white|oklch\(100%|#fff|#ffffff)/i, eink_partial,
      "background is not paper white")
    assert_match(/--color-fg:\s*(black|oklch\(\s*0%|#000)/i, eink_partial,
      "foreground is not ink black")
  end

  def test_surfaces_and_borders_stay_visible_on_the_eink_theme
    assert_includes eink_partial, "--color-bg-2:", "border colour not overridden"
    assert_includes eink_partial, "--color-bg-darkest:", "darkest bg not overridden"
    assert_match(/--color-bg-2[^:]*:\s*(black|oklch\(\s*0%|#000)/i, eink_partial,
      "border colour is not ink black — borders will vanish on e-ink")
  end

  def test_nothing_moves_on_the_eink_theme
    assert_match(/\[data-theme="eink"\].*animation:\s*none/m, eink_partial,
      "animations not suppressed for eink theme")
    assert_match(/\[data-theme="eink"\].*transition:\s*none/m, eink_partial,
      "transitions not suppressed for eink theme")
    assert_match(/::view-transition-group\(\*\).*animation:\s*none/m, eink_partial,
      "page-slide view transitions not suppressed for eink theme")
  end

  def test_the_eink_theme_has_no_shadows_gradients_or_see_through_fills
    assert_match(/\[data-theme="eink"\][^}]*box-shadow:\s*none/m, eink_partial,
      "box shadows not removed for eink theme")
    refute_match(/linear-gradient|radial-gradient/, eink_partial,
      "gradients still present in eink theme")
    refute_match(/\d+%\s*\)/, eink_partial,
      "semi-transparent fills (oklch with alpha %) still present in eink theme")
  end

  def test_buttons_still_tell_an_eink_reader_how_heavy_the_action_is
    assert_match(/\.button-danger/, eink_partial,
      ".button-danger not targeted in eink theme")
    assert_match(/\.button-warning/, eink_partial,
      ".button-warning not targeted in eink theme")
    assert_match(/\.button-secondary/, eink_partial,
      ".button-secondary not targeted in eink theme")
    assert_match(/button:disabled|:disabled/, eink_partial,
      "disabled state not targeted in eink theme")
  end

  def test_an_invalid_field_still_looks_wrong_on_the_eink_theme
    assert_match(/:invalid[^}]*border(?:-width)?:\s*2px/m, eink_partial,
      "invalid fields do not have 2px border in eink theme — they look the same as valid fields")
  end

  private

  def eink_partial
    @eink_partial ||= File.read(
      File.expand_path("../app/assets/stylesheets/mvpa/4_theme/2_eink.css", __dir__)
    )
  end

  def bundle
    @bundle ||= File.read(
      File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__)
    )
  end
end
