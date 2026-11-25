require_relative "helper"

class RulesTest < Minitest::Test
  def test_ids_name_the_five_rules
    assert_equal %w[token file class data_attribute importmap_pin], Semver::Rules.ids
  end
end
