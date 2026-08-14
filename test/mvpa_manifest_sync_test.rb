require "minitest/autorun"

# Verifies the packaged stylesheet stays in sync with the source theme partials.
class MvpaManifestSyncTest < Minitest::Test
  def test_source_and_manifest_declare_the_same_themes
    assert_equal theme_selectors_from_source, theme_selectors(packaged_manifest)
  end

  private

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def theme_selectors(contents)
    contents.scan(/\[data-theme="[^"]+"\]/).uniq.sort
  end

  def theme_selectors_from_source
    theme_dir = File.expand_path("../app/assets/stylesheets/mvpa/4_theme", __dir__)
    Dir["#{theme_dir}/*.css"].flat_map { |f| theme_selectors(File.read(f)) }.uniq.sort
  end
end
