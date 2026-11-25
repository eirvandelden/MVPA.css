require_relative "helper"

# The generic files are copied to appkit, so they must stay free of this repository's names.
class GenericFilesTest < Minitest::Test
  GENERIC = %w[level version fragment release repository surface_change pull_request snapshot shell semver].freeze

  def test_generic_files_name_no_repository_paths
    GENERIC.each do |name|
      source = File.read(File.expand_path("../../script/semver/#{name}.rb", __dir__))

      %w[mvpa app/ stylesheets importmap CHANGELOG.md].each do |word|
        refute_includes source, word, "#{name}.rb names #{word}"
      end
    end
  end
end
