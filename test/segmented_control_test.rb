require "minitest/autorun"
require_relative "css_source_helper"

# A <menu> of links (view switch) or of radios (form choice) renders as joined segments on a track.
class SegmentedControlTest < Minitest::Test
  include CssSourceHelper

  PARTIAL = "2_modules/13_segmented_control.css".freeze
  WIGGLE = "a:not([class]):not(main > header nav a, body > header nav a, a[role=\"button\"], " \
           "menu:has(> li > a):not(:has(> li > :not(a))) > li > a, a:has(data:not([value=\"0\"])))".freeze
  VIEW_SWITCH = "menu:has(> li > a):not(:has(> li > :not(a)))".freeze
  FORM_CHOICE = 'menu:has(> li > label > input[type="radio"]):not(:has(> li > :not(label)))' \
                ':not(:has(> li > label > input:not([type="radio"])))'.freeze
  CURRENT_LINK = "#{VIEW_SWITCH} > li > a:any-link[aria-current]:not([aria-current=\"false\"])".freeze
  CHECKED_LABEL = "#{FORM_CHOICE} > li > label:has(> input[type=\"radio\"]:checked)".freeze
  RADIO = "#{FORM_CHOICE} > li > label > input[type=\"radio\"]".freeze

  def test_a_menu_of_links_is_a_flex_track
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, VIEW_SWITCH)

      assert_includes rule, "display: flex;", name
      assert_includes rule, "background-color: var(--segment-track);", name
      assert_includes rule, "list-style: none;", name
      assert_includes rule, "inline-size: fit-content;", name
    end
  end

  def test_a_menu_of_radios_is_a_track_too
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, FORM_CHOICE)

      assert_includes rule, "display: flex;", name
      assert_includes rule, "background-color: var(--segment-track);", name
    end
  end

  def test_no_rule_styles_a_bare_menu
    rules(partial(PARTIAL)).each do |selector, body|
      next unless selector.include?("menu") && body.lines.any? { |line| line =~ /^\s*[a-z]/ && line !~ /^\s*--/ }

      selector.split(/,\s*(?=\S)/).each { |entry| assert_includes entry, "menu:has(", entry }
    end
  end

  def test_a_mixed_menu_is_not_a_segmented_control
    each_source(PARTIAL) do |name, css|
      assert_includes css, ":not(:has(> li > :not(a)))", name
      assert_includes css, ":not(:has(> li > :not(label)))", name
      assert_includes css, ':not(:has(> li > label > input:not([type="radio"])))', name
    end
  end

  def test_segment_items_carry_no_margins
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, "#{VIEW_SWITCH} > li")

      assert_includes rule, "margin: 0;", name
      assert_includes rule, "display: flex;", name
    end
  end

  def test_a_segment_face_is_plain_by_default
    each_source(PARTIAL) do |name, css|
      [ "#{VIEW_SWITCH} > li > a:any-link", "#{FORM_CHOICE} > li > label" ].each do |face|
        rule = rule_body(css, face)

        assert_includes rule, "background-color: transparent;", name
        assert_includes rule, "color: var(--segment-fg);", name
        assert_includes rule, "text-decoration: none;", name
        assert_includes rule, "min-block-size: var(--touch-target);", name
      end
    end
  end

  def test_a_segment_link_outranks_visited_and_hover_link_colours
    each_source(PARTIAL) do |name, css|
      hover = rule_body(css, "#{VIEW_SWITCH} > li > a:any-link:hover")

      assert_includes hover, "color: var(--segment-fg);", name
      assert_includes hover, "transform: none;", name
    end
  end

  def test_the_current_link_is_the_raised_segment
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, CURRENT_LINK)

      assert_includes rule, "background-color: var(--segment-selected-bg);", name
      assert_includes rule, "box-shadow: var(--segment-shadow);", name
      assert_includes rule, "font-weight: 600;", name
    end
  end

  def test_the_checked_radio_label_is_the_raised_segment
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, CHECKED_LABEL)

      assert_includes rule, "background-color: var(--segment-selected-bg);", name
      assert_includes rule, "box-shadow: var(--segment-shadow);", name
    end
  end

  def test_the_raised_segment_is_not_filled
    each_source(PARTIAL) do |name, css|
      [ CURRENT_LINK, CHECKED_LABEL ].each { |selected|
 refute_includes rule_body(css, selected), "--color-primary", name }
    end
  end

  def test_the_radio_dot_is_visually_hidden_but_stays_focusable
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, RADIO)

      assert_includes rule, "opacity: 0;", name
      assert_includes rule, "clip-path: inset(50%);", name
    end

    refute_includes partial(PARTIAL), "display: none"
    refute_includes partial(PARTIAL), "visibility: hidden"
  end

  def test_a_focused_radio_rings_its_segment
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, "#{FORM_CHOICE} > li > label:has(> input[type=\"radio\"]:focus-visible)")

      assert_includes rule, "outline: 2px solid var(--color-primary);", name
    end
  end

  def test_a_disabled_radio_dims_its_segment
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, "#{FORM_CHOICE} > li > label:has(> input[type=\"radio\"]:disabled)")

      assert_includes rule, "color: var(--color-fg-lighter);", name
      assert_includes rule, "cursor: not-allowed;", name
      assert_operator css.index("input[type=\"radio\"]:disabled)"), :>, css.index("input[type=\"radio\"]:checked)"),
name
    end
  end

  def test_a_menu_in_a_fieldset_spans_its_grid
    each_source(PARTIAL) do |name, css|
      rule = rule_body(css, "fieldset > #{FORM_CHOICE}")

      assert_includes rule, "grid-column: 1 / -1;", name
    end
  end

  def test_below_45rem_the_track_stacks_full_width
    each_source(PARTIAL) do |name, css|
      stacked = css.scan(/@container \(width < 45rem\) \{.*?\n\}/m).find { |block| block.include?("menu:has(") }.to_s

      assert_includes stacked, "flex-direction: column;", name
      assert_includes stacked, "inline-size: 100%;", name
      assert_includes stacked, VIEW_SWITCH, name
      assert_includes stacked, FORM_CHOICE, name
    end
  end

  def test_dark_themes_swap_the_shadow_for_a_hairline
    each_source(PARTIAL) do |name, css|
      [ '[data-theme="solunized-dark"] menu', ":root:not([data-theme]) menu" ].each do |selector|
        rule = rule_body(css, selector)

        assert_includes rule, "--segment-shadow: none;", name
        assert_includes rule, "--segment-edge: color-mix(in oklch, var(--color-fg) 14%, transparent);", name
      end
    end
  end

  def test_the_track_never_clips_a_focus_ring
    each_source(PARTIAL) do |name, css|
      refute_includes rule_body(css, VIEW_SWITCH), "overflow", name
    end
  end

  # One look for both kinds: a radio segment that can still be chosen tints on hover like a link segment.
  def test_a_radio_segment_tints_on_hover_like_a_link_segment
    each_source(PARTIAL) do |name, css|
      tint = "background-color: color-mix(in oklch, var(--segment-track), var(--color-bg-lightest) 50%);"
      hover = rule_body(css, "#{FORM_CHOICE} > li > label:has(> input[type=\"radio\"]:enabled:not(:checked)):hover")

      assert_includes hover, tint, name
      assert_includes rule_body(css, "#{VIEW_SWITCH} > li > a:any-link:hover"), tint, name
    end
  end

  def test_segment_links_get_no_wiggle_underline
    each_source("0_base/3_animations.css") do |name, css|
      assert_includes css, "#{WIGGLE} {", name
      assert_includes css, "#{WIGGLE}::after {", name
      assert_includes css, "#{WIGGLE}:hover::after {", name
    end
  end

  # Only a view switch drops the wiggle; a link in a mixed <menu> keeps its plain look, hover included.
  def test_a_link_in_a_mixed_menu_keeps_the_wiggle_underline
    each_source("0_base/3_animations.css") do |name, css|
      refute_includes css, "menu > li > a) {", name
    end
  end

  private

  # [selector, body] of every innermost rule.
  def rules(css)
    css.scan(/([^{}]+)\{([^{}]*)\}/).map { |selector, body| [ selector.gsub(%r{/\*.*?\*/}m, "").strip, body ] }
  end
end
