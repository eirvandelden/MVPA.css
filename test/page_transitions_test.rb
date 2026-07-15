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

  private

  def page_transitions_js
    File.read(File.expand_path("../app/javascript/mvpa/page_transitions.js", __dir__))
  end

  def importmap_rb
    File.read(File.expand_path("../config/importmap.rb", __dir__))
  end
end
