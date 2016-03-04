#!/usr/bin/env ruby

# trigonal.rb - Load Estimator of Trigonal Human Pyramids
#   by takehikom
# see also:
#   https://gist.github.com/takehiko/a32f51e2eabba4f821d8
#   http://d.hatena.ne.jp/takehikom/20151019/1445266799
# usage:
#   ruby lib/gf/trigonal.rb
#   ruby lib/gf/trigonal.rb -p 7 -m 0
#   ruby lib/gf/trigonal.rb -p 7 -m 1
#   ruby lib/gf/trigonal.rb -p 7 -m 2
#   ruby lib/gf/trigonal.rb -p 7 -m 4

require_relative "root.rb"
require "optparse"

module GFLoad
  class Formation
    def build_pyramid_trigonal(level = 4)
      # トップダウンで三角錐型（立体型）ピラミッドを構成
      raise if level < 3

      name_top = compose_name(level, 1, 1)
      p = GFLoad::Person.new(:name => name_top)
      add_person(p)

      name_a = [compose_name(level - 1, 1, 1), compose_name(level - 1, 1, 2)]
      name_a.each do |name|
        p = GFLoad::Person.new(:name => name)
        add_person(p)
        @mem[name_top].put_load(p, 0.5)
      end

      until name_a.empty?
        name = name_a.shift
        p = @mem[name]

        i, j, k = decompose_name(name)

        if i >= 3
          i2 = i - 2
          j2 = j + 1
          [k, k + 1].each do |k2|
            name2 = compose_name(i2, j2, k2)
            if !@mem.key?(name2)
              p2 = GFLoad::Person.new(:name => name2)
              add_person(p2)
              name_a << name2
            else
              p2 = @mem[name2]
            end
            p.put_load(p2, 0.35)
          end
        end

        if i >= 2
          i2 = i - 1
          j2 = j
          [k, k + 1].each do |k2|
            name2 = compose_name(i2, j2, k2)
            if !@mem.key?(name2)
              p2 = GFLoad::Person.new(:name => name2)
              add_person(p2)
              name_a << name2
            else
              p2 = @mem[name2]
            end
            p.put_load(p2, 0.15)
          end
        end
      end
    end
  end

  class Trigonal
    include GFLoad::Helper

    def initialize(param = {})
      @level = param[:level] || 5      # 三角錐型人間ピラミッドの段数
      @zmax = param[:zmax] || 2        # generate_random_bmで使用
      @placement_id = param[:plc] || 2 # 体重配分の方法
      @weight_a = param[:w]            # 体重のリスト
      @print = param[:print]
    end
    attr_reader :level, :zmax, :placement_id, :gf
    attr_accessor :weight_a

    def start(opt_noprint = false)
      @gf = GFLoad::Formation.new
      @gf.build_pyramid_trigonal(@level)

      unless Array === @weight_a
        init_weight_a
      end

      case @placement_id.to_s
      when "0"
        # do nothing
      when "1"
        place1
      when "3"
        place3
      when "4"
        place4
      else # when "2"
        place2
      end

      if !opt_noprint
        if @print == :verbose
          puts @gf
          puts @gf.to_s_member
        else
          puts self.to_s
        end
      end
    end

    def summary
      raise if @gf.nil?

      sum = Hash.new
      sum[:person] = @gf.mem.size
      sum[:total_weight] = @gf.total_weight
      sum[:max_load_weight] = @gf.max_load_weight
      p_max = @gf.member.sort_by {|p| p.load_weight_rate}.last
      sum[:person_max_load_rate] = p_max.load_weight_rate
      sum[:person_max_load_name] = p_max.name
      sum[:person_max_load_weight] = p_max.weight
      sum[:person_max_load] = p_max.load_weight

      sum
    end
    alias :summary_h :summary

    def summary_a
      sum = summary
      [sum[:person], sum[:total_weight], sum[:max_load_weight],
        sum[:person_max_load_rate], sum[:person_max_load_name],
        sum[:person_max_load_weight], sum[:person_max_load]]
    end

    def to_s
      sum = summary
      s_gf = @gf.to_s
      s_self = "max_rate=%g (name=%s, weight=%g, load=%g)" %
        [sum[:person_max_load_rate], sum[:person_max_load_name],
        sum[:person_max_load_weight], sum[:person_max_load]]
      [s_gf, s_self].join(", ")
    end

    def init_weight_a
      @weight_a = sample(@gf.mem.size, @zmax)
    end

    def place1
      # 土台と2段目以上に分けず，負荷の高いところを体重の重い者に割り当てる
      p_a = @gf.mem.values.sort_by {|p| p.load_weight}
      w_a = @weight_a.sort

      p_a.each_with_index do |p, i|
        w = w_a[i]
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end
    end

    def place2
      # 土台と2段目以上に分け，負荷の高いところを体重の重い者に割り当てる
      # (gfload+.rbのデフォルト処理)
      p_a = @gf.mem.values
      p_a1 = p_a.dup
      p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
      p_a2 = p_a - p_a1                         # 2段目以上の人(誰かに負荷をかける)
      p_a1.sort_by! {|p| p.load_weight}
      p_a2.sort_by! {|p| p.load_weight}
      w_a = @weight_a.sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "w_a: #{w_a.inspect}"
      end

      [p_a2, p_a1].each do |p_aa|
        p_aa.each do |p|
          w = w_a.shift
          p.weight = w
          puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
        end
      end
    end

    def place3
      # 土台と上2段と残りに分け，残りは総当たり
      # 他の方法と比べて時間がかかるが，結果はplace4と同じになる
      p_a = @gf.mem.values
      p_a1 = p_a.dup
      p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
      p_a2 = p_a - p_a1                         # 残り
      p_a3 = [[level, 1, 1], [level - 1, 1, 1], [level - 1, 1, 2]].map {|pos|
        @gf.mem[compose_name(*pos)]
      }                                         # 上2段の人
      p_a2 -= p_a3
      p_a1.sort_by! {|p| p.load_weight}
      p_a2.sort_by! {|p| p.load_weight}
      w_a = @weight_a.sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "p_a3: #{p_a2.map{|p| p.name}.inspect}"
        puts "w_a: #{w_a.inspect}"
      end

      # 上2段
      p_a3.each do |p|
        w = w_a.shift
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      # 土台
      p_a1.reverse.each do |p|
        w = w_a.pop
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      if p_a2.length != w_a.length
        raise
      end

      # 残り
      c = c_init = 10000
      min_load = @gf.max_load_weight * 2
      min_a = (0...p_a2.length).to_a
      min_a.dup.permutation do |a|
        a.each do |num|
          p_a2[num].weight = w_a[num]
        end

        if min_load > @gf.max_load_weight
          min_load = @gf.max_load_weight
          min_a = a.dup
          print "!";
        end
        c -= 1
        if c == 0
          print "*";
          c = c_init
        end
      end
      puts
      min_a.each do |num|
        p_a2[num].weight = w_a[num]
        puts "%s : %5.2f kg" % [p_a2[num].name, w_a[num]] if $DEBUG
      end
    end

    def place4
      # 土台と上2段と残りに分ける
      p_a = @gf.mem.values
      p_a1 = p_a.dup
      p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
      p_a2 = p_a - p_a1                         # 残り
      p_a3 = [[level, 1, 1], [level - 1, 1, 1], [level - 1, 1, 2]].map {|pos|
        @gf.mem[compose_name(*pos)]
      }                                         # 上2段の人
      p_a2 -= p_a3
      p_a1.sort_by! {|p| p.load_weight}
      p_a2.sort_by! {|p| p.load_weight}
      w_a = @weight_a.sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "p_a3: #{p_a2.map{|p| p.name}.inspect}"
        puts "w_a: #{w_a.inspect}"
      end

      # 上2段
      p_a3.each do |p|
        w = w_a.shift
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      # 土台
      p_a1.reverse.each do |p|
        w = w_a.pop
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      if p_a2.length != w_a.length
        raise
      end

      # 残り
      p_a2.each do |p|
        w = w_a.shift
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end
    end
  end
end

if __FILE__ == $0
  seed = 12345
  opt = OptionParser.new
  h = {}
  opt.on("-p", "--pyramid=VAL",
         "Level of human pyramid") {|v| h[:level] = v.to_i}
  opt.on("-z", "--zmax=VAL",
         "Threshold of weight") {|v| h[:zmax] = v.to_f}
  opt.on("-s", "--seed=VAL",
         "Random seed") {|v| seed = v.to_i}
  opt.on("-m", "--placement=VAL",
         "Placement Method") {|v| h[:plc] = v.dup}
  opt.on("-v", "--verbose",
         "Print verbose info") { h[:print] = :verbose }
  opt.parse!(ARGV)
  srand(seed)
  GFLoad::Trigonal.new(h).start
end
