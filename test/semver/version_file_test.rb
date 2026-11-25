require_relative "helper"
require_relative "../../lib/mvpa/css/version"

class VersionFileTest < Minitest::Test
  def test_the_gem_version_is_the_plain_version_literal
    source = File.read(File.expand_path("../../lib/mvpa/css/version.rb", __dir__))

    assert_match(/VERSION = "\d+\.\d+\.\d+"/, source)
    assert_equal Semver::Stamp.version_in(source), Mvpa::Css::VERSION
    spec = Gem::Specification.load(File.expand_path("../../mvpa-css.gemspec", __dir__))

    assert_equal Mvpa::Css::VERSION, spec.version.to_s
  end
end
