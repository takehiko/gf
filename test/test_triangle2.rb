require "test/unit"
require_relative "../lib/gf/root.rb"

class TestTriangle2 < Test::Unit::TestCase
  def test_create_triangle2_level5
    gf = GF::Formation.new(:triangle2 => 5, :print => :none)
    gf.start
    assert_equal([15, 15, 2.125, 2.125, "2.3", 1, 2.125], gf.summary_a)
  end

  def test_create_triangle2_level7
    gf0 = GF::Formation.new(:triangle2 => 7, :print => :none)
    gf0.start
    gf4 = GF::Formation.new(:triangle2 => 7, :plc => 4, :dist => 2, :print => :none)
    gf4.start
    summary_a = [28, 28.0, 3.8125, 3.8125, "2.4", 1.0, 3.8125]
    assert_equal(summary_a, gf0.summary_a)
    assert_not_equal(summary_a, gf4.summary_a)
    assert_equal(gf0.size, gf4.size)
    assert(gf0.summary_a[3] > gf4.summary_a[3])
  end

  def test_compare_triangle2_and_pyramid_level3
    gf1 = GF::Formation.new(:triangle2 => 3, :print => :none)
    gf1.start
    gf2 = GF::Formation.new(:pyramid => 3, :print => :none)
    gf2.start
    assert_equal(gf1.size, gf2.size)
    assert_equal(gf1.member.sort_by {|p| p.name}.map {|p| p.load_weight},
                 gf2.member.sort_by {|p| p.name}.map {|p| p.load_weight})
  end
end

class TestTriangleTrigonal < Test::Unit::TestCase
  def test_create_triangle_trigonal_level5_1
    gf = GF::Formation.new(:triangle2 => [5, 2], :print => :none)
    gf.start
    assert_equal([15, 15.0, 2.125, 2.125, "2.1.3", 1.0, 2.125], gf.summary_a)
  end

  def test_create_triangle_trigonal_level7_1
    gf0 = GF::Formation.new(:triangle2 => [7, 2], :print => :none)
    gf0.start
    gf4 = GF::Formation.new(:triangle2 => [7, 2], :plc => 4, :dist => 2, :print => :none)
    gf4.start
    summary_a = [28, 28.0, 3.8125, 3.8125, "2.1.4", 1.0, 3.8125]
    assert_equal(summary_a, gf0.summary_a)
    assert_not_equal(summary_a, gf4.summary_a)
    assert_equal(gf0.size, gf4.size)
    assert(gf0.summary_a[3] > gf4.summary_a[3])
  end

  def test_create_triangle_trigonal_level5_2to4
    gf52 = GF::Formation.new(:triangle2 => [5, 2], :print => :none)
    gf52.start
    assert_equal([15, 15.0, 2.125, 2.125, "2.1.3", 1.0, 2.125], gf52.summary_a)
    # puts gf52.to_s
    # puts gf52.to_s_member

    gf53 = GF::Formation.new(:triangle2 => [5, 3], :print => :none)
    gf53.start
    assert_equal([19, 19.0, 1.5, 1.5, "3.1.2", 1.0, 1.5], gf53.summary_a)
    # puts gf53.to_s
    # puts gf53.to_s_member

    gf54 = GF::Formation.new(:triangle2 => [5, 4], :print => :none)
    gf54.start
    assert_equal([22, 22.0, 1.4725, 1.4725, "1.2.3", 1.0, 1.4725], gf54.summary_a)

    assert_raise do
      GF::Formation.new(:triangle2 => [2, 1], :print => :none).start
    end

    assert_raise do
      GF::Formation.new(:triangle2 => [5, 0], :print => :none).start
    end
  end
end
