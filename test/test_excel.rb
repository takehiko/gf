require "test/unit"
require_relative "../lib/gf/root.rb"

class TestExcel < Test::Unit::TestCase
  def test_create_triangle_excel
    2.upto(8) do |level|
      filename = "gf_triangle#{level}.xlsx"
      gf = GFLoad::Formation.new(:triangle => level,
                                 :workbook_name => filename,
                                 :sheet_name => "Triangle #{level}",
                                 :print => :none)
      gf.start
      gf.to_excel

      assert(test(?f, filename))
      workbook = RubyXL::Parser.parse(filename)
      assert_not_nil(workbook[0][gf.size])
      assert_equal(level, workbook[0][gf.size][0].value)
      assert_nil(workbook[0][gf.size + 1])

      File.unlink(filename)
    end
  end

  def test_create_trigonal_excel
    4.upto(11) do |level|
      filename = "gf_trigonal#{level}.xlsx"
      gf = GFLoad::Formation.new(:pyramid => level,
                                 :workbook_name => filename,
                                 :sheet_name => "Trigonal #{level}",
                                 :print => :none)
      gf.start
      gf.to_excel

      assert(test(?f, filename))
      workbook = RubyXL::Parser.parse(filename)
      assert_not_nil(workbook[0][gf.size])
      assert_equal(level, workbook[0][gf.size][0].value)
      assert_nil(workbook[0][gf.size + 1])

      File.unlink(filename)
    end
  end

  def test_create_yagura_excel
    [[3, 5], [3, 7], [4, 9], [5, 21]].each do |level, person|
      filename = "gf_yagura#{person}.xlsx"
      gf = GFLoad::Formation.new(:yagura => person,
                                 :workbook_name => filename,
                                 :sheet_name => "Yagura #{person}",
                                 :print => :none)
      gf.start
      gf.to_excel

      assert(test(?f, filename))
      workbook = RubyXL::Parser.parse(filename)
      assert_not_nil(workbook[0][gf.size])
      assert_equal(level, workbook[0][gf.size][0].value)
      assert_nil(workbook[0][gf.size + 1])

      File.unlink(filename)
    end
  end
end
