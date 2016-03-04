require "test/unit"
require_relative "../lib/gf/root.rb"

class TestYagura < Test::Unit::TestCase
  def test_create_yagura_5_persons
    gf = GFLoad::Formation.new(:yagura => 5, :print => :none)
    gf.start
    assert_equal(5, gf.size)
    assert_equal(5, gf.total_weight)
    assert_in_delta(0.5, gf.max_load_weight)
    assert_equal([5, 5, 0.5, 0.5, "2.2", 1, 0.5], gf.summary_a)
  end

  def test_create_yagura_7_persons
    gf = GFLoad::Formation.new(:yagura => 7, :print => :none)
    gf.start
    assert_equal(7, gf.size)
    assert_equal(7, gf.total_weight)
    assert_in_delta(0.5, gf.max_load_weight)
    assert_equal([7, 7, 0.5, 0.5, "2.1", 1, 0.5], gf.summary_a)
  end

  def test_create_yagura_9_persons
    gf = GFLoad::Formation.new(:yagura => 9, :print => :none)
    gf.start
    assert_equal(9, gf.size)
    assert_equal(9, gf.total_weight)
    assert_in_delta(0.7425, gf.max_load_weight)
    w = gf.max_load_weight
    assert_equal([9, 9, w, w, "1.2.1", 1, w], gf.summary_a)
  end

  def test_create_yagura_21_persons
    gf = GFLoad::Formation.new(:yagura => 21, :print => :none)
    gf.start
    assert_equal(21, gf.size)
    assert_equal(21, gf.total_weight)
    assert_in_delta(0.9908, gf.max_load_weight)
    w = gf.max_load_weight
    assert_equal([21, 21, w, w, "1.2.2", 1, w], gf.summary_a)
  end
end
