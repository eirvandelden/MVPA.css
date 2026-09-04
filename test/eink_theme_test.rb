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

  def test_buttons_stay_flat_on_the_eink_theme
    assert_match(/\[data-theme="eink-light"\] button,[^{]*\{[^}]*box-shadow:\s*none/m, eink_partial,
      "eink-light buttons keep the library's raised box-shadow, contradicting the theme's flat-surface contract")
    assert_match(/\[data-theme="eink-dark"\] button,[^{]*\{[^}]*box-shadow:\s*none/m, eink_partial,
      "eink-dark buttons keep the library's raised box-shadow, contradicting the theme's flat-surface contract")
  end

  def test_the_page_header_action_link_also_stays_flat_on_the_eink_theme
    # main > header nav a got a shadow alongside real buttons, so it needs
    # the same flat-surface treatment or it breaks the eink theme's contract.
    assert_match(/\[data-theme="eink-light"\] main > header nav a\s*\{[^}]*box-shadow:\s*none/m, eink_partial,
      "eink-light's page header action link keeps its raised box-shadow")
    assert_match(/\[data-theme="eink-dark"\] main > header nav a\s*\{[^}]*box-shadow:\s*none/m, eink_partial,
      "eink-dark's page header action link keeps its raised box-shadow")
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

  def test_the_mobile_header_divider_is_visible_on_the_eink_theme
    mobile_block = header_css[/@media \(max-width: 768px\) \{.*?\n\}/m]
    assert_match(/border-block-start:\s*1px solid var\(--color-border\)/, mobile_block,
      "mobile header divider uses --color-bg-darker, which equals the page background on eink " \
      "and vanishes — should use the semantic --color-border token instead")
  end

  def test_the_eink_header_border_does_not_fight_the_mobile_flush_bar
    assert_match(/@media \(min-width:\s*769px\)\s*\{[^}]*\[data-theme="eink-light"\] body > header\s*\{[^}]*border:\s*1px solid black/m,
      eink_partial,
      "eink-light's header border rule is not confined to desktop widths — at the same specificity as " \
      "header.css's mobile flush override, and loaded later in the bundle, it wins and puts a border back " \
      "on every side of the mobile header bar")
    assert_match(/@media \(min-width:\s*769px\)\s*\{[^}]*\[data-theme="eink-dark"\] body > header\s*\{[^}]*border:\s*1px solid white/m,
      eink_partial,
      "eink-dark's header border rule is not confined to desktop widths — same issue, inverted colours")
  end

  def test_pressing_danger_or_warning_gives_visible_feedback_on_the_eink_theme
    assert_match(/\[data-theme="eink-light"\] \.button-warning:active,\s*\[data-theme="eink-light"\] \.button-danger:active\s*\{[^}]*background-color:\s*white/m,
      eink_partial,
      "pressing a filled danger/warning button on eink-light shows no change — they are already " \
      "black-on-white inverted, so the generic invert-on-press rule sets them to the same colours they already have")
    assert_match(/\[data-theme="eink-dark"\] \.button-warning:active,\s*\[data-theme="eink-dark"\] \.button-danger:active\s*\{[^}]*background-color:\s*black/m,
      eink_partial,
      "pressing a filled danger/warning button on eink-dark shows no change — same issue, inverted direction")
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
