require "minitest/autorun"

# Verifies the page-transition feature (direction-aware slide) is present
# in both the source partials/JS and the packaged mvpa.css manifest, and
# locks in two specific bugs found during design validation so they can't
# silently come back:
#   1. must use event.activation.from/.entry.url, never location.href
#   2. must use a data-attribute, never :active-view-transition-type()
class PageTransitionsTest < Minitest::Test
  def test_direction_script_exists_and_is_pinned
    assert_includes page_transitions_js, "window.addEventListener(\"pageswap\""
    assert_includes page_transitions_js, "sessionStorage.setItem(\"mvpaTransitionDirection\""
    assert_includes importmap_rb, "mvpa/page_transitions"
  end

  def test_direction_script_uses_activation_urls_not_location
    assert_includes page_transitions_js, "event.activation.from.url"
    assert_includes page_transitions_js, "event.activation.entry.url"
    assert_equal false, page_transitions_js.include?("location.href")
  end

  def test_direction_script_scoped_to_sidebar_nav_only
    assert_includes page_transitions_js, "body > header nav a[href]"
  end

  def test_readme_documents_the_required_inline_snippet
    assert_includes readme, "data-transition-direction"
    assert_includes readme, "mvpaTransitionDirection"
    assert_includes readme, 'import "mvpa/page_transitions"'
  end

  def test_mobile_axis_swap_present
    mobile_block = turbo_transitions_css[/@media \(max-width: 768px\) \{.*?\n  \}\n\}/m]
    assert mobile_block, "expected to find a max-width: 768px media query inside the transitions file"
    assert_includes mobile_block, "@keyframes mvpa-slide-out-down"
    assert_includes mobile_block, "translate: 100vw 0;"
    assert_includes mobile_block, "translate: -100vw 0;"
  end

  def test_direction_scoped_overrides_present
    assert_includes turbo_transitions_css, 'html[data-transition-direction="forward"] ::view-transition-old(main-content) {'
    assert_includes turbo_transitions_css, 'html[data-transition-direction="forward"] ::view-transition-new(main-content) {'
    assert_includes turbo_transitions_css, 'html[data-transition-direction="backward"] ::view-transition-old(main-content) {'
    assert_includes turbo_transitions_css, 'html[data-transition-direction="backward"] ::view-transition-new(main-content) {'
    assert_includes packaged_manifest, 'html[data-transition-direction="backward"] ::view-transition-new(main-content) {'
  end

  def test_does_not_use_the_confirmed_non_functional_mechanism
    assert_equal false, turbo_transitions_css.include?(":active-view-transition-type")
    assert_equal false, turbo_transitions_css.include?("viewTransition.types")
  end

  def test_main_named_and_baseline_slide_present
    assert_includes turbo_transitions_css, "view-transition-name: main-content;"
    assert_includes turbo_transitions_css, "::view-transition-old(main-content) {"
    assert_includes turbo_transitions_css, "::view-transition-new(main-content) {"
    assert_includes turbo_transitions_css, "animation-name: mvpa-slide-out-down;"
    assert_includes turbo_transitions_css, "animation-name: mvpa-slide-in-down;"
    assert_includes packaged_manifest, "view-transition-name: main-content;"
  end

  private

  def page_transitions_js
    File.read(File.expand_path("../app/javascript/mvpa/page_transitions.js", __dir__))
  end

  def importmap_rb
    File.read(File.expand_path("../config/importmap.rb", __dir__))
  end

  def turbo_transitions_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/11_turbo-transitions.css", __dir__))
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def readme
    File.read(File.expand_path("../README.md", __dir__))
  end
end
