require "test/unit"
require_relative "../lib/gf.rb"

class TestRoot < Test::Unit::TestCase
  def test_create_triangle
    gf = GF::Formation.new(:triangle => 5, :print => :none)
    gf.start

    assert_equal(15, gf.size)
    assert_equal(15, gf.total_weight)
    assert_in_delta(3.125, gf.max_load_weight)
    assert_equal(%w(1.3), gf.to_h_load.select {|key, value|
                   (value - gf.max_load_weight).abs < 0.001}.keys)
  end

  def test_create_pyramid
    gf = GF::Formation.new(:pyramid => 5, :print => :none)
    gf.start

    assert_equal(22, gf.size)
    assert_equal(22, gf.total_weight)
    assert_in_delta(1.4725, gf.max_load_weight)
    assert_equal(%w(1.2.2 1.2.3), gf.to_h_load.select {|key, value|
                   (value - gf.max_load_weight).abs < 0.001}.keys)
  end
end
