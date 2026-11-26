require_relative "helper"

class LevelTest < Minitest::Test
  def test_parse_names_the_three_levels
    assert_equal %w[patch minor major], %w[patch minor major].map { |name| Semver::Level.parse(name).to_s }
  end

  def test_parse_refuses_an_unknown_name
    assert_raises(Semver::Fragment::Invalid) { Semver::Level.parse("huge") }
  end

  def test_levels_order_patch_below_minor_below_major
    levels = %w[major patch minor].map { |name| Semver::Level.parse(name) }

    assert_equal %w[patch minor major], levels.sort.map(&:to_s)
    assert_predicate Semver::Level.parse("major"), :major?
  end
end
