require "minitest/autorun"
require_relative "css_source_helper"

# An e-ink reader uses a slow, grey, paper-like screen with no colour.
# The eink theme must be readable on such a screen without any colour perception.
class EinkThemeTest < Minitest::Test
  include CssSourceHelper

  # theme selector => [ink, paper]
  EINK_THEMES = {
    '[data-theme="eink-light"]' => %w[black white],
    '[data-theme="eink-dark"]' => %w[white black]
  }.freeze

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
      "submenu arrow no longer rotates when open on eink theme — the blanket transform: none " \
      "wins, so expanded submenus look collapsed"
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
      "submenu arrow no longer rotates when open on the dark eink theme — the blanket " \
      "transform: none wins, so expanded submenus look collapsed"
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

  def test_pressing_a_warning_button_inks_it_on_paper_and_back_on_eink
    EINK_THEMES.each do |theme, (ink, paper)|
      rule = rule_body(eink_partial, "#{theme} button.button-warning:active")

      assert_includes rule, "background-color: #{paper};", "#{theme} pressed warning button shows no change"
      assert_includes rule, "color: #{ink};", theme
    end
  end

  def test_the_default_button_is_ink_filled_on_eink
    EINK_THEMES.each do |theme, (ink, paper)|
      rule = rule_body(eink_partial, "#{theme} button")

      assert_includes rule, "background-color: #{ink};", theme
      assert_includes rule, "color: #{paper};", theme
      assert_includes rule, "border: 1px solid #{ink};", theme
      assert_includes rule_body(eink_partial, "#{theme} a[role=\"button\"]"), "background-color: #{ink};", theme
      assert_empty rule_bodies(eink_partial, "#{theme} input[type=\"button\"]").grep(/background-color: #{ink}/), theme
    end
  end

  def test_a_push_button_is_outlined_on_eink
    EINK_THEMES.each do |theme, (ink, paper)|
      %w[button[type="button"] button[type="reset"] input[type="button"] input[type="reset"]].each do |selector|
        rule = rule_body(eink_partial, "#{theme} #{selector}")

        assert_includes rule, "background-color: #{paper};", "#{theme} #{selector}"
        assert_includes rule, "color: #{ink};", "#{theme} #{selector}"
        assert_includes rule, "border: 1px solid #{ink};", "#{theme} #{selector}"
      end
    end
  end

  def test_the_secondary_button_matches_the_push_button_on_eink
    EINK_THEMES.each_key do |theme|
      assert_equal rule_body(eink_partial, "#{theme} button[type=\"button\"]"),
        rule_body(eink_partial, "#{theme} .button-secondary"), theme
    end
  end

  def test_a_destructive_button_has_a_double_border_on_eink
    EINK_THEMES.each do |theme, (ink, paper)|
      rule = rule_body(eink_partial, "#{theme} button.button-danger")

      assert_includes rule, "background-color: #{paper};", theme
      assert_includes rule, "color: #{ink};", theme
      assert_includes rule, "border: 3px double #{ink};", theme
    end
  end

  def test_a_delete_form_button_has_the_destructive_look_on_eink
    EINK_THEMES.each_key do |theme|
      delete_form = rule_body(eink_partial, "#{theme} :where(form:has(input[name=\"_method\"][value=\"delete\"])) button")

      assert_equal rule_body(eink_partial, "#{theme} button.button-danger"), delete_form, theme
    end
  end

  def test_pressing_a_destructive_button_inks_it_without_a_filter_on_eink
    EINK_THEMES.each do |theme, (ink, paper)|
      rule = rule_body(eink_partial, "#{theme} button.button-danger:active")

      assert_includes rule, "background-color: #{ink};", theme
      assert_includes rule, "color: #{paper};", theme
      assert_includes rule, "filter: none;", theme
    end
  end

  def test_pressing_a_push_button_inks_it_on_eink
    EINK_THEMES.each do |theme, (ink, paper)|
      rule = rule_body(eink_partial, "#{theme} button[type=\"button\"]:active")

      assert_includes rule, "background-color: #{ink};", theme
      assert_includes rule, "color: #{paper};", theme
    end
  end

  def test_a_secondary_link_is_outlined_like_a_push_button_on_eink
    EINK_THEMES.each_key do |theme|
      assert_equal rule_body(eink_partial, "#{theme} button[type=\"button\"]"),
        rule_body(eink_partial, "#{theme} a[role=\"button\"].button-secondary"), theme
    end
  end

  def test_a_danger_link_has_the_destructive_look_on_eink
    EINK_THEMES.each_key do |theme|
      assert_equal rule_body(eink_partial, "#{theme} button.button-danger"),
        rule_body(eink_partial, "#{theme} a[role=\"button\"].button-danger"), theme
    end
  end

  def test_pressing_a_delete_form_button_or_a_danger_link_inks_it_on_eink
    EINK_THEMES.each_key do |theme|
      pressed = rule_body(eink_partial, "#{theme} button.button-danger:active")
      delete_form = "#{theme} :where(form:has(input[name=\"_method\"][value=\"delete\"])) button:active"

      assert_equal pressed, rule_body(eink_partial, delete_form), theme
      assert_equal pressed, rule_body(eink_partial, "#{theme} a[role=\"button\"].button-danger:active"), theme
    end
  end

  def test_pressing_a_secondary_submit_or_link_inks_it_on_eink
    EINK_THEMES.each_key do |theme|
      assert_equal rule_body(eink_partial, "#{theme} button[type=\"button\"]:active"),
        rule_body(eink_partial, "#{theme} :is(button, input, a).button-secondary:active"), theme
    end
  end

  def test_disabled_comes_after_every_other_button_rule_on_eink
    EINK_THEMES.each_key do |theme|
      disabled = eink_partial.index("#{theme} button:disabled,")

      [ "#{theme} button,", "#{theme} button[type=\"button\"]", "#{theme} button.button-warning {",
        "#{theme} button.button-danger," ].each do |earlier|
        assert_operator eink_partial.index(earlier), :<, disabled, "#{theme} #{earlier}"
      end
    end
  end

  def test_the_dialog_opens_without_animation_on_eink
    EINK_THEMES.each_key do |theme|
      assert_includes rule_body(eink_partial, "#{theme} dialog::backdrop"), "animation: none !important;", theme
      assert_includes rule_body(eink_partial, "#{theme} dialog::backdrop"), "background: none;", theme
    end
  end

  def test_the_dialog_is_a_flat_bordered_box_on_eink
    EINK_THEMES.each do |theme, (ink, _paper)|
      rule = rule_body(eink_partial, "#{theme} dialog")

      assert_includes rule, "border: 2px solid #{ink};", theme
      assert_includes rule, "box-shadow: none;", theme
    end
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
