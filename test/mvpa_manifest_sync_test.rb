require "minitest/autorun"

# Verifies the packaged stylesheet stays in sync with the source theme partials.
class MvpaManifestSyncTest < Minitest::Test
  def test_source_and_manifest_declare_the_same_themes
    assert_equal theme_selectors_from_source, theme_selectors(packaged_manifest)
  end

  def test_bundle_defines_every_semantic_colour_mapping_the_source_defines
    assert_equal semantic_mappings(source_colors), semantic_mappings(packaged_manifest)
  end

  private

  def theme_selectors_from_source
    theme_dir = File.expand_path("../app/assets/stylesheets/mvpa/4_theme", __dir__)
    Dir["#{theme_dir}/*.css"].flat_map { |f| theme_selectors(File.read(f)) }.uniq.sort
  end

  def theme_selectors(contents)
    contents.scan(/\[data-theme="[^"]+"\]/).uniq.sort
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def semantic_mappings(contents)
    block = contents[/\/\* Semantic color mappings \*\/\s*:root\s*\{([^}]*)\}/m, 1]
    block.scan(/--color-[\w-]+:[^;]+;/).sort
  end

  def source_colors
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/4_theme/0_colors.css", __dir__))
  end
end
