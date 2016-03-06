require "test/unit"
require_relative "../lib/gf/root.rb"

class TestTrigonal2 < Test::Unit::TestCase
  def test_create_pyramid_level5
    gf = GF::Formation.new(:pyramid => 5, :plc => 0, :print => :none)
    gf.start
    assert_equal([22, 22, 1.4725, 1.4725, "1.2.3", 1, 1.4725], gf.summary_a)
  end

  def test_create_pyramids_level7
    gf0 = GF::Formation.new(:pyramid => 7, :plc => 0, :print => :none)
    gf0.start
    gf4 = GF::Formation.new(:pyramid => 7, :plc => 4, :print => :none)
    gf4.start
    summary_a = [55, 55.0, 2.406125, 2.406125, "1.3.3", 1.0, 2.406125]
    assert_equal(summary_a, gf0.summary_a)
    assert_not_equal(summary_a, gf4.summary_a)
    assert_equal(gf0.summary_a[0], gf4.summary_a[0])
    assert(gf0.summary_a[3] > gf4.summary_a[3])
  end

  def test_calc_loads
    person_a = [0,
       0,  0,  0,  13,  22,
      37, 55, 81, 111, 151,
      196]
    max_load_a = [0,
      0,    0,    0,    1.05, 1.47,
      1.72, 2.40, 2.80, 3.08, 3.85,
      4.20]

    4.upto(11) do |level|
      gf = GF::Formation.new(:pyramid => level, :plc => 0, :print => :none)
      gf.start
      assert_equal(person_a[level], gf.summary[:person])
      assert_in_delta(max_load_a[level], gf.summary[:person_max_load_rate], 0.01)
    end

    4.upto(11) do |level|
      gf = GF::Formation.new(:pyramid => level, :plc => 4, :print => :none)
      gf.start
      assert_equal(person_a[level], gf.summary[:person])
      assert(max_load_a[level] > gf.summary[:person_max_load_rate])
    end
  end
end
