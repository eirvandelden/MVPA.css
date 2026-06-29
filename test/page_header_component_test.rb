require "minitest/autorun"

# Verifies page header component styles are shipped from source and manifest.
class PageHeaderComponentTest < Minitest::Test
  def test_page_header_component_styles_are_packaged
    assert_includes header_css, "main > header"
    assert_includes header_css, "justify-content: space-between"
    assert_includes header_css, "main > header nav form button"

    assert_includes packaged_manifest, "main > header"
    assert_includes packaged_manifest, "justify-content: space-between"
    assert_includes packaged_manifest, "main > header nav form button"
  end

  private

  def header_css
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/1_layout/0_header.css", __dir__))
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
