require "minitest/autorun"

# Verifies the packaged stylesheet stays in sync with the source theme partial.
class MvpaManifestSyncTest < Minitest::Test
  def test_source_and_manifest_expose_only_solunized_themes
    assert_equal expected_theme_selectors, theme_selectors(source_colors)
    assert_equal expected_theme_selectors, theme_selectors(packaged_manifest)
  end

  private

  def expected_theme_selectors
    [
      '[data-theme="solunized-black"]',
      '[data-theme="solunized-dark"]',
      '[data-theme="solunized-light"]',
      '[data-theme="solunized-white"]'
    ]
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def theme_selectors(contents)
    contents.scan(/\[data-theme="[^"]+"\]/).uniq.sort
  end

  def source_colors
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/0_settings/0_colors.css", __dir__))
  end
end
