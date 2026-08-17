require "minitest/autorun"

# An e-ink reader uses a slow, grey, paper-like screen with no colour.
# The eink theme must be readable on such a screen without any colour perception.
class EinkThemeTest < Minitest::Test
  def test_an_eink_reader_can_choose_the_eink_theme
    assert_includes eink_partial, '[data-theme="eink-light"]',
      "eink-light theme selector missing from source partial"
    assert_includes bundle, '[data-theme="eink-light"]',
      "eink-light theme selector missing from packaged bundle"
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
    assert_match(/\[data-theme="eink-light"\].*animation:\s*none/m, eink_partial,
      "animations not suppressed for eink theme")
    assert_match(/\[data-theme="eink-light"\].*transition:\s*none/m, eink_partial,
      "transitions not suppressed for eink theme")
    assert_match(/::view-transition-group\(\*\).*animation:\s*none/m, eink_partial,
      "page-slide view transitions not suppressed for eink theme")
  end

  def test_hover_states_do_not_shift_position_on_the_eink_theme
    assert_match(/\[data-theme="eink-light"\][^{]*\{[^}]*transform:\s*none/m, eink_partial,
      "hover transforms (scale/translate) still shift buttons and nav links on eink theme")
  end

  def test_the_submenu_arrow_still_shows_open_state_on_the_eink_theme
    assert_match(
      /\[data-theme="eink-light"\] header nav details\[open\] > summary::after[^}]*transform:\s*rotate\(90deg\)\s*!important/m,
      eink_partial,
      "submenu arrow no longer rotates when open on eink theme — the blanket transform: none wins, so expanded submenus look collapsed"
    )
  end

  def test_the_eink_theme_has_no_shadows_gradients_or_see_through_fills
    assert_match(/\[data-theme="eink-light"\][^}]*box-shadow:\s*none/m, eink_partial,
      "box shadows not removed for eink theme")
    refute_match(/linear-gradient|radial-gradient/, eink_partial, # rubocop:disable Rails/RefuteMethods
      "gradients still present in eink theme")
    refute_match(/\d+%\s*\)/, eink_partial, # rubocop:disable Rails/RefuteMethods
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

  def test_an_eink_reader_can_choose_a_dark_eink_theme
    assert_includes eink_partial, '[data-theme="eink-dark"]',
      "eink-dark theme selector missing from source partial"
    assert_includes bundle, '[data-theme="eink-dark"]',
      "eink-dark theme selector missing from packaged bundle"
  end

  def test_the_dark_eink_theme_is_the_light_theme_inverted
    dark_block = eink_partial[/\[data-theme="eink-dark"\]\s*\{[^}]*\}/m]
    refute_nil dark_block, "no [data-theme=\"eink-dark\"] rule block found" # rubocop:disable Rails/RefuteMethods
    assert_match(/--color-bg-0:\s*black/, dark_block,
      "dark eink surface is not ink black")
    assert_match(/--color-fg:\s*white/, dark_block,
      "dark eink text is not paper white")
    assert_match(/--color-bg-2:\s*white/, dark_block,
      "dark eink border is not paper white — borders would vanish on a black canvas")
  end

  def test_nothing_moves_on_the_dark_eink_theme_either
    assert_match(/\[data-theme="eink-dark"\].*animation:\s*none/m, eink_partial,
      "animations not suppressed for the dark eink theme")
    assert_match(/\[data-theme="eink-dark"\].*transition:\s*none/m, eink_partial,
      "transitions not suppressed for the dark eink theme")
  end

  def test_hover_states_do_not_shift_position_on_the_dark_eink_theme_either
    assert_match(/\[data-theme="eink-dark"\][^{]*\{[^}]*transform:\s*none/m, eink_partial,
      "hover transforms (scale/translate) still shift buttons and nav links on the dark eink theme")
  end

  def test_the_submenu_arrow_still_shows_open_state_on_the_dark_eink_theme
    assert_match(
      /\[data-theme="eink-dark"\] header nav details\[open\] > summary::after[^}]*transform:\s*rotate\(90deg\)\s*!important/m,
      eink_partial,
      "submenu arrow no longer rotates when open on the dark eink theme — the blanket transform: none wins, so expanded submenus look collapsed"
    )
  end

  def test_the_mobile_header_stays_flush_on_the_eink_theme
    mobile_block = header_css[/@media \(max-width: 768px\) \{.*?\n\}/m]
    assert_match(/^\s*\[data-theme="eink-light"\] body > header,/, mobile_block,
      "eink-light header keeps its all-round border on mobile — the flush edge-to-edge bar breaks")
    assert_match(/^\s*\[data-theme="eink-dark"\] body > header/, mobile_block,
      "eink-dark header keeps its all-round border on mobile — the flush edge-to-edge bar breaks")
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

  def header_css
    @header_css ||= File.read(
      File.expand_path("../app/assets/stylesheets/mvpa/1_layout/0_header.css", __dir__)
    )
  end
end
