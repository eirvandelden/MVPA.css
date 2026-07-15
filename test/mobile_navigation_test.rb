require "minitest/autorun"

# Locks in the mobile app shell so the navigation remains visible on long pages.
class MobileNavigationTest < Minitest::Test
  def test_source_keeps_mobile_navigation_fixed_at_the_viewport_bottom
    assert_fixed_mobile_navigation(source_header)
  end

  def test_packaged_manifest_keeps_mobile_navigation_fixed_at_the_viewport_bottom
    assert_fixed_mobile_navigation(packaged_manifest)
  end

  private

  def assert_fixed_mobile_navigation(stylesheet)
    assert mobile_body_blocks(stylesheet).any?
    assert mobile_header_blocks(stylesheet).any?

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

  def mobile_header_blocks(stylesheet)
    mobile_media_blocks(stylesheet).flat_map { |block| block.scan(/^[ \t]*body > header(?:,| \{).*?^[ \t]*\}/m) }
  end

  def mobile_media_blocks(stylesheet)
    stylesheet.to_enum(:scan, /@media \(max-width: 768px\) \{/).map do
      media_query = Regexp.last_match
      balanced_block(stylesheet, media_query.begin(0))
    end
  end

  def balanced_block(stylesheet, start_index)
    depth = 0
    opening_brace = stylesheet.index("{", start_index)

    stylesheet.each_char.with_index do |character, index|
      next if index < opening_brace

      depth += 1 if character == "{"
      depth -= 1 if character == "}"
      return stylesheet[start_index..index] if depth.zero?
    end
  end

  def source_header
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/1_layout/0_header.css", __dir__))
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end
end
