require "test/unit"
require_relative "../lib/gf/root.rb"

class TestYagura < Test::Unit::TestCase
  def test_create_yagura_5_persons
    gf = GFLoad::Formation.new(:yagura => 5)
    gf.start
    assert_equal(5, gf.size)
    assert_equal(5, gf.total_weight)
    assert_equal(0.5, gf.max_load_weight)
  end
end
