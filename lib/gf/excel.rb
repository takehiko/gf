#!/usr/bin/env ruby

# gfload.rb : Save as Excel, Load Calculator for Gymnastic Formation
#   by takehikom

require_relative "gfload.rb"
require "rubyXL"

module GFLoad
  class Formation
    def to_excel_obj
      puts "under construction"
      raise
    end

    def to_excel
      @workbook = RubyXL::Workbook.new
      @worksheet = @workbook[0]
      @worksheet.sheet_name = @opt[:sheet_name] if @opt[:sheet_name]

      # 表頭
      pos_a = generate_pos_array
      pos_a_size = pos_a.size
      @header = pos_a + %w(名前 自重 荷重 荷重/自重 荷重+自重)
      @header.each_with_index do |v, i|
        @worksheet.add_cell(0, i, v)
      end
      # 列位置は幅を小さく
      pos_a_size.times do |i|
        @worksheet.change_column_width(i, 3)
      end

      # Personインスタンスごとに行を追加
      p_a = sort_person(@mem.values)
      p_a.each_with_index do |p, i|
        row_a = fit_pos_array(decompose_name(p.name), pos_a_size)
        row_a << p.name
        row_a << p.weight
        row_a << p.load_weight
        row_a << "=" + RubyXL::Reference.ind2ref(i + 1, @header.index("荷重")) + "/" + RubyXL::Reference.ind2ref(i + 1, @header.index("自重"))
        row_a << "=" + RubyXL::Reference.ind2ref(i + 1, @header.index("自重")) + "+" + RubyXL::Reference.ind2ref(i + 1, @header.index("荷重"))

        sort_person(p.sup.keys).each do |p2|
          j = row_a.size # 格納する値の列位置
          j_name = @header.index("名前")
          j_total_weight = @header.index("荷重+自重")

          # 直接負荷をかける（自分の上の）者の名前
          row_a << "=" + RubyXL::Reference.ind2ref(p_a.index(p2) + 1, j_name)
          j += 1

          # 負荷割合
          row_a << p2.sub[p]
          j += 1

          # 荷重+自重
          c11 = RubyXL::Reference.ind2ref(1, j_name)
          c12 = RubyXL::Reference.ind2ref(p_a.size + 1, j_name)
          c21 = RubyXL::Reference.ind2ref(1, j_total_weight)
          c22 = RubyXL::Reference.ind2ref(p_a.size + 1, j_total_weight)
          c3 = RubyXL::Reference.ind2ref(i + 1, j - 2)
          row_a << "=IF(COUNTIF($%s:$%s,%s),INDEX($%s:$%s,MATCH(%s,$%s:$%s,0),1),0)" % [c11, c12, c3, c21, c22, c3, c11, c12]
          j += 1

          # (荷重+自重)*負荷割合
          row_a << "=" + RubyXL::Reference.ind2ref(i + 1, j - 1) + "*" + RubyXL::Reference.ind2ref(i + 1, j - 2)
          j += 1
        end

        j_load = @header.index("荷重")
        row_a[j_load] = "=SUM(" + (1..4).to_a.map{|j| RubyXL::Reference.ind2ref(i + 1, @header.size + j * 4 - 1)}.join(",") + ")"

        row_a.each_with_index do |v, j|
          if v.nil? || v == ""
            # do nothing
          elsif String === v && /^=/ =~ v
            @worksheet.add_cell(i + 1, j, "", $')
          else
            @worksheet.add_cell(i + 1, j, v)
          end
        end
      end

      # ファイルを保存
      filename_out = @opt[:workbook_name] || "gfload.xlsx"
      puts "save as #{filename_out}..."
      @workbook.write(filename_out)
    end

    def generate_pos_array
      if @opt[:possize]
        pos_size = @opt[:possize].to_i
      else
        pos_size = decompose_name(@mem.keys.first).size
      end

      case pos_size
      when 0
        pos_a = []
      when 1
        pos_a = %w(番)
      when 2
        pos_a = %w(段 番)
      when 3
        pos_a = %w(段 列 番)
      else
        raise
      end

      pos_a
    end

    def fit_pos_array(a, size)
      (a + [nil] * size)[0, size]
    end
  end
end

if __FILE__ == $0
  case ARGV.shift
  when /^t/i
    level = (ARGV.shift || 4).to_i
    gf = GFLoad::Formation.new(:triangle => level, :workbook_name => "gfload_triangle#{level}.xlsx", :sheet_name => "Triangle #{level}")
    gf.build_pyramid_triangle(level)
    gf.to_excel
  when /^p/i
    level = (ARGV.shift || 5).to_i
    gf = GFLoad::Formation.new(:pyramid => level, :workbook_name => "gfload_trigonal#{level}.xlsx", :sheet_name => "Trigonal #{level}")
    gf.build_pyramid_trigonal(level)
    gf.to_excel
  when /^e/i
    require_relative "gfload_est.rb"
    level = (ARGV.shift || 5).to_i
    est = GFLoad::Estimator.new(:level => level, :print => false, :plc => 4)
    est.start
    gf = est.gf
    gf.opt[:workbook_name] = "gfload_est#{level}.xlsx"
    gf.opt[:sheet_name] = "Trigonal #{level}"
    gf.to_excel
  when /^a/i
    require_relative "gfload_est.rb"

    2.upto(8) do |level|
      gf = GFLoad::Formation.new(:triangle => level,
                                 :workbook_name => "gfload_triangle#{level}.xlsx",
                                 :sheet_name => "Triangle #{level}")
      gf.build_pyramid_triangle(level)
      gf.to_excel
    end

    4.upto(11) do |level|
      gf = GFLoad::Formation.new(:pyramid => level,
                                 :workbook_name => "gfload_trigonal#{level}.xlsx",
                                 :sheet_name => "Trigonal #{level}")
      gf.build_pyramid_trigonal(level)
      gf.to_excel
    end

    4.upto(11) do |level|
      est = GFLoad::Estimator.new(:level => level, :print => false, :plc => 4)
      est.start
      gf = est.gf
      gf.opt[:workbook_name] = "gfload_est#{level}.xlsx"
      gf.opt[:sheet_name] = "Trigonal #{level}"
      gf.to_excel
    end
  else
    puts "usage:"
    puts "  ruby #{__FILE__} trigngle [level]"
    puts "  ruby #{__FILE__} pyramid [level]"
    puts "  ruby #{__FILE__} est [level]"
    puts "  ruby #{__FILE__} all [level]"
  end
end
