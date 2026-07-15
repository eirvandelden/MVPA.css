require "minitest/autorun"
require "open3"

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

  def test_direction_script_handles_turbo_visits_before_rendering
    assert_includes page_transitions_js, 'document.addEventListener("turbo:before-visit"'
    assert_includes page_transitions_js, "event.detail.url"
    assert_includes page_transitions_js, "document.URL"
    assert_includes page_transitions_js, 'document.documentElement.setAttribute("data-transition-direction", direction);'
  end

  def test_turbo_directions_do_not_persist_for_later_native_page_loads
    assert_includes page_transitions_js, "const recordDirection = (fromUrl, toUrl, { persist = false } = {}) => {"
    assert_includes page_transitions_js, 'if (persist) sessionStorage.setItem("mvpaTransitionDirection", direction);'
    assert_includes page_transitions_js,
      "recordDirection(event.activation.from.url, event.activation.entry.url, { persist: true });"
    assert_includes page_transitions_js, "recordDirection(document.URL, event.detail.url);"
  end

  def test_direction_script_guards_missing_activation
    assert_includes page_transitions_js, "if (!event.activation) return;"
  end

  def test_direction_script_scoped_to_sidebar_nav_only
    assert_includes page_transitions_js, "body > header nav a[href]"
  end

  def test_non_sidebar_visits_clear_stale_transition_direction
    script = <<~JAVASCRIPT
      const fs = require("fs");
      const vm = require("vm");

      const attributes = {};
      const documentElement = {
        setAttribute(name, value) { attributes[name] = value; },
        getAttribute(name) { return attributes[name]; },
        removeAttribute(name) { delete attributes[name]; }
      };
      const storage = {};
      const sessionStorage = {
        getItem(name) { return storage[name] ?? null; },
        setItem(name, value) { storage[name] = value; },
        removeItem(name) { delete storage[name]; }
      };
      const listeners = {};
      const links = ["dashboard", "reports", "settings"].map((path) => ({
        href: `https://example.test/${path}`
      }));
      const document = {
        URL: "https://example.test/dashboard",
        documentElement,
        addEventListener(name, listener) { listeners[name] = listener; },
        querySelectorAll() { return links; }
      };
      const window = { addEventListener(name, listener) { listeners[name] = listener; } };

      vm.runInNewContext(
        fs.readFileSync("app/javascript/mvpa/page_transitions.js", "utf8"),
        { document, window, sessionStorage }
      );

      listeners["turbo:before-visit"]({ detail: { url: "https://example.test/reports" } });
      document.URL = "https://example.test/reports";
      listeners["turbo:before-visit"]({ detail: { url: "https://example.test/help" } });
      if (documentElement.getAttribute("data-transition-direction") !== undefined) {
        throw new Error("Turbo visit retained a stale transition direction");
      }

      documentElement.setAttribute("data-transition-direction", "backward");
      sessionStorage.setItem("mvpaTransitionDirection", "backward");
      listeners.pageswap({
        viewTransition: {},
        activation: {
          from: { url: "https://example.test/reports" },
          entry: { url: "https://example.test/help" }
        }
      });
      if (documentElement.getAttribute("data-transition-direction") !== undefined) {
        throw new Error("Persisted visit retained a stale transition direction");
      }
      if (sessionStorage.getItem("mvpaTransitionDirection") !== null) {
        throw new Error("Persisted visit retained a stale transition direction in storage");
      }
    JAVASCRIPT

    _output, error, status = Open3.capture3("node", "-e", script)

    assert status.success?, error
  end

  def test_readme_documents_the_required_inline_snippet
    assert_includes readme, "data-transition-direction"
    assert_includes readme, "mvpaTransitionDirection"
    assert_includes readme, 'import "mvpa/page_transitions"'
    assert_includes readme, '<meta name="view-transition" content="same-origin">'
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

  def test_header_transition_name_is_scoped_to_the_shell_header
    assert_includes turbo_transitions_css, "body > header {\n      view-transition-name: header;"
    assert_includes packaged_manifest, "body > header {\n      view-transition-name: header;"
    assert_equal false, turbo_transitions_css.include?("    header {\n      view-transition-name: header;")
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
