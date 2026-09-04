require "minitest/autorun"

# Buttons were flat and glued to whatever sat next to them: no shadow to lift
# them off the page, no space around stacked forms, and pressing one gave no
# springy feedback.
class ButtonShadowSpacingSpringTest < Minitest::Test
  def test_a_button_casts_a_shadow
    assert_includes button_rule(forms_css), "box-shadow: var(--shadow-1);"
    assert_includes button_rule(bundle), "box-shadow: var(--shadow-1);"
  end

  def test_a_button_has_a_default_margin_so_it_never_sits_flush_against_a_neighbor
    assert_includes button_rule(forms_css), "margin-inline-end: var(--inline-space-half);"
    assert_includes button_rule(forms_css), "margin-block-end: var(--block-space-half);"
    assert_includes button_rule(bundle), "margin-inline-end: var(--inline-space-half);"
    assert_includes button_rule(bundle), "margin-block-end: var(--block-space-half);"
  end

  def test_a_form_stacked_directly_after_another_form_gets_space_above_it
    assert_match(/form \+ form\s*\{[^}]*margin-block-start:\s*var\(--block-space\)/m, forms_css)
    assert_match(/form \+ form\s*\{[^}]*margin-block-start:\s*var\(--block-space\)/m, bundle)
  end

  def test_the_press_transition_carries_only_one_easing_function_per_layer
    # --transition-fast already bundles a duration and an easing function
    # (150ms ease-in-out). Reusing it alongside --animation-spring would
    # stack two easing functions in one layer, which is invalid and makes
    # the browser discard the whole declaration. The duration is pulled from
    # its own token instead of a hardcoded 150ms, so retuning it can't
    # silently pull filter and transform out of sync again.
    expected_transition = "transition: filter var(--transition-fast), " \
      "transform var(--transition-duration-fast) var(--animation-spring);"
    assert_includes button_rule(forms_css), expected_transition
    assert_includes button_rule(bundle), expected_transition
  end

  def test_the_press_squash_is_suppressed_for_reduced_motion
    reduce_block = animations_css[/@media \(prefers-reduced-motion: reduce\) \{.*?\n\}/m]
    refute_nil reduce_block, "no reduced-motion block found" # rubocop:disable Rails/RefuteMethods
    assert_includes reduce_block, "transform: none !important;"
  end

  def test_a_mouse_press_still_squashes_a_hovered_button
    # A press always also counts as a hover, so the squash needs !important
    # to win over the hover boop's animation. Plain specificity is not
    # enough: a running CSS animation outranks a normal declaration.
    assert_includes button_active_rule(forms_css), "transform: scale(var(--animation-scale-press)) !important;"
    assert_includes button_active_rule(bundle), "transform: scale(var(--animation-scale-press)) !important;"
  end

  def test_releasing_a_click_does_not_replay_the_hover_boop
    # The hover rule must keep matching continuously through a press (no
    # :not(:active) escape hatch), or the boop animation restarts from 0%
    # the moment the button is released — an effect nobody asked for.
    assert_includes animations_css, "button:not(:disabled):hover {"
    assert_includes bundle, "button:not(:disabled):hover {"
    refute_includes animations_css, ":hover:not(:active)" # rubocop:disable Rails/RefuteMethods
  end

  def test_a_button_gets_a_visible_border_instead_of_an_invisible_shadow_on_dark_themes
    # --shadow-1 is near-black at low opacity, so it disappears against the
    # dark themes' dark canvas. The header solves the same problem by
    # swapping to a hairline border there instead — buttons follow suit.
    dark_button_rule = forms_css[/\[data-theme="solunized-dark"\] button,.*?\n\}/m]
    refute_nil dark_button_rule, "no dark-theme button override found" # rubocop:disable Rails/RefuteMethods
    assert_includes dark_button_rule, "box-shadow: none;"
    assert_includes dark_button_rule, "border: 1px solid color-mix(in oklch, var(--color-fg) 14%, transparent);"
    assert_includes dark_button_rule, "[data-theme=\"solunized-black\"] button,"
  end

  def test_a_button_also_gets_the_border_swap_on_the_default_system_dark_scheme
    # solunized-dark/black are explicit opt-ins via data-theme. Most dark-mode
    # users never set that attribute — they get dark purely from the OS via
    # prefers-color-scheme, which the border swap didn't cover, so most
    # dark-mode users kept the shadow that renders as nothing on a dark canvas.
    system_dark_rule = forms_css[
      /@media \(prefers-color-scheme: dark\) \{\s*:root:not\(\[data-theme\]\) button,.*?\n  \}\n\}/m
    ]
    refute_nil system_dark_rule, "no default-dark-scheme button override found" # rubocop:disable Rails/RefuteMethods
    assert_includes system_dark_rule, "box-shadow: none;"
    assert_includes system_dark_rule, "border: 1px solid color-mix(in oklch, var(--color-fg) 14%, transparent);"
    assert_includes system_dark_rule, ":root:not([data-theme]) main > header nav a"
  end

  def test_the_page_header_action_link_also_gets_the_dark_theme_border_swap
    # main > header nav a got a shadow alongside real buttons, so it needs
    # the same dark-theme treatment or it stays invisible-shadowed while the
    # button beside it correctly shows a hairline border.
    dark_button_rule = forms_css[/\[data-theme="solunized-dark"\] button,.*?\n\}/m]
    assert_includes dark_button_rule, "main > header nav a,"
  end

  def test_a_disabled_button_loses_its_lift_shadow
    # The shadow is the affordance that says "press me". A disabled button
    # dims but still cast the shadow, so it kept looking like you could press it.
    assert_includes button_disabled_rule(forms_css), "box-shadow: none;"
    assert_includes button_disabled_rule(bundle), "box-shadow: none;"
  end

  def test_the_page_header_action_link_lifts_like_the_button_beside_it
    # main > header nav pairs a primary action link with a real button (e.g.
    # Show + Destroy). The link is styled to look like a button, so it should
    # carry the same elevation or it reads as flat next to a raised button.
    assert_includes header_nav_link_rule(buttons_css), "box-shadow: var(--shadow-1);"
    assert_includes header_nav_link_rule(bundle), "box-shadow: var(--shadow-1);"
  end

  def test_the_press_duration_and_scale_are_tokens_not_hardcoded_numbers
    assert_includes variables_css, "--transition-duration-fast: 150ms;"
    assert_includes variables_css, "--transition-fast: var(--transition-duration-fast) ease-in-out;"
    assert_includes variables_css, "--animation-scale-press: 0.93;"
  end

  private

  def variables_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/0_base/0_variables.css", __dir__))
  end

  def forms_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/1_forms.css", __dir__))
  end

  def bundle
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def animations_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/0_base/3_animations.css", __dir__))
  end

  def buttons_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/5_buttons.css", __dir__))
  end

  def header_nav_link_rule(contents)
    contents[/^main > header nav a \{.*?\n\}/m]
  end

  def button_rule(contents)
    contents[
      /^button,\ninput\[type="submit"\],\ninput\[type="button"\],\ninput\[type="reset"\],\na\[role="button"\] \{.*?\n\}/m
    ]
  end

  def button_active_rule(contents)
    contents[
      /^button:active,\ninput\[type="submit"\]:active,\ninput\[type="button"\]:active,\ninput\[type="reset"\]:active \{.*?\n\}/m
    ]
  end

  def button_disabled_rule(contents)
    contents[
      /^button:disabled,\ninput\[type="submit"\]:disabled,\ninput\[type="button"\]:disabled,\ninput\[type="reset"\]:disabled \{.*?\n\}/m
    ]
  end
end
