require "test/unit"
require_relative "../lib/gf.rb"

class TestRoot < Test::Unit::TestCase
  def test_hand_foot_case1
    gf = GF::Formation.new(:triangle => 5, :print => :none)
    gf.setup_hand_foot

    assert_in_delta(0.15, gf.default_hand_rate)
    assert_in_delta(0.35, gf.default_foot_rate)
  end

  def test_hand_foot_case2
    gf = GF::Formation.new(:triangle => 5, :print => :none, :hand_foot => "3:7")
    gf.setup_hand_foot

    assert_in_delta(0.15, gf.default_hand_rate)
    assert_in_delta(0.35, gf.default_foot_rate)
  end

  def test_hand_foot_case3
    gf = GF::Formation.new(:triangle => 5, :print => :none, :hand_foot => "5:5")
    gf.setup_hand_foot

    assert_in_delta(0.25, gf.default_hand_rate)
    assert_in_delta(0.25, gf.default_foot_rate)
  end

  def test_hand_foot_case4
    gf = GF::Formation.new(:triangle => 5, :print => :none, :hand_foot => "1:1")
    gf.setup_hand_foot

    assert_in_delta(0.25, gf.default_hand_rate)
    assert_in_delta(0.25, gf.default_foot_rate)
  end

  def test_hand_foot_case5
    gf = GF::Formation.new(:triangle => 5, :print => :none, :hand_foot => "0.3")
    gf.setup_hand_foot

    assert_in_delta(0.15, gf.default_hand_rate)
    assert_in_delta(0.35, gf.default_foot_rate)
  end

  def test_hand_foot_unusual_case
    gf = GF::Formation.new(:triangle => 5, :print => :none, :hand_foot => "0")
    gf.setup_hand_foot

    assert_in_delta(0, gf.default_hand_rate)
    assert_in_delta(0.5, gf.default_foot_rate)

    gf = GF::Formation.new(:triangle => 5, :print => :none, :hand_foot => "1")
    gf.setup_hand_foot

    assert_in_delta(0.5, gf.default_hand_rate)
    assert_in_delta(0, gf.default_foot_rate)
  end
end
