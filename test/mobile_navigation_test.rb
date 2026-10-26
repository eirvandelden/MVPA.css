require "minitest/autorun"
require_relative "css_source_helper"

# Locks in the mobile app shell so the navigation remains visible on long pages.
class MobileNavigationTest < Minitest::Test
  include CssSourceHelper

  def test_source_keeps_mobile_navigation_fixed_at_the_viewport_bottom
    assert_fixed_mobile_navigation(source_header)
  end

  def test_packaged_manifest_keeps_mobile_navigation_fixed_at_the_viewport_bottom
    assert_fixed_mobile_navigation(packaged_manifest)
  end

  def test_a_tab_bar_badge_sits_in_the_item_corner
    [ File.read(File.expand_path("../app/assets/stylesheets/mvpa/2_modules/10_navigation.css", __dir__)),
      packaged_manifest ].each do |css|
      block = mobile_media_blocks(css).find { |media| media.include?("header nav > ul > li > a > data") }

      refute_nil block
      assert_includes block, "header nav > ul > li > a {\n    position: relative;"
      assert_match(/header nav > ul > li > a > data \{[^}]*position: absolute;[^}]*inset-inline-end: 0.25rem;/m, block)
    end
  end

  private

  def assert_fixed_mobile_navigation(stylesheet)
    assert_predicate mobile_body_blocks(stylesheet), :any?
    assert_predicate mobile_header_blocks(stylesheet), :any?

    mobile_body_blocks(stylesheet).each do |block|
      assert_includes block, "padding-block-end: var(--nav-height-mobile);"
    end

    mobile_header_blocks(stylesheet).each do |block|
      assert_includes block, "position: fixed;"
      assert_includes block, "inset-block-end: 0;"
      assert_includes block, "block-size: var(--nav-height-mobile);"
      assert_includes block, "z-index: var(--z-sticky);"
    end
  end

  def mobile_body_blocks(stylesheet)
    mobile_media_blocks(stylesheet).flat_map { |block| block.scan(/^[ \t]*body \{.*?^[ \t]*\}/m) }
  end

  def mobile_media_blocks(stylesheet)
    stylesheet.to_enum(:scan, /@media \(max-width: 768px\) \{/).map do
      media_query = Regexp.last_match
      balanced_block(stylesheet, media_query.begin(0))
    end
  end

  def mobile_header_blocks(stylesheet)
    mobile_media_blocks(stylesheet).flat_map { |block| block.scan(/^[ \t]*body > header(?:,| \{).*?^[ \t]*\}/m) }
  end

  def source_header
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/1_layout/0_header.css", __dir__))
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
